import 'dart:convert';

class Weather {
  final double temperature;

  Weather({required this.temperature});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['current_weather']['temperature'] as num).toDouble(),
    );
  }
}
