import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../core/constants/app_colors.dart';


class SongCardWidget extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongCardWidget({super.key, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: song.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, __) => Container(color: AppColors.surface),
                      errorWidget: (_, __, ___) => Container(color: AppColors.surface, child: const Icon(Icons.music_note, color: AppColors.textSecondary)),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          song.durationFormatted,
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              song.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
