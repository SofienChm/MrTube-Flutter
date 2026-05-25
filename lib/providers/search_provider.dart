import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/search_result.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class SearchProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Song> _results = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'music_songs';
  String _currentQuery = '';
  Timer? _debounce;

  List<Song> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String get currentQuery => _currentQuery;

  Future<void> search(String query, {String filter = 'music_songs'}) async {
    _currentQuery = query;
    _currentFilter = filter;
    _debounce?.cancel();

    if (query.trim().length < 2) {
      _results = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        final data = await _apiClient.get(ApiEndpoints.search(query, filter: filter));
        final result = SearchResult.fromJson(data);
        _results = result.songs;
      } catch (e) {
        _errorMessage = 'Aucun résultat trouvé';
        _results = [];
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    if (_currentQuery.isNotEmpty) {
      search(_currentQuery, filter: filter);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
