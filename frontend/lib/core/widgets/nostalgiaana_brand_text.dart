import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme_config.dart';

/// Renders the "Nostalgiaana" brand wordmark with its signature colour split:
///
///   Nostalg  – crimson (AppColors.crimson)
///   i        – crimson body, teal/cyan tittle (the dot above)
///   aa       – gold/yellow (AppColors.gold)
///   na       – teal/cyan (AppColors.teal)
///
/// Pass [style] for size and weight control — only [fontSize] and [fontWeight]
/// are read; colour is managed internally. The font family is always
/// Playfair Display to match the app's heading typescale.
///
/// Usage:
///   NostalgiaanaBrandText(style: Theme.of(context).textTheme.headlineMedium!)
///   NostalgiaanaBrandText(style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))
class NostalgiaanaBrandText extends StatelessWidget {
  const NostalgiaanaBrandText({
    super.key,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  final TextStyle style;
  final TextAlign textAlign;

  TextStyle _s(Color color) => GoogleFonts.playfairDisplay(
        color: color,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Nostalg', style: _s(AppColors.crimson)),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _BrandI(style: _s(AppColors.crimson)),
          ),
          TextSpan(text: 'aa', style: _s(AppColors.gold)),
          TextSpan(text: 'na', style: _s(AppColors.teal)),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// The letter "i" rendered with a crimson body (dotless ı, U+0131) and a
/// separate teal/cyan dot painted above it. The dot's vertical position is
/// calculated from the font size so it scales correctly at any text size.
class _BrandI extends StatelessWidget {
  const _BrandI({required this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final fs = style.fontSize ?? 20.0;
    final dotSize = (fs * 0.13).clamp(2.0, 14.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dotless i — same glyph as "i" but without the tittle, so our
        // custom cyan dot is the only dot visible.
        Text('ı', style: style),
        // Cyan tittle: positioned in the ascender zone above the ı glyph.
        // top: 0.20 * fs places the dot at ~0.73 * fs above the baseline,
        // which matches Playfair Display's tittle height.
        Positioned(
          top: fs * 0.20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
