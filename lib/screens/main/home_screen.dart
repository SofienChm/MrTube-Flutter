import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/audio_player_service.dart';
import '../../models/song.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/song_card_widget.dart';
import '../../widgets/song_row_widget.dart';
import '../../widgets/skeleton_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  void _load() {
    final auth = context.read<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;
    context.read<HomeProvider>().loadData(isLoggedIn: isLoggedIn);
    if (!isLoggedIn) {
      auth.addListener(_onAuthChange);
    }
  }

  void _onAuthChange() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      auth.removeListener(_onAuthChange);
      context.read<HomeProvider>().loadData(isLoggedIn: true);
    }
  }

  Future<void> _onRefresh() async {
    final auth = context.read<AuthProvider>();
    await context.read<HomeProvider>().loadData(isLoggedIn: auth.isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MrTube'),
        actions: [
          Consumer<AuthProvider>(
            builder: (_, auth, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  (auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0] : 'U').toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (_, home, __) {
          if (home.isLoading && home.trending.isEmpty) {
            return _buildSkeleton();
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView(
              children: [
                if (home.recentlyPlayed.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Réécouter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: home.recentlyPlayed.length,
                      itemBuilder: (_, i) => SongRowWidget(
                        song: home.recentlyPlayed[i],
                        onTap: () => _playSong(context, home.recentlyPlayed, i),
                        compact: true,
                      ),
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text('Tendances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: home.trending.length,
                    itemBuilder: (_, i) => SongCardWidget(
                      song: home.trending[i],
                      onTap: () => _playSong(context, home.trending, i),
                    ),
                  ),
                ),
                if (home.recommendations.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text('Pour vous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: home.recommendations.length,
                      itemBuilder: (_, i) => SongCardWidget(
                        song: home.recommendations[i],
                        onTap: () => _playSong(context, home.recommendations, i),
                      ),
                    ),
                  ),
                ],
                if (home.quickPicks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text('Sélection rapide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: home.quickPicks.length,
                      itemBuilder: (_, i) => SongCardWidget(
                        song: home.quickPicks[i],
                        onTap: () => _playSong(context, home.quickPicks, i),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  void _playSong(BuildContext context, List<Song> songs, int index) {
    context.read<AudioPlayerService>().setQueue(songs, index);
  }

  Widget _buildSkeleton() {
    return ListView(
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonWidget(width: double.infinity, height: 20),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonWidget(width: 200, height: 50),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonWidget(width: double.infinity, height: 20),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonWidget(width: 140, height: 200),
            ),
          ),
        ),
        // Quick picks skeleton
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonWidget(width: double.infinity, height: 20),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SkeletonWidget(width: 140, height: 200),
            ),
          ),
        ),
      ],
    );
  }
}
