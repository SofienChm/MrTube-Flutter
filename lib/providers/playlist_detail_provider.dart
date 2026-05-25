import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';

class PlaylistDetailProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Playlist? _playlist;
  List<Song> _songs = [];
  bool _isLoading = false;
  String? _errorMessage;

  Playlist? get playlist => _playlist;
  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlaylist(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.get(ApiEndpoints.playlistById(id));
      _playlist = Playlist.fromJson(data);
      _songs = _playlist!.songs;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Impossible de charger la playlist';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> removeSong(String songId) async {
    if (_playlist == null) return false;
    final index = _songs.indexWhere((s) => s.videoId == songId);
    if (index == -1) return false;
    final removed = _songs.removeAt(index);
    notifyListeners();

    try {
      final apiId = removed.id ?? songId;
      await _apiClient.delete(ApiEndpoints.playlistSong(_playlist!.id, apiId));
      return true;
    } catch (e) {
      _songs.insert(index, removed);
      _errorMessage = 'Impossible de retirer la chanson';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSong(String playlistId, Song song) async {
    try {
      await _apiClient.post(ApiEndpoints.playlistSongs(playlistId), body: {
        'videoId': song.videoId,
        'title': song.title,
        'artist': song.artist,
        'thumbnail': song.thumbnail,
        'duration': song.duration,
      });
      _songs.add(song);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Impossible d\'ajouter la chanson';
      notifyListeners();
      return false;
    }
  }
}
