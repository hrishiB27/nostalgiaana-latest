import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/config/theme_config.dart';

/// The circular logo badge at the top of the auth landing screen: a
/// crimson/teal ring around a vinyl-disc + music-note + lightning-bolt
/// composite, with the "Nostalgiaana" wordmark and a script tagline below.
/// No logo art asset exists for this badge, so it's built entirely from
/// stock Material icons and styled text rather than redrawn artwork — a
/// color/style homage to the mockup, not a pixel-accurate recreation.
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.crimson, width: 3),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(diameter * 0.05),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.teal, width: 1.6),
                  ),
                ),
              ),
              Icon(Icons.album, size: diameter * 0.34, color: AppColors.charcoal),
              Positioned(
                top: diameter * 0.16,
                left: diameter * 0.2,
                child: Icon(Icons.music_note, size: diameter * 0.22, color: AppColors.teal),
              ),
              Positioned(
                top: diameter * 0.06,
                left: diameter * 0.04,
                child: Icon(Icons.bolt, size: diameter * 0.16, color: AppColors.gold),
              ),
              Positioned(
                top: diameter * 0.06,
                right: diameter * 0.04,
                child: Icon(Icons.bolt, size: diameter * 0.16, color: AppColors.gold),
              ),
            ],
          ),
        ),
        SizedBox(height: diameter * 0.06),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Nostalgi',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.w700,
                  fontSize: diameter * 0.16,
                ),
              ),
              TextSpan(
                text: 'aa',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.crimson,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  fontSize: diameter * 0.16,
                ),
              ),
              TextSpan(
                text: 'na',
                style: GoogleFonts.playfairDisplay(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  fontSize: diameter * 0.16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text('Where Memories Matter', style: AppTheme.taglineStyle),
      ],
    );
  }
}
