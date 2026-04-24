import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/country.dart';
import '../widgets/country_flag.dart';

class CountryDetailsPage extends StatelessWidget {
  const CountryDetailsPage({super.key, required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'pt_BR');
    final capitalText = country.capitals.isNotEmpty
        ? country.capitals.join(', ')
        : 'Sem capital registrada';

    return Scaffold(
      appBar: AppBar(title: const Text('Informações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CountryFlag(flagUrl: country.flagUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  country.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome oficial: ${country.officialName}'),
                  const SizedBox(height: 8),
                  Text(
                    'População: ${formatter.format(country.population)} habitantes',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Idiomas: ${country.languages.isNotEmpty ? country.languages.join(', ') : 'Não informado'}',
                  ),
                  const SizedBox(height: 8),
                  Text('Regiao: ${country.region}'),
                  const SizedBox(height: 8),
                  Text('Capital: $capitalText'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: country.openStreetMapsUrl.isEmpty
                            ? null
                            : () => _openExternalUrl(country.openStreetMapsUrl),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Abrir OpenStreetMap'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: country.googleMapsUrl.isEmpty
                            ? null
                            : () => _openExternalUrl(country.googleMapsUrl),
                        icon: const Icon(Icons.public),
                        label: const Text('Abrir Google Maps'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mini mapa da localizacao',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _CountryMiniMap(country: country),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CountryMiniMap extends StatelessWidget {
  const _CountryMiniMap({required this.country});

  static const Map<String, String> _osmHeaders = <String, String>{
    'User-Agent':
        'LocalizeAI/1.0 (Flutter app; contact: suporte@localizeai.app)',
    'Accept': 'image/png,image/*;q=0.8,*/*;q=0.5',
  };

  final Country country;

  @override
  Widget build(BuildContext context) {
    if (country.latitude == null || country.longitude == null) {
      return const Card(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Text('Coordenadas indisponiveis para este pais.'),
          ),
        ),
      );
    }

    final lat = country.latitude!;
    final lon = country.longitude!;
    const zoom = 4;
    final tileX = _longitudeToTileX(lon, zoom);
    final tileY = _latitudeToTileY(lat, zoom);
    final tileUrl = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              tileUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              headers: _osmHeaders,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0xFFE5E7EB),
                child: Center(child: Text('Falha ao carregar mini mapa.')),
              ),
            ),
            const Icon(Icons.location_on, color: Colors.red, size: 42),
          ],
        ),
      ),
    );
  }

  int _longitudeToTileX(double longitude, int zoom) {
    final scale = math.pow(2, zoom).toDouble();
    return ((longitude + 180.0) / 360.0 * scale).floor();
  }

  int _latitudeToTileY(double latitude, int zoom) {
    final latRad = latitude * math.pi / 180.0;
    final scale = math.pow(2, zoom).toDouble();
    final mercator = math.log(math.tan(latRad) + 1 / math.cos(latRad));
    return ((1.0 - mercator / math.pi) / 2.0 * scale).floor();
  }
}
