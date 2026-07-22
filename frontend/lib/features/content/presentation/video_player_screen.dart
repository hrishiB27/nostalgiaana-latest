import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../application/video_player_notifier.dart';

/// Full-screen video playback — unlike audio (which plays via the
/// persistent Now Playing bar across screens), video gets its own
/// dedicated route and stops when the user navigates away.
///
/// Starts in portrait (video shown in a 16:9 box, like YouTube's embedded
/// player) and only rotates to landscape/immersive when the user taps the
/// fullscreen button — it never auto-rotates on its own.
class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.contentId,
    required this.title,
  });

  final String streamUrl;
  final String contentId;
  final String title;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(videoPlayerProvider.notifier)
        .play(
          widget.streamUrl,
          contentId: widget.contentId,
          title: widget.title,
        );
    // Explicit portrait lock (not just "leave orientation alone") so the
    // screen can't be opened mid-landscape from a rotated device — matches
    // "start in portrait mode by default" exactly.
    if (_isMobile) _setPortraitOrientation();
  }

  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _toggleFullscreen() {
    final enteringFullscreen = !_isFullscreen;
    setState(() => _isFullscreen = enteringFullscreen);
    if (!_isMobile) return;
    if (enteringFullscreen) {
      _setLandscapeOrientation();
    } else {
      // Restored immediately here, not left to dispose() alone — this is
      // the fix for the bug where exiting fullscreen left the whole app
      // stuck in a distorted landscape layout.
      _setPortraitOrientation();
    }
  }

  @override
  void dispose() {
    ref.read(videoPlayerProvider.notifier).stop();
    // Final safety net in case the screen is torn down some other way —
    // harmless no-op if already restored by _toggleFullscreen/PopScope.
    if (_isMobile) _setPortraitOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(videoPlayerProvider.notifier);
    final controller = notifier.controller;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Back while fullscreen exits fullscreen first (same as YouTube) —
        // guarantees the orientation restore always happens on the way
        // out, rather than a stray back-press leaving the screen (and the
        // whole app) stuck in landscape.
        if (_isFullscreen) {
          _toggleFullscreen();
          return;
        }
        if (_isMobile) _setPortraitOrientation();
        // Await the stop completing before actually leaving the screen —
        // dispose() can't be async, so relying on it alone lets the async
        // native stop command race against the Video widget/texture being
        // torn down, which is how audio was surviving navigation away.
        await ref.read(videoPlayerProvider.notifier).stop();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullscreen
            ? null
            : AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
        body: _isFullscreen
            ? _VideoStack(
                controller: controller,
                notifier: notifier,
                isFullscreen: _isFullscreen,
                onToggleFullscreen: _toggleFullscreen,
              )
            : Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _VideoStack(
                    controller: controller,
                    notifier: notifier,
                    isFullscreen: _isFullscreen,
                    onToggleFullscreen: _toggleFullscreen,
                  ),
                ),
              ),
      ),
    );
  }
}

/// The video surface plus its overlaid controls (skip buttons, fullscreen
/// toggle) — shared between the portrait (boxed) and fullscreen (filled)
/// layouts so the two states can't drift out of sync.
class _VideoStack extends StatelessWidget {
  const _VideoStack({
    required this.controller,
    required this.notifier,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final VideoController controller;
  final VideoPlayerNotifier notifier;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Video(controller: controller)),
        // Flanking rewind/forward-10s buttons, YouTube-style — sit at
        // the screen's edges rather than the center so they don't
        // compete with media_kit's own tap-to-toggle center controls.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _VideoIconButton(icon: Icons.replay_10, onPressed: notifier.skipBackward),
                _VideoIconButton(icon: Icons.forward_10, onPressed: notifier.skipForward),
              ],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _VideoIconButton(
            icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            onPressed: onToggleFullscreen,
          ),
        ),
      ],
    );
  }
}

/// Circular translucent icon button laid over the video — sized and styled
/// to read clearly against arbitrary video frames regardless of content.
class _VideoIconButton extends StatelessWidget {
  const _VideoIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.4),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
