import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_service.dart';

class MrTubeAudioHandler extends BaseAudioHandler {
  final AudioPlayerService _service;

  MrTubeAudioHandler(this._service) {
    _service.player.playbackEventStream.listen(_onPlaybackEvent);
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    final playing = _service.player.playing;
    final current =
        _service.player.sequenceState?.currentSource?.tag as MediaItem?;

    if (current != null) {
      mediaItem.add(current);
    }

    playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: playing,
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
      ),
    );
  }

  @override
  Future<void> play() => _service.resume();

  @override
  Future<void> pause() => _service.pause();

  @override
  Future<void> skipToNext() => _service.next();

  @override
  Future<void> skipToPrevious() => _service.previous();

  @override
  Future<void> seek(Duration position) => _service.seekTo(position);

  @override
  Future<void> stop() => _service.pause();
}
