import 'package:flutter/material.dart';

import '../../core/config/theme_config.dart';

/// The rounded #FDF5EC strip below the vintage illustrations, split into
/// three equal columns: Secure & Private / Curated with Love / For True
/// Music Lovers, each with a simple outline icon.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  static const _items = [
    (icon: Icons.shield_outlined, label: 'Secure &\nPrivate'),
    (icon: Icons.favorite_outline, label: 'Curated with\nLove'),
    (icon: Icons.star_outline, label: 'For True\nMusic Lovers'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.panelCream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final item in _items)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: AppColors.crimson, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.charcoal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
