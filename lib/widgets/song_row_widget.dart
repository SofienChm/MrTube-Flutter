import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../core/constants/app_colors.dart';

class SongRowWidget extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? index;
  final bool compact;

  const SongRowWidget({
    super.key,
    required this.song,
    this.onTap,
    this.onLongPress,
    this.index,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: SizedBox(
            width: 280,
            height: 48,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 40, height: 40,
                    child: CachedNetworkImage(
                      imageUrl: song.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surface),
                      errorWidget: (_, __, ___) => Container(color: AppColors.surface, child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(song.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(song.artist, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              if (index != null) ...[
                SizedBox(
                  width: 24,
                  child: Text(
                    '$index',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 48, height: 48,
                  child: CachedNetworkImage(
                    imageUrl: song.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.surface),
                    errorWidget: (_, __, ___) => Container(color: AppColors.surface, child: const Icon(Icons.music_note, color: AppColors.textSecondary, size: 20)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(song.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(song.artist, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(song.durationFormatted, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
