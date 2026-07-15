import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'video_player_notifier.dart';

/// `title`/`contentId` are null when nothing has ever been loaded — that's
/// the only time the Now Playing bar should stay hidden.
class AudioPlayerState {
  const AudioPlayerState({
    this.contentId,
    this.title,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration,
  });

  final String? contentId;
  final String? title;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration? duration;

  bool get hasActiveTrack => contentId != null;

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      contentId: contentId,
      title: title,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Single app-wide audio session backing the Now Playing bar. Wraps one
/// [AudioPlayer] instance and forwards its streams into Riverpod state so
/// any screen can watch playback without holding a reference to the player
/// itself.
class AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  late final AudioPlayer _player;

  static const _skipAmount = Duration(seconds: 10);

  @override
  AudioPlayerState build() {
    _player = AudioPlayer();

    final playerStateSub = _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isBuffering: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );
    });
    final positionSub = _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    final durationSub = _player.durationStream.listen((duration) {
      if (duration != null) state = state.copyWith(duration: duration);
    });

    ref.onDispose(() {
      playerStateSub.cancel();
      positionSub.cancel();
      durationSub.cancel();
      _player.dispose();
    });

    return const AudioPlayerState();
  }

  Future<void> play(String url, {required String contentId, required String title}) async {
    if (ref.read(videoPlayerProvider).isPlaying) {
      await ref.read(videoPlayerProvider.notifier).pause();
    }
    state = AudioPlayerState(contentId: contentId, title: title, isBuffering: true);
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> togglePlayPause() {
    return _player.playing ? _player.pause() : _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipBackward() {
    final target = _player.position - _skipAmount;
    return _player.seek(target.isNegative ? Duration.zero : target);
  }

  Future<void> skipForward() {
    final duration = _player.duration;
    final target = _player.position + _skipAmount;
    return _player.seek(duration != null && target > duration ? duration : target);
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AudioPlayerState();
  }
}

final audioPlayerProvider = NotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
  AudioPlayerNotifier.new,
);
