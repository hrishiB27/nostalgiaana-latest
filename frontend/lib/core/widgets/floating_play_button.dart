import 'dart:ui';

import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// Circular floating play action meant to sit *on top of* cover art (e.g.
/// the bottom-right corner of a `Stack`) rather than as a full-width text
/// button. Sizes itself off [AppBreakpoints] — 48dp on mobile widths, 56dp
/// on desktop widths — and grows 5% under the pointer on desktop/web via
/// [MouseRegion] + [AnimatedScale]; touch devices get a plain [InkWell]
/// ripple instead since there's no hover concept to animate.
///
/// [frosted] swaps the solid [color] fill for a blurred, semi-transparent
/// glass background (via [BackdropFilter]) — use it whenever the button is
/// layered directly over an image, so it stays legible regardless of the
/// artwork underneath instead of relying on one fixed accent color to
/// contrast with every possible cover.
class FloatingPlayButton extends StatefulWidget {
  const FloatingPlayButton({
    super.key,
    required this.onPressed,
    required this.color,
    this.isLoading = false,
    this.frosted = false,
  });

  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final bool frosted;

  @override
  State<FloatingPlayButton> createState() => _FloatingPlayButtonState();
}

class _FloatingPlayButtonState extends State<FloatingPlayButton> {
  bool _hovered = false;

  /// `Icons.play_arrow_rounded`'s glyph carries more visual weight on its
  /// left edge than its right (it's a triangle, not a symmetric shape), so
  /// dead-center placement reads as slightly left-of-center to the eye.
  /// Padding the icon on the left nudges its rendered position right by
  /// half that amount, which reads as mathematically centered instead.
  static const _iconNudge = 2.0;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final size = AppBreakpoints.isDesktop(context) ? 56.0 : 48.0;
    final fillColor = widget.frosted ? Colors.black.withValues(alpha: 0.38) : widget.color;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: _hovered ? 0.5 : 0.3),
            blurRadius: _hovered ? 18 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.isLoading ? null : widget.onPressed,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: _iconNudge),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: size * 0.56,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (widget.frosted) {
      button = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: button,
        ),
      );
    }

    return MouseRegion(
      cursor: widget.isLoading ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: button,
      ),
    );
  }
}
