import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Weather? get currentWeather => _currentWeather;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _apiUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<void> fetchCurrentWeather() async {
    try {
      if (_isLoading) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('WeatherProvider: Iniciando fetch...');

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        debugPrint('WeatherProvider: GPS OK - ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('WeatherProvider: GPS falhou, usando Lisboa: $e');
        position = Position(
          longitude: -9.1393,
          latitude: 38.7223,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      _currentPosition = position;

      final url = Uri.parse(
        '$_apiUrl?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true&timezone=Europe/Lisbon&language=pt',
      );

      debugPrint('WeatherProvider: Chamando API: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _currentWeather = Weather.fromJson(jsonData);
        _error = null;
        debugPrint('WeatherProvider: SUCCESS - ${_currentWeather!.temperature}°C');
      } else {
        _error = 'Erro API: ${response.statusCode}';
        debugPrint('WeatherProvider: ERRO API: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Erro: $e';
      debugPrint('WeatherProvider: ERRO: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getOutdoorSuggestion() {
    if (_currentWeather == null) return 'Sem dados';

    final temp = _currentWeather!.temperature;

    if (temp < 8) return 'Frio (${temp.toStringAsFixed(1)}°C) - Sugerir indoor';
    if (temp > 30) return 'Calor (${temp.toStringAsFixed(1)}°C) - Sugerir manhã/tarde';
    if (temp >= 15 && temp <= 25) return 'Perfeito para exterior (${temp.toStringAsFixed(1)}°C)';

    return '${temp.toStringAsFixed(1)}°C';
  }

  bool get isGoodForOutdoor =>
      _currentWeather != null && _currentWeather!.temperature >= 10 && _currentWeather!.temperature <= 28;

  Future<void> refresh() => fetchCurrentWeather();
}
