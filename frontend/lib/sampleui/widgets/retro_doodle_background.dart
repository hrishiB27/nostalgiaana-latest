import 'package:flutter/material.dart';

/// Full-bleed retro doodle wallpaper for the three auth entry-point screens
/// (landing, create-account, login). Painted as the bottom-most layer of a
/// [Stack] with [child] stacked directly on top, so every interactive
/// widget — text fields, buttons, images, plain text — stays fully
/// legible above the artwork. `BoxFit.cover` scales the doodle sheet to
/// completely fill the screen on any device size/orientation without
/// leaving gaps or introducing visible tile seams.
class RetroDoodleBackground extends StatelessWidget {
  const RetroDoodleBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/retro_doodle.png',
            fit: BoxFit.cover,
          ),
        ),
        // Also `Positioned.fill` (not a bare non-positioned child): with a
        // loose-constrained Stack, a non-positioned `SingleChildScrollView`
        // descendant shrink-wraps to its content height, which then shrinks
        // the whole Stack — and the doodle layer above — down to just the
        // content's height instead of the full screen.
        Positioned.fill(child: child),
      ],
    );
  }
}
