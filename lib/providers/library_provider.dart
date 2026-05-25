import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class LibraryProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.getList(ApiEndpoints.playlist);
      _playlists = data
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Impossible de charger les playlists';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPlaylist(String name) async {
    try {
      final data = await _apiClient.post(ApiEndpoints.playlist, body: {
        'name': name,
      });
      final playlist = Playlist.fromJson(data);
      _playlists.add(playlist);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Impossible de créer la playlist';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlaylist(String id) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    final removed = _playlists.removeAt(index);
    notifyListeners();

    try {
      await _apiClient.delete(ApiEndpoints.playlistById(id));
      return true;
    } catch (e) {
      _playlists.insert(index, removed);
      _errorMessage = 'Impossible de supprimer la playlist';
      notifyListeners();
      return false;
    }
  }
}
