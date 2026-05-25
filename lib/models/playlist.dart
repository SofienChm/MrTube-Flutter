import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String? cover;
  final String userId;
  final List<Song> songs;
  final String createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.cover,
    required this.userId,
    this.songs = const [],
    required this.createdAt,
  });

  int get songCount => songs.length;

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cover: json['cover'] as String?,
      userId: json['userId'] as String? ?? '',
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}
