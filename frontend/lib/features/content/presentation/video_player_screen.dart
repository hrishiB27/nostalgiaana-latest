import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    ref.read(videoPlayerProvider.notifier).play(
          widget.streamUrl,
          contentId: widget.contentId,
          title: widget.title,
        );
  }

  @override
  void dispose() {
    ref.read(videoPlayerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(videoPlayerProvider.notifier).controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: Video(controller: controller),
      ),
    );
  }
}
