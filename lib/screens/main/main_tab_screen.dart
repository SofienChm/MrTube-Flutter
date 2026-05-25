import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio_player_service.dart';
import '../../widgets/mini_player_widget.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Consumer<AudioPlayerService>(
            builder: (_, player, __) {
              if (player.currentSong == null) return const SizedBox.shrink();
              return Positioned(
                bottom: 56,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  ),
                  child: const MiniPlayerWidget(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), activeIcon: Icon(Icons.library_music), label: 'Bibliothèque'),
        ],
      ),
    );
  }
}
