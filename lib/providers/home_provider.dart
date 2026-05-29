import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/local_storage.dart';
import '../services/location_service.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final LocalStorage _localStorage = LocalStorage();

  List<Song> _trending = [];
  List<Song> _recentlyPlayed = [];
  List<Song> _recommendations = [];
  List<Song> _quickPicks = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _generation = 0;

  List<Song> get trending => _trending;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  List<Song> get recommendations => _recommendations;
  List<Song> get quickPicks => _quickPicks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadData({bool isLoggedIn = false}) async {
    final gen = ++_generation;
    debugPrint('[HomeProvider] loadData gen=$gen isLoggedIn=$isLoggedIn');
    _isLoading = true;
    notifyListeners();

    try {
      final r0 = _loadTrending();
      final r3 = _loadQuickPicks();
      final r1 = _loadRecentlyPlayed(isLoggedIn);
      await Future.wait([r0, r3, r1]);
      if (gen < _generation) return;
      _trending = await r0;
      _quickPicks = await r3;
      _recentlyPlayed = await r1;

      final r2 = _loadRecommendations(_recentlyPlayed);
      _recommendations = await r2;
      if (gen < _generation) return;

      debugPrint('[HomeProvider] trending=${_trending.length} recently=${_recentlyPlayed.length} recs=${_recommendations.length} picks=${_quickPicks.length}');
      _errorMessage = null;
    } catch (e) {
      if (gen < _generation) return;
      debugPrint('[HomeProvider] loadData error: $e');
      _errorMessage = 'Impossible de charger les données';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Song>> _loadTrending() async {
    try {
      final region = await LocationService().getCountry();
      final data = await _apiClient.getList(ApiEndpoints.trending(region: region));
      return data
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Song>> _loadRecentlyPlayed(bool isLoggedIn) async {
    if (isLoggedIn) {
      try {
        final data = await _apiClient.getList(ApiEndpoints.recentlyPlayed);
        debugPrint('[HomeProvider] recentlyPlayed API returned ${data.length} items');
        if (data.isNotEmpty) {
          return data
              .map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint('[HomeProvider] recentlyPlayed API error: $e');
      }
    }
    final local = await _localStorage.getRecentlyPlayed();
    debugPrint('[HomeProvider] recentlyPlayed local storage returned ${local.length} items');
    return local;
  }

  Future<List<Song>> _loadRecommendations(List<Song> recentlyPlayed) async {
    if (recentlyPlayed.isEmpty) return [];
    try {
      final ids = recentlyPlayed.take(3).map((s) => s.videoId).join(',');
      if (ids.isEmpty) return [];
      final data = await _apiClient.getList(ApiEndpoints.recommendations(ids));
      return data
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Song>> _loadQuickPicks() async {
    try {
      final data = await _apiClient.getList(ApiEndpoints.quickPicks);
      return data
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    await loadData();
  }
}
