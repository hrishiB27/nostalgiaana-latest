import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'audio_player_notifier.dart';

/// `title`/`contentId` are null when nothing has ever been loaded.
class VideoPlayerState {
  const VideoPlayerState({
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

  VideoPlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
  }) {
    return VideoPlayerState(
      contentId: contentId,
      title: title,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Single app-wide video session, mirroring [AudioPlayerNotifier]'s shape.
/// Unlike audio there's no persistent mini-bar — [VideoPlayerScreen] plays
/// this and calls [stop] on exit — but the player still lives here (not
/// screen-local state) so its lifecycle is managed the same consistent way
/// as every other player in this app.
class VideoPlayerNotifier extends Notifier<VideoPlayerState> {
  late final Player _player;
  late final VideoController controller;

  @override
  VideoPlayerState build() {
    _player = Player();
    controller = VideoController(_player);

    final playingSub = _player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
    final bufferingSub = _player.stream.buffering.listen((buffering) {
      state = state.copyWith(isBuffering: buffering);
    });
    final positionSub = _player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });
    final durationSub = _player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    ref.onDispose(() {
      playingSub.cancel();
      bufferingSub.cancel();
      positionSub.cancel();
      durationSub.cancel();
      _player.dispose();
    });

    return const VideoPlayerState();
  }

  Future<void> play(String url, {required String contentId, required String title}) async {
    if (ref.read(audioPlayerProvider).isPlaying) {
      await ref.read(audioPlayerProvider.notifier).pause();
    }
    state = VideoPlayerState(contentId: contentId, title: title, isBuffering: true);
    await _player.open(Media(url));
  }

  Future<void> togglePlayPause() {
    return state.isPlaying ? _player.pause() : _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    state = const VideoPlayerState();
  }
}

final videoPlayerProvider = NotifierProvider<VideoPlayerNotifier, VideoPlayerState>(
  VideoPlayerNotifier.new,
);
