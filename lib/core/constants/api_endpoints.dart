import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    const prodUrl = String.fromEnvironment('BASE_URL');
    if (prodUrl.isNotEmpty) return prodUrl;
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return 'http://100.89.232.15:8086';
  }

  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String trending({String? region}) => region != null
      ? '$baseUrl/music/trending?region=${Uri.encodeComponent(region)}'
      : '$baseUrl/music/trending';
  static String get playlist => '$baseUrl/playlist';
  static String get recentlyPlayed => '$baseUrl/recently-played';

  static String search(String query, {String filter = 'music_songs'}) =>
      '$baseUrl/music/search?q=${Uri.encodeComponent(query)}&filter=$filter';

  static String recommendations(String videoIds) =>
      '$baseUrl/music/recommendations?videoIds=$videoIds';
  static String get quickPicks => '$baseUrl/music/quick-picks';
  static String personalizedPicks(String videoIds) =>
      '$baseUrl/music/personalized-picks?videoIds=$videoIds';

  static String details(String videoId) =>
      '$baseUrl/music/details/$videoId';

  static String related(String videoId) =>
      '$baseUrl/music/related/$videoId';

  static String playlistById(String id) => '$baseUrl/playlist/$id';

  static String playlistSongs(String playlistId) =>
      '$baseUrl/playlist/$playlistId/songs';

  static String playlistSong(String playlistId, String songId) =>
      '$baseUrl/playlist/$playlistId/songs/$songId';

  static const List<String> pipedInstances = [
    'https://pipedapi.kavin.rocks',
    'https://piped-api.garudalinux.org',
    'https://api.piped.projectsegfau.lt',
  ];

  static String pipedStreams(String videoId) =>
      '/streams/$videoId';
}
