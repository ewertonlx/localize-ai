import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/country.dart';

class CountriesApi {
  static const String _previewEndpoint =
      'https://restcountries.com/v3.1/all?fields=name,flags';
  static const String _endpoint =
      'https://restcountries.com/v3.1/all?fields=name,capital,region,flags,maps,latlng,population,languages';

  static Future<List<CountryPreview>> fetchCountryPreviews() async {
    final response = await http.get(Uri.parse(_previewEndpoint));

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao carregar destaques: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Resposta invalida da API.');
    }

    final countries = decoded
        .whereType<Map<String, dynamic>>()
        .map(CountryPreview.fromJson)
        .toList();

    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  static Future<List<Country>> fetchAllCountries() async {
    final response = await http.get(Uri.parse(_endpoint));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar paises: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Resposta invalida da API.');
    }

    final countries = decoded
        .whereType<Map<String, dynamic>>()
        .map(Country.fromJson)
        .toList();

    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }
}
