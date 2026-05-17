import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/country.dart';
import '../services/countries_api.dart';
import '../widgets/country_flag.dart';
import '../widgets/google_globe_viewer.dart';
import 'country_details_page.dart';

enum HomeFilter { featured, all, region, capitals }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<CountryPreview>> _featuredCountriesFuture;
  Future<List<Country>>? _countriesFuture;
  HomeFilter _selectedFilter = HomeFilter.featured;

  @override
  void initState() {
    super.initState();
    _featuredCountriesFuture = CountriesApi.fetchCountryPreviews().then((
      countries,
    ) {
      countries.shuffle(math.Random());
      return countries.take(3).toList();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _changeFilter(HomeFilter filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter != HomeFilter.featured) {
        _countriesFuture ??= CountriesApi.fetchAllCountries();
      }
    });
  }

  void _returnToFeatured() {
    setState(() {
      _selectedFilter = HomeFilter.featured;
    });
  }

  Future<List<Country>> _loadCountriesIfNeeded() {
    return _countriesFuture ??= CountriesApi.fetchAllCountries();
  }

  List<Country> _applyNameFilter(List<Country> countries) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return countries;
    }

    return countries
        .where((country) => country.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localize Ai'),
        leading: _selectedFilter == HomeFilter.featured
            ? null
            : IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: _returnToFeatured,
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _selectedFilter == HomeFilter.featured
              ? _buildFeaturedHome()
              : _buildCountriesBrowser(),
        ),
      ),
    );
  }

  Widget _buildFeaturedHome() {
    final query = _searchController.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildFilterRow(),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<CountryPreview>>(
            future: _featuredCountriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar destaques: ${snapshot.error}'),
                );
              }

              final countries = snapshot.data ?? const <CountryPreview>[];

              return IndexedStack(
                index: query.isEmpty ? 0 : 1,
                children: [
                  _buildFeaturedInitialContent(countries),
                  _buildFeaturedSearchResults(query),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedInitialContent(List<CountryPreview> countries) {
    return ListView(
      children: [
        Text(
          'Países em destaque',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 72,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: countries.map((country) {
                return Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Semantics(
                    label: country.name,
                    button: true,
                    child: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(6),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () => _openCountryDetailsByName(country.name),
                        child: SizedBox(
                          width: 96,
                          height: 60,
                          child: CountryFlag(
                            flagUrl: country.flagUrl,
                            width: 96,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),
        const GoogleGlobeViewer(),
      ],
    );
  }

  Widget _buildFeaturedSearchResults(String query) {
    return FutureBuilder<List<Country>>(
      future: _loadCountriesIfNeeded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar dados: ${snapshot.error}'),
          );
        }

        final countries = snapshot.data ?? const <Country>[];
        final matches = countries
            .where((country) => country.name.toLowerCase().contains(query))
            .toList();

        if (matches.isEmpty) {
          return const Center(
            child: Text('Nenhum país encontrado para essa busca.'),
          );
        }

        return ListView.separated(
          itemCount: matches.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final country = matches[index];
            return _CountryTile(
              country: country,
              onTap: () => _openCountryDetails(country),
            );
          },
        );
      },
    );
  }

  Widget _buildCountriesBrowser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildFilterRow(),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Country>>(
            future: _loadCountriesIfNeeded(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar dados: ${snapshot.error}'),
                );
              }

              final countries = snapshot.data ?? const <Country>[];
              final filteredByName = _applyNameFilter(countries);

              if (filteredByName.isEmpty) {
                return const Center(
                  child: Text('Nenhum pais encontrado para essa busca.'),
                );
              }

              switch (_selectedFilter) {
                case HomeFilter.all:
                  return _AllCountriesList(
                    countries: filteredByName,
                    onCountryTap: _openCountryDetails,
                  );
                case HomeFilter.region:
                  return _CountriesByRegionList(
                    countries: filteredByName,
                    onCountryTap: _openCountryDetails,
                  );
                case HomeFilter.capitals:
                  return _CapitalsList(
                    countries: filteredByName,
                    onCountryTap: _openCountryDetails,
                  );
                case HomeFilter.featured:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filtros', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 12),

        Row(
          children: [
            _FilterSquare(
              title: 'Todos',
              icon: Icons.public,
              selected: _selectedFilter == HomeFilter.all,
              onTap: () => _changeFilter(HomeFilter.all),
            ),

            const SizedBox(width: 12),

            _FilterSquare(
              title: 'Regiao',
              icon: Icons.map,
              selected: _selectedFilter == HomeFilter.region,
              onTap: () => _changeFilter(HomeFilter.region),
            ),

            const SizedBox(width: 12),

            _FilterSquare(
              title: 'Capitais',
              icon: Icons.location_city,
              selected: _selectedFilter == HomeFilter.capitals,
              onTap: () => _changeFilter(HomeFilter.capitals),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Buscar',
        hintText: 'Ex: Brazil',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  void _openCountryDetails(Country country) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CountryDetailsPage(country: country)),
    );
  }

  void _openCountryDetailsByName(String countryName) {
    final future = _countriesFuture ??= CountriesApi.fetchAllCountries();
    future.then((countries) {
      final match = countries.firstWhere(
        (country) => country.name.toLowerCase() == countryName.toLowerCase(),
        orElse: () => countries.first,
      );
      if (!mounted) {
        return;
      }
      _openCountryDetails(match);
    });
  }
}

class _FilterSquare extends StatelessWidget {
  const _FilterSquare({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = selected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final borderColor = selected ? colorScheme.primary : Colors.transparent;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 110,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllCountriesList extends StatelessWidget {
  const _AllCountriesList({
    required this.countries,
    required this.onCountryTap,
  });

  final List<Country> countries;
  final ValueChanged<Country> onCountryTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: countries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final country = countries[index];
        return _CountryTile(
          country: country,
          onTap: () => onCountryTap(country),
        );
      },
    );
  }
}

class _CountriesByRegionList extends StatelessWidget {
  const _CountriesByRegionList({
    required this.countries,
    required this.onCountryTap,
  });

  final List<Country> countries;
  final ValueChanged<Country> onCountryTap;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Country>>{};
    for (final country in countries) {
      grouped.putIfAbsent(country.region, () => <Country>[]).add(country);
    }

    final regions = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final countriesInRegion = grouped[region]!
          ..sort((a, b) => a.name.compareTo(b.name));

        return ExpansionTile(
          title: Text('$region (${countriesInRegion.length})'),
          children: countriesInRegion
              .map(
                (country) => ListTile(
                  leading: CountryFlag(flagUrl: country.flagUrl),
                  title: Text(country.name),
                  onTap: () => onCountryTap(country),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CapitalsList extends StatelessWidget {
  const _CapitalsList({required this.countries, required this.onCountryTap});

  final List<Country> countries;
  final ValueChanged<Country> onCountryTap;

  @override
  Widget build(BuildContext context) {
    final entries = <({String capital, Country country})>[];
    for (final country in countries) {
      for (final capital in country.capitals) {
        entries.add((capital: capital, country: country));
      }
    }

    entries.sort((a, b) => a.capital.compareTo(b.capital));

    if (entries.isEmpty) {
      return const Center(
        child: Text('Nenhuma capital encontrada para os paises filtrados.'),
      );
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          child: ListTile(
            leading: CountryFlag(flagUrl: entry.country.flagUrl),
            title: Text(entry.capital),
            subtitle: Text(entry.country.name),
            onTap: () => onCountryTap(entry.country),
          ),
        );
      },
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({required this.country, this.onTap});

  final Country country;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final capitalText = country.capitals.isNotEmpty
        ? country.capitals.join(', ')
        : 'Sem capital registrada';

    return Card(
      child: ListTile(
        leading: CountryFlag(flagUrl: country.flagUrl),
        title: Text(country.name),
        subtitle: Text('Regiao: ${country.region}\nCapital: $capitalText'),
        onTap: onTap,
      ),
    );
  }
}
