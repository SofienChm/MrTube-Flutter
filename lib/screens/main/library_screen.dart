import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/playlist_row_widget.dart';
import '../auth/login_screen.dart';
import '../playlist/playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<LibraryProvider>().loadPlaylists();
      }
    });
  }

  void _createPlaylist() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Nouvelle playlist', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nom de la playlist'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<LibraryProvider>().createPlaylist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createPlaylist,
            ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (_, lib, __) {
          if (!auth.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_music_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Connectez-vous pour voir', style: TextStyle(color: AppColors.textSecondary)),
                  const Text('vos playlists', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            );
          }

          if (lib.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (lib.playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_add, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Aucune playlist', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createPlaylist,
                    child: const Text('Créer une playlist'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => lib.loadPlaylists(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lib.playlists.length,
              itemBuilder: (_, i) {
                final playlist = lib.playlists[i];
                return Dismissible(
                  key: Key(playlist.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => lib.deletePlaylist(playlist.id),
                  child: PlaylistRowWidget(
                    playlist: playlist,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlistId: playlist.id, playlistName: playlist.name),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
