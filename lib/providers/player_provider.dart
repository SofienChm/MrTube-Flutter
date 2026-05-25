import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/secure_storage.dart';

class PlayerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Song> _related = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _likedIds = {};
  String? _playlistError;

  List<Song> get related => _related;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get playlistError => _playlistError;

  PlayerProvider() {
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    _likedIds = (prefs.getStringList('liked_songs') ?? []).toSet();
    notifyListeners();
  }

  Future<void> _saveLikes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_songs', _likedIds.toList());
  }

  bool isLiked(String videoId) => _likedIds.contains(videoId);

  Future<void> toggleLike(String videoId) async {
    if (_likedIds.contains(videoId)) {
      _likedIds.remove(videoId);
    } else {
      _likedIds.add(videoId);
    }
    notifyListeners();
    await _saveLikes();
  }

  Future<bool> addToPlaylist(String playlistId, Song song) async {
    _playlistError = null;
    try {
      final token = await SecureStorage().getToken();
      if (token != null) {
        _apiClient.setToken(token);
      }
      await _apiClient.post(ApiEndpoints.playlistSongs(playlistId), body: {
        'videoId': song.videoId,
        'title': song.title,
        'artist': song.artist,
        'thumbnail': song.thumbnail,
        'duration': song.duration,
      });
      return true;
    } catch (e) {
      _playlistError = 'Erreur lors de l\'ajout à la playlist';
      notifyListeners();
      return false;
    }
  }

  void shareSong(Song song) {
    Share.share(
      '${song.title} — ${song.artist}\n\nÉcouter sur YouTube : https://youtube.com/watch?v=${song.videoId}\n\nDécouvert via MrTube',
    );
  }

  Future<void> loadRelated(String videoId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.get(ApiEndpoints.related(videoId));
      _related = (data['data'] as List<dynamic>? ?? [])
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Impossible de charger les suggestions';
    }

    _isLoading = false;
    notifyListeners();
  }
}
