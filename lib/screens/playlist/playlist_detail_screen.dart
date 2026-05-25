import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/playlist_detail_provider.dart';
import '../../services/audio_player_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/song.dart';
import '../../widgets/song_row_widget.dart';
import '../../widgets/skeleton_widget.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistDetailProvider>().loadPlaylist(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName)),
      body: Consumer<PlaylistDetailProvider>(
        builder: (_, detail, __) {
          if (detail.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonWidget(width: double.infinity, height: 56),
              ),
            );
          }

          if (detail.songs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Playlist vide', style: TextStyle(color: AppColors.textSecondary)),
                  Text('Ajoutez des chansons depuis la recherche', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => detail.loadPlaylist(widget.playlistId),
            color: AppColors.primary,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _playAll(context, detail.songs, 0),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Tout lire'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _playAll(context, detail.songs, 0),
                          icon: const Icon(Icons.shuffle, size: 18),
                          label: const Text('Lecture aléatoire'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: detail.songs.length,
                    itemBuilder: (_, i) {
                      final song = detail.songs[i];
                      return Dismissible(
                        key: Key(song.videoId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => detail.removeSong(song.videoId),
                        child: SongRowWidget(
                          song: song,
                          index: i + 1,
                          onTap: () => _playAll(context, detail.songs, i),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _playAll(BuildContext context, List<Song> songs, int startIndex) {
    context.read<AudioPlayerService>().setQueue(songs, startIndex);
  }
}
