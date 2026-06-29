import 'package:flutter/material.dart';

import '../../core/config/theme_config.dart';

/// The small red-to-teal gradient line with a centered gold star, sitting
/// under the title on the auth landing screen.
class SampleUiSectionDivider extends StatelessWidget {
  const SampleUiSectionDivider({super.key, this.width = 160});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _gradientLine(beginColor: AppColors.crimson, endColor: AppColors.gold),
        const SizedBox(width: 8),
        const Icon(Icons.star, color: AppColors.gold, size: 14),
        const SizedBox(width: 8),
        _gradientLine(beginColor: AppColors.gold, endColor: AppColors.teal),
      ],
    );
  }

  Widget _gradientLine({required Color beginColor, required Color endColor}) {
    return Container(
      width: width / 2,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [beginColor, endColor]),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
