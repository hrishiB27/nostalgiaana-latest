import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../application/video_player_notifier.dart';

/// Full-screen video playback — unlike audio (which plays via the
/// persistent Now Playing bar across screens), video gets its own
/// dedicated route and stops when the user navigates away.
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
    if (_isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    ref.read(videoPlayerProvider.notifier).stop();
    if (_isMobile) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
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
        // Await the stop completing before actually leaving the screen —
        // dispose() can't be async, so relying on it alone lets the async
        // native stop command race against the Video widget/texture being
        // torn down, which is how audio was surviving navigation away.
        await ref.read(videoPlayerProvider.notifier).stop();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: Video(controller: controller)),
            // Flanking rewind/forward-10s buttons, YouTube-style — sit at
            // the screen's edges rather than the center so they don't
            // compete with media_kit's own tap-to-toggle center controls.
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _VideoSkipButton(
                      icon: Icons.replay_10,
                      onPressed: notifier.skipBackward,
                    ),
                    _VideoSkipButton(
                      icon: Icons.forward_10,
                      onPressed: notifier.skipForward,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular translucent skip button laid over the video — sized and styled
/// to read clearly against arbitrary video frames regardless of content.
class _VideoSkipButton extends StatelessWidget {
  const _VideoSkipButton({required this.icon, required this.onPressed});

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
