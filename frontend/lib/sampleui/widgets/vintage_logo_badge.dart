import 'package:flutter/material.dart';

import '../../core/config/theme_config.dart';
import '../../core/widgets/nostalgiaana_brand_text.dart';

/// The circular logo badge at the top of the auth landing screen: the
/// real Nostalgiaana logo artwork framed by a crimson/teal ring, with the
/// "Nostalgiaana" wordmark and a script tagline below.
class VintageLogoBadge extends StatelessWidget {
  const VintageLogoBadge({super.key, this.diameter = 160});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.teal, width: 1.6),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(diameter * 0.04),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/newLogo_badge.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: diameter * 0.06),
        NostalgiaanaBrandText(
          style: TextStyle(
            fontSize: diameter * 0.16,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text('Where Memories Matter', style: AppTheme.taglineStyle),
      ],
    );
  }
}
