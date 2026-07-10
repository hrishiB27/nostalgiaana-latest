import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// Desktop-only centered "card" wrapper for the sampleui auth screens. Below
/// `AppBreakpoints.desktop`, returns [child] completely unmodified — mobile
/// renders pixel-identical to today. On desktop, centers [child] inside a
/// width-capped, padded, rounded panel that reads as a card slightly darker
/// than the page background.
///
/// The darker shade is computed from `Theme.of(context).scaffoldBackgroundColor`
/// rather than a new named color constant, so it tracks the theme
/// automatically — `alpha: 0.06` was picked to land at roughly the same
/// darkening magnitude as the existing `AppColors.headerBeige` panel color
/// without introducing a second hardcoded hex value.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.child,
    required this.maxWidth,
    this.padding = const EdgeInsets.all(32),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!AppBreakpoints.isDesktop(context)) return child;

    final cardColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.06),
      Theme.of(context).scaffoldBackgroundColor,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}
