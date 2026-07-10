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
    final controller = ref.read(videoPlayerProvider.notifier).controller;

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
        body: Center(child: Video(controller: controller)),
      ),
    );
  }
}
