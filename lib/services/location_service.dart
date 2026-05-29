import 'package:dio/dio.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  String? _cachedCountry;

  Future<String?> getCountry() async {
    if (_cachedCountry != null) return _cachedCountry;
    try {
      final response = await _dio.get('https://ip-api.com/json/');
      _cachedCountry = response.data['country'] as String?;
      return _cachedCountry;
    } catch (_) {
      return null;
    }
  }
}