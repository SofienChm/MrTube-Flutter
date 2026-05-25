import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/song.dart';

class LocalStorage {
  static const _recentlyPlayedKey = 'recently_played';
  static const int _maxSongs = 20;

  Future<List<Song>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_recentlyPlayedKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Song.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRecentlyPlayed(Song song) async {
    final songs = await getRecentlyPlayed();
    songs.removeWhere((s) => s.videoId == song.videoId);
    songs.insert(0, song);
    if (songs.length > _maxSongs) {
      songs.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _recentlyPlayedKey, jsonEncode(songs.map((s) => s.toJson()).toList()));
  }

  Future<void> clearRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyPlayedKey);
  }
}
