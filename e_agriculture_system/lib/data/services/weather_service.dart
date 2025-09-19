import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  Future<WeatherResult> getWeatherForCity(String cityName) async {
    try {
      final location = await _geocodeCity(cityName);
      if (location == null) {
        throw Exception('City "$cityName" not found. Please check the spelling.');
      }

      final forecast = await _fetchForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      return forecast;
    } catch (e) {
      print('Weather service error: $e'); // For debugging
      rethrow;
    }
  }

  Future<_Location?> _geocodeCity(String cityName) async {
    try {
      final uri = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeQueryComponent(cityName)}&count=5&language=en&format=json',
      );
      
      final response = await _client.get(uri).timeout(_timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Geocoding API returned status ${response.statusCode}');
      }
      
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (json['results'] as List?) ?? [];
      
      if (results.isEmpty) return null;

      // Prefer Sri Lanka (LK) results first, then any result
      Map<String, dynamic>? selected = results
          .cast<Map<String, dynamic>>()
          .where((r) => (r['country_code'] as String?)?.toUpperCase() == 'LK')
          .firstOrNull;
      
      // If no Sri Lankan city found, take the first result
      selected ??= results.first as Map<String, dynamic>;

      return _Location(
        latitude: (selected['latitude'] as num).toDouble(),
        longitude: (selected['longitude'] as num).toDouble(),
        name: selected['name'] as String? ?? cityName,
        country: selected['country'] as String? ?? '',
      );
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  Future<WeatherResult> _fetchForecast({
    required double latitude, 
    required double longitude
  }) async {
    try {
      final params = {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '7',
      };
      
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', params);
      final response = await _client.get(uri).timeout(_timeout);
      
      if (response.statusCode != 200) {
        throw Exception('Weather API returned status ${response.statusCode}');
      }
      
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final current = json['current'] as Map<String, dynamic>?;
      final daily = json['daily'] as Map<String, dynamic>?;
      
      if (current == null || daily == null) {
        throw Exception('Invalid weather data received');
      }

      final int code = (current['weather_code'] as num).toInt();
      final currentDesc = _descriptionForCode(code);
      final currentIcon = _emojiForCode(code);

      final List times = (daily['time'] as List?) ?? [];
      final List tempsMax = (daily['temperature_2m_max'] as List?) ?? [];
      final List tempsMin = (daily['temperature_2m_min'] as List?) ?? [];
      final List weatherCodes = (daily['weather_code'] as List?) ?? [];

      final now = DateTime.now();
      List<ForecastDay> forecast = [];
      
      for (int i = 0; i < times.length && i < 7; i++) {
        final date = DateTime.tryParse(times[i] as String);
        if (date == null) continue;
        
        final label = _labelForDate(now, date);
        final wCode = (weatherCodes[i] as num).toInt();
        
        forecast.add(
          ForecastDay(
            label: label,
            temperatureMaxC: (tempsMax[i] as num).toDouble(),
            temperatureMinC: i < tempsMin.length ? (tempsMin[i] as num).toDouble() : (tempsMax[i] as num).toDouble(),
            description: _descriptionForCode(wCode),
            icon: _emojiForCode(wCode),
          ),
        );
      }

      return WeatherResult(
        currentTemperatureC: (current['temperature_2m'] as num).toDouble(),
        apparentTemperatureC: (current['apparent_temperature'] as num).toDouble(),
        humidityPercent: (current['relative_humidity_2m'] as num).toInt(),
        windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
        currentDescription: currentDesc,
        currentIcon: currentIcon,
        forecast: forecast,
      );
    } catch (e) {
      print('Weather fetch error: $e');
      rethrow;
    }
  }

  String _labelForDate(DateTime now, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _descriptionForCode(int code) {
    const Map<int, String> descriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy', 
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      56: 'Light freezing drizzle',
      57: 'Dense freezing drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      66: 'Light freezing rain',
      67: 'Heavy freezing rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      97: 'Thunderstorm with heavy hail',
    };
    
    return descriptions[code] ?? 'Unknown weather';
  }

  String _emojiForCode(int code) {
    const Map<int, String> emojis = {
      0: '☀️',
      1: '🌤️',
      2: '⛅',
      3: '☁️',
      45: '🌫️',
      48: '🌫️',
      51: '🌦️',
      53: '🌦️',
      55: '🌦️',
      56: '🌦️',
      57: '🌦️',
      61: '🌧️',
      63: '🌧️',
      65: '🌧️',
      66: '🌧️',
      67: '🌧️',
      71: '❄️',
      73: '❄️',
      75: '❄️',
      77: '❄️',
      80: '🌦️',
      81: '🌦️',
      82: '🌦️',
      85: '❄️',
      86: '❄️',
      95: '⛈️',
      96: '⛈️',
      97: '⛈️',
    };
    
    return emojis[code] ?? '⛅';
  }
}

class _Location {
  _Location({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
  });
  
  final double latitude;
  final double longitude;
  final String name;
  final String country;
}

class WeatherResult {
  WeatherResult({
    required this.currentTemperatureC,
    required this.apparentTemperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.currentDescription,
    required this.currentIcon,
    required this.forecast,
  });

  final double currentTemperatureC;
  final double apparentTemperatureC;
  final int humidityPercent;
  final double windSpeedKmh;
  final String currentDescription;
  final String currentIcon;
  final List<ForecastDay> forecast;

  Map<String, dynamic> toCurrentMap() => {
        'temp': currentTemperatureC.round(),
        'feels_like': apparentTemperatureC.round(),
        'humidity': humidityPercent,
        'wind_speed': windSpeedKmh.round(),
        'description': currentDescription,
        'icon': currentIcon,
      };

  List<Map<String, dynamic>> toForecastList() => forecast
      .map((f) => {
            'day': f.label,
            'temp': f.temperatureMaxC.round(),
            'temp_min': f.temperatureMinC.round(),
            'icon': f.icon,
            'description': f.description,
          })
      .toList();
}

class ForecastDay {
  ForecastDay({
    required this.label,
    required this.temperatureMaxC,
    required this.temperatureMinC,
    required this.description,
    required this.icon,
  });

  final String label;
  final double temperatureMaxC;
  final double temperatureMinC;
  final String description;
  final String icon;
}

