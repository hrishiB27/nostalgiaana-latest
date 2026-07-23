import 'package:flutter/material.dart';

import '../../../content/presentation/widgets/now_playing_bar.dart';
import 'comment_input_box.dart';

/// Combines the comment input with the persistent mini-player into a single
/// `bottomNavigationBar` — a `Scaffold` only has one such slot, and
/// `NowPlayingBar` already collapses to nothing when idle, so this bar
/// shrinks to just the input box when no track is playing.
class CommentsBottomBar extends StatelessWidget {
  const CommentsBottomBar({super.key, required this.contentId, required this.accent});

  final String contentId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommentInputBox(contentId: contentId, accent: accent),
        const NowPlayingBar(),
      ],
    );
  }
}
