import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import '../models/song.dart';
import '../core/constants/api_endpoints.dart';
import '../core/storage/local_storage.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final LocalStorage _localStorage = LocalStorage();
  final ApiClient _apiClient = ApiClient();

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  PlaybackRepeatMode _repeatMode = PlaybackRepeatMode.none;
  double _volume = 0.8;

  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  PlaybackRepeatMode get repeatMode => _repeatMode;
  double get volume => _volume;

  StreamSubscription? _positionSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _processingSub;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    _positionSub = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _playingSub = _player.playingStream.listen((playing) {
      _isPlaying = playing;
      _isLoading = false;
      notifyListeners();
    });

    _processingSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onSongComplete();
      } else if (state == ProcessingState.buffering) {
        _isLoading = true;
        notifyListeners();
      } else if (state == ProcessingState.ready) {
        _isLoading = false;
        _duration = _player.duration ?? Duration.zero;
        notifyListeners();
      }
    });
  }

  void _onSongComplete() {
    if (_repeatMode == PlaybackRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }

    if (_isShuffle) {
      final next = _getShuffleIndex();
      if (next != -1) {
        play(_queue[next]);
        return;
      }
    }

    if (_currentIndex < _queue.length - 1) {
      play(_queue[_currentIndex + 1]);
    } else if (_repeatMode == PlaybackRepeatMode.all) {
      play(_queue[0]);
    } else {
      _isPlaying = false;
      notifyListeners();
    }
  }

  int _getShuffleIndex() {
    if (_queue.isEmpty) return -1;
    final random = DateTime.now().millisecondsSinceEpoch % _queue.length;
    if (random == _currentIndex && _queue.length > 1) {
      return (random + 1) % _queue.length;
    }
    return random;
  }

  Future<String?> _getAudioUrl(String videoId) async {
    if (kIsWeb) {
      return '${ApiEndpoints.baseUrl}/music/stream/$videoId';
    }

    for (final instance in ApiEndpoints.pipedInstances) {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));
        final response = await dio.get(
          '$instance${ApiEndpoints.pipedStreams(videoId)}',
        );
        final data = response.data as Map<String, dynamic>;
        final streams = data['audioStreams'] as List<dynamic>?;
        if (streams != null && streams.isNotEmpty) {
          String? bestUrl;
          int bestBitrate = 0;
          for (final stream in streams) {
            final bitrate = stream['bitrate'] as int? ?? 0;
            if (bitrate > bestBitrate) {
              bestBitrate = bitrate;
              bestUrl = stream['url'] as String?;
            }
          }
          if (bestUrl != null) return bestUrl;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<void> play(Song song) async {
    _currentSong = song;
    _currentIndex = _queue.indexWhere((s) => s.videoId == song.videoId);
    if (_currentIndex == -1) {
      _queue.add(song);
      _currentIndex = _queue.length - 1;
    }

    _isLoading = true;
    notifyListeners();

    final url = await _getAudioUrl(song.videoId);
    if (url == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: song.videoId,
          title: song.title,
          artist: song.artist,
          artUri: Uri.parse(song.thumbnail),
          duration: Duration(seconds: song.duration),
        ),
      ),
    );
    await _player.play();

    _saveToRecentlyPlayed(song);
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> next() async {
    if (_isShuffle) {
      final idx = _getShuffleIndex();
      if (idx != -1) play(_queue[idx]);
    } else if (_currentIndex < _queue.length - 1) {
      play(_queue[_currentIndex + 1]);
    } else if (_repeatMode == PlaybackRepeatMode.all) {
      play(_queue[0]);
    }
  }

  Future<void> previous() async {
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_currentIndex > 0) {
      play(_queue[_currentIndex - 1]);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void setVolume(double volume) {
    _volume = volume;
    _player.setVolume(volume);
    notifyListeners();
  }

  void setQueue(List<Song> songs, int startIndex) {
    _queue = List.from(songs);
    _currentIndex = startIndex;
    if (songs.isNotEmpty && startIndex >= 0 && startIndex < songs.length) {
      play(songs[startIndex]);
    }
  }

  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex) {
      _currentSong = _queue.isNotEmpty ? _queue[_currentIndex.clamp(0, _queue.length - 1)] : null;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void cyclePlaybackRepeatMode() {
    const modes = [PlaybackRepeatMode.none, PlaybackRepeatMode.one, PlaybackRepeatMode.all];
    final idx = modes.indexOf(_repeatMode);
    _repeatMode = modes[(idx + 1) % modes.length];
    notifyListeners();
  }

  void _saveToRecentlyPlayed(Song song) async {
    await _localStorage.saveRecentlyPlayed(song);
    try {
      final token = await _getToken();
      if (token != null) {
        _apiClient.setToken(token);
        await _apiClient.post(ApiEndpoints.recentlyPlayed, body: {
          'videoId': song.videoId,
          'title': song.title,
          'artist': song.artist,
          'thumbnail': song.thumbnail,
          'duration': song.duration,
        });
      }
    } catch (_) {}
  }

  Future<String?> _getToken() async {
    final storage = SecureStorage();
    return await storage.getToken();
  }

  String formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _processingSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

enum PlaybackRepeatMode { none, one, all }
