import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/config/theme_config.dart';

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
                    'assets/images/NostalgiaanaLogo.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
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
