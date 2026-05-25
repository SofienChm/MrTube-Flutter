import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../services/audio_player_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/song.dart';
import '../../widgets/song_row_widget.dart';
import '../../widgets/skeleton_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final _filters = [
    {'label': 'Songs', 'value': 'music_songs'},
    {'label': 'Vidéos', 'value': 'music_videos'},
    {'label': 'Albums', 'value': 'music_albums'},
    {'label': 'Playlists', 'value': 'music_playlists'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            border: InputBorder.none,
            fillColor: AppColors.surface,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchProvider>().search('');
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          onChanged: (q) => context.read<SearchProvider>().search(q),
          onSubmitted: (q) => context.read<SearchProvider>().search(q),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (_, search, __) {
          if (search.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonWidget(width: double.infinity, height: 56),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final isActive = search.currentFilter == f['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f['label']!),
                          selected: isActive,
                          onSelected: (_) => search.setFilter(f['value']!),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: search.results.isEmpty
                    ? Center(
                        child: Text(
                          search.currentQuery.isEmpty
                              ? 'Recherchez un titre ou un artiste'
                              : 'Aucun résultat',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: search.results.length,
                        itemBuilder: (_, i) => SongRowWidget(
                          song: search.results[i],
                          onTap: () {
                            context.read<AudioPlayerService>().setQueue(search.results, i);
                          },
                          onLongPress: () => _showSongOptions(context, search.results[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: AppColors.textPrimary),
              title: const Text('Lecture', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AudioPlayerService>().setQueue([song], 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: AppColors.textPrimary),
              title: const Text('Ajouter à la file', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AudioPlayerService>().addToQueue(song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: AppColors.textPrimary),
              title: const Text('Ajouter à une playlist', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showPlaylistPicker(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.textPrimary),
              title: const Text('Partager', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showPlaylistPicker(BuildContext context, Song song) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Ajouter à une playlist', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Fonctionnalité à venir', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Fermer'),
        ),
      ],
    ),
  );
}
