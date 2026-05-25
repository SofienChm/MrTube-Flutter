import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null && _token != null;

  Future<void> tryAutoLogin() async {
    final token = await _secureStorage.getToken();
    final user = await _secureStorage.getUser();
    if (token != null && user != null) {
      _token = token;
      _currentUser = user;
      _apiClient.setToken(token);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiClient.post(ApiEndpoints.login, body: {
        'email': email,
        'password': password,
      });
      final response = AuthResponse.fromJson(data);
      await _saveSession(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiClient.post(ApiEndpoints.register, body: {
        'name': name,
        'email': email,
        'password': password,
      });
      final response = AuthResponse.fromJson(data);
      await _saveSession(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = _extractError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _apiClient.setToken(null);
    await _secureStorage.clearAll();
    notifyListeners();
  }

  Future<void> _saveSession(AuthResponse response) async {
    _token = response.token;
    _currentUser = response.user;
    _apiClient.setToken(response.token);
    await _secureStorage.saveToken(response.token);
    await _secureStorage.saveUser(response.user);
  }

  String _extractError(DioException e) {
    try {
      final data = e.response?.data as Map<String, dynamic>?;
      return data?['message']?.toString() ?? 'Erreur de connexion';
    } catch (_) {
      return 'Erreur de connexion';
    }
  }
}
