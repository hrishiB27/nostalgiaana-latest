import 'package:flutter/material.dart';

/// Small high-contrast pill used to mark Premium vs Standard — for a user's
/// membership tier on Manage Users, a content item's premium flag on
/// Manage Shows/Audios, and the listener-facing content detail screen.
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
      ),
    );
  }
}
