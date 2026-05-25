import 'song.dart';

class SearchResult {
  final List<Song> songs;

  SearchResult({required this.songs});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
