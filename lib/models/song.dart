class Song {
  final String? id;
  final String videoId;
  final String title;
  final String artist;
  final String thumbnail;
  final int duration;
  final String durationFormatted;
  final int? views;
  final String? uploadedAt;

  Song({
    this.id,
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.duration,
    required this.durationFormatted,
    this.views,
    this.uploadedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String?,
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      durationFormatted: json['durationFormatted'] as String? ?? '0:00',
      views: json['views'] as int?,
      uploadedAt: json['uploadedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'thumbnail': thumbnail,
      'duration': duration,
      'durationFormatted': durationFormatted,
      if (views != null) 'views': views,
      if (uploadedAt != null) 'uploadedAt': uploadedAt,
    };
  }
}
