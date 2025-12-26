import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart'; // teu model

class WeatherProvider with ChangeNotifier {
  Weather? _currentWeather;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  Weather? get currentWeather => _currentWeather;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _apiKey = 'SUA_OPENWEATHERMAP_API_KEY_AQUI';
  static const String _apiUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<void> fetchCurrentWeather() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Geolocalização
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Serviços de localização desativados';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permissão de localização negada';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Open-Meteo API (grátis, sem key)
      final url = Uri.parse('$_apiUrl?latitude=${_currentPosition!.latitude}&longitude=${_currentPosition!.longitude}&current_weather=true&timezone=Europe/Lisbon&language=pt');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _currentWeather = Weather.fromJson(jsonData);
        _error = null;
      } else {
        _error = 'Erro ao obter tempo: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de rede: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sugestão para tarefas outdoor
  String getOutdoorSuggestion() {
    if (_currentWeather == null) return '';

    final temp = _currentWeather!.temperature;

    if (temp < 8) return 'Frio (${temp.toStringAsFixed(1)}°C) - Sugerir indoor';
    if (temp > 30) return 'Calor (${temp.toStringAsFixed(1)}°C) - Sugerir manhã/tarde';
    if (temp >= 15 && temp <= 25) return 'Perfeito para exterior (${temp.toStringAsFixed(1)}°C)';

    return '${temp.toStringAsFixed(1)}°C';
  }

  bool get isGoodForOutdoor =>
      _currentWeather != null && _currentWeather!.temperature >= 10 && _currentWeather!.temperature <= 28;

  Future<void> refresh() => fetchCurrentWeather();

  @override
  void dispose() {
    super.dispose();
  }
}
