import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_player_service.dart';
import 'services/audio_handler.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/search_provider.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/playlist_detail_provider.dart';
import 'core/constants/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioService = AudioPlayerService();
  MrTubeAudioHandler? audioHandler;

  if (!kIsWeb) {
    audioHandler = MrTubeAudioHandler(audioService);
    await AudioService.init(
      builder: () => audioHandler!,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mrtube.audio',
        androidNotificationChannelName: 'MrTube',
        androidNotificationOngoing: true,
      ),
    );
  }

  runApp(MrTubeApp(audioService: audioService, audioHandler: audioHandler));
}

class MrTubeApp extends StatefulWidget {
  final AudioPlayerService audioService;
  final MrTubeAudioHandler? audioHandler;

  const MrTubeApp({
    super.key,
    required this.audioService,
    this.audioHandler,
  });

  @override
  State<MrTubeApp> createState() => _MrTubeAppState();
}

class _MrTubeAppState extends State<MrTubeApp> {
  late final _audioService = widget.audioService;
  final _authProvider = AuthProvider();
  final _homeProvider = HomeProvider();
  final _searchProvider = SearchProvider();
  final _playerProvider = PlayerProvider();
  final _libraryProvider = LibraryProvider();
  final _playlistDetailProvider = PlaylistDetailProvider();

  @override
  void initState() {
    super.initState();
    _authProvider.tryAutoLogin();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _authProvider.dispose();
    _homeProvider.dispose();
    _searchProvider.dispose();
    _playerProvider.dispose();
    _libraryProvider.dispose();
    _playlistDetailProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _audioService),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _homeProvider),
        ChangeNotifierProvider.value(value: _searchProvider),
        ChangeNotifierProvider.value(value: _playerProvider),
        ChangeNotifierProvider.value(value: _libraryProvider),
        ChangeNotifierProvider.value(value: _playlistDetailProvider),
      ],
      child: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          return MaterialApp(
            title: 'MrTube',
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: auth.isLoggedIn
                ? const MainTabScreen()
                : const LoginScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}
