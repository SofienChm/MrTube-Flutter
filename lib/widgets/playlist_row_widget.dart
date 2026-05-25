import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/playlist.dart';
import '../core/constants/app_colors.dart';

class PlaylistRowWidget extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const PlaylistRowWidget({super.key, required this.playlist, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 56,
                height: 56,
                child: playlist.cover != null
                    ? CachedNetworkImage(
                        imageUrl: playlist.cover!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.surface),
                        errorWidget: (_, __, ___) => Container(color: AppColors.surface, child: const Icon(Icons.playlist_play, color: AppColors.textSecondary)),
                      )
                    : Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.playlist_play, color: AppColors.textSecondary),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.songCount} titre${playlist.songCount > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
