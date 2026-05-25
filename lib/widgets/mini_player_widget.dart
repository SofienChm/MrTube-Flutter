import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/audio_player_service.dart';
import '../core/constants/app_colors.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (_, player, __) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Container(
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CachedNetworkImage(
                    imageUrl: song.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.surface),
                    errorWidget: (_, __, ___) => Container(color: AppColors.surface, child: const Icon(Icons.music_note, size: 18, color: AppColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: player.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.textPrimary,
                      ),
                onPressed: () => player.togglePlay(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
                onPressed: () => player.next(),
              ),
            ],
          ),
        );
      },
    );
  }
}
