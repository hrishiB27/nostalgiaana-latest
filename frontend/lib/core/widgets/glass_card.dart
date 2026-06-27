import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass container shared by the role-selection panels and the auth
/// card. [borderColor] tints both the border and an outer glow to match
/// whichever accent (red/teal) the surrounding screen is using.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.blurSigma = 18,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: borderColor?.withValues(alpha: 0.5) ?? Colors.white.withValues(alpha: 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              if (borderColor != null)
                BoxShadow(
                  color: borderColor!.withValues(alpha: 0.18),
                  blurRadius: 30,
                  spreadRadius: -4,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
