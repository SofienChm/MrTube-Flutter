import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/audio_player_service.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/song.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/song_row_widget.dart';
import '../../widgets/skeleton_widget.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = context.read<AudioPlayerService>();
      if (player.currentSong != null) {
        context.read<PlayerProvider>().loadRelated(player.currentSong!.videoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final playerProvider = context.watch<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Aucune chanson en cours', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildDragHandle(),
            _buildHeader(context, player),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  _buildArtwork(song),
                  const SizedBox(height: 24),
                  _buildSongInfo(song, playerProvider),
                  const SizedBox(height: 16),
                  _buildProgress(player),
                  const SizedBox(height: 16),
                  _buildControls(player),
                  const SizedBox(height: 16),
                  _buildVolume(player),
                  const SizedBox(height: 16),
                  _buildBottomActions(context, player, song),
                  const SizedBox(height: 24),
                  _buildUpNext(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AudioPlayerService player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('En cours', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showOptions(context, player, player.currentSong!),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(Song song) {
    return AnimatedScale(
      scale: context.watch<AudioPlayerService>().isPlaying ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: song.thumbnail,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.card),
              errorWidget: (_, __, ___) => Container(color: AppColors.card, child: const Icon(Icons.music_note, color: AppColors.textSecondary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(Song song, PlayerProvider provider) {
    final liked = provider.isLiked(song.videoId);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(song.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(song.artist, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? AppColors.primary : AppColors.textSecondary),
          onPressed: () => provider.toggleLike(song.videoId),
        ),
      ],
    );
  }

  Widget _buildProgress(AudioPlayerService player) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            min: 0,
            max: player.duration.inSeconds.toDouble().clamp(1, double.infinity),
            value: player.position.inSeconds.toDouble().clamp(0, player.duration.inSeconds.toDouble()),
            onChanged: (v) => player.seekTo(Duration(seconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(player.formatTime(player.position), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(player.formatTime(player.duration), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(AudioPlayerService player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle, color: player.isShuffle ? AppColors.primary : AppColors.textSecondary),
          onPressed: () => player.toggleShuffle(),
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 32),
          onPressed: () => player.previous(),
        ),
        Consumer<AudioPlayerService>(
          builder: (_, p, __) => GestureDetector(
            onTap: () => p.togglePlay(),
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: p.isLoading
                  ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                  : Icon(p.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: AppColors.textPrimary, size: 32),
          onPressed: () => player.next(),
        ),
        IconButton(
          icon: Icon(Icons.repeat, color: player.repeatMode != RepeatMode.none ? AppColors.primary : AppColors.textSecondary),
          onPressed: () => player.cycleRepeatMode(),
        ),
      ],
    );
  }

  Widget _buildVolume(AudioPlayerService player) {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: AppColors.textSecondary, size: 18),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surface,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              min: 0,
              max: 1,
              value: player.volume,
              onChanged: (v) => player.setVolume(v),
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: AppColors.textSecondary, size: 18),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, AudioPlayerService player, Song song) {
    final provider = context.read<PlayerProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.playlist_add, color: AppColors.textSecondary),
          onPressed: () => _showAddToPlaylistSheet(context, song),
        ),
        IconButton(
          icon: const Icon(Icons.queue_music, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textSecondary),
          onPressed: () => provider.shareSong(song),
        ),
      ],
    );
  }

  Widget _buildUpNext(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À suivre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        if (playerProvider.isLoading)
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SkeletonWidget(width: double.infinity, height: 48),
          ))
        else if (playerProvider.related.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Aucune suggestion', style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...playerProvider.related.map((song) => SongRowWidget(
            song: song,
            onTap: () => context.read<AudioPlayerService>().setQueue(playerProvider.related, playerProvider.related.indexOf(song)),
          )),
      ],
    );
  }

  void _showOptions(BuildContext context, AudioPlayerService player, Song song) {
    final provider = context.read<PlayerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add, color: AppColors.textPrimary),
              title: const Text('Ajouter à une playlist', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddToPlaylistSheet(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.textPrimary),
              title: const Text('Partager', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                provider.shareSong(song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    final library = context.read<LibraryProvider>();
    library.loadPlaylists();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Ajouter à une playlist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Consumer<LibraryProvider>(
              builder: (_, lib, __) {
                if (lib.playlists.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucune playlist', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return Column(
                  children: lib.playlists.map((p) => ListTile(
                    leading: const Icon(Icons.playlist_play, color: AppColors.textPrimary),
                    title: Text(p.name, style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final ok = await context.read<PlayerProvider>().addToPlaylist(
                        p.id, song,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Ajouté à ${p.name}' : 'Erreur lors de l\'ajout'),
                            backgroundColor: ok ? AppColors.primary : Colors.red,
                          ),
                        );
                      }
                    },
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
