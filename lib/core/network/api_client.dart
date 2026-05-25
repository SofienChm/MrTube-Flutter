import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);
  @override
  String toString() => message;
}

class ServiceUnavailableException implements Exception {
  final String message;
  ServiceUnavailableException([this.message = 'Service unavailable']);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> _getAuthHeaders() async {
    final headers = <String, dynamic>{};
    final token = _token ?? await SecureStorage().getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _unwrapResponse(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      return body['data'] as Map<String, dynamic>;
    }
    throw ApiException(body['message']?.toString() ?? 'Unknown error');
  }

  List<dynamic> _unwrapListResponse(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      return body['data'] as List<dynamic>;
    }
    throw ApiException(body['message']?.toString() ?? 'Unknown error');
  }

  void _handleStatusCode(int? code, String message) {
    switch (code) {
      case 401:
        throw UnauthorizedException(message);
      case 404:
        throw NotFoundException(message);
      case 503:
        throw ServiceUnavailableException(message);
    }
  }

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(url, options: Options(headers: headers));
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleStatusCode(e.response?.statusCode, e.message ?? 'Request failed');
      rethrow;
    }
  }

  Future<List<dynamic>> getList(String url) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(url, options: Options(headers: headers));
      return _unwrapListResponse(response);
    } on DioException catch (e) {
      _handleStatusCode(e.response?.statusCode, e.message ?? 'Request failed');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(url,
          data: body, options: Options(headers: headers));
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleStatusCode(e.response?.statusCode, e.message ?? 'Request failed');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String url) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.delete(url, options: Options(headers: headers));
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleStatusCode(e.response?.statusCode, e.message ?? 'Request failed');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRaw(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Request failed', statusCode: e.response?.statusCode);
    }
  }
}
