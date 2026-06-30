import 'package:flutter/material.dart';

class GoldenRecordCorner extends StatelessWidget {
  /// The radius of the full circular record disc.
  /// Only the bottom-right quadrant (1/4th) of this circle will overlap onto the screen.
  final double radius;

  const GoldenRecordCorner({super.key, this.radius = 120.0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -radius,
      left: -radius,
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CustomPaint(painter: _GoldenRecordPainter()),
      ),
    );
  }
}

class _GoldenRecordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Metallic gold sweep gradient to simulate realistic vinyl reflections
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFD4AF37), // Classic Metallic Gold
          Color(0xFFF3E5AB), // Light Vanilla Gold Highlight
          Color(0xFF996515), // Deep Amber/Dark Gold
          Color(0xFFD4AF37),
          Color(0xFFFFF09F), // Sparkling Gold Highlight
          Color(0xFF996515),
          Color(0xFFD4AF37),
        ],
        stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // 1. Draw the primary golden vinyl base disc
    canvas.drawCircle(center, radius, paint);

    final groovePaint = Paint()
      ..color =
          const Color(0x3A5C4033) // Subtle dark gold/brown groove tint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw realistic concentric grooves
    for (double r = radius * 0.35; r < radius * 0.95; r += 6.0) {
      // Skips a few lines occasionally to simulate separate song/track gaps
      if ((r - (radius * 0.55)).abs() < 4.0 ||
          (r - (radius * 0.75)).abs() < 4.0) {
        continue;
      }
      canvas.drawCircle(center, r, groovePaint);
    }

    // 2. Draw the record's central paper label (Crimson to match the Retro Theme)
    final labelPaint = Paint()
      ..color =
          const Color(0xFFC62828) // Nostalgiaana Crimson Red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.28, labelPaint);

    // 3. Draw a tiny gold highlight ring around the center spindle hole
    final goldRingPaint = Paint()
      ..color = const Color(0xFFFFF09F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.08, goldRingPaint);

    // 4. Draw the actual dark center spindle hole
    final spindleHolePaint = Paint()
      ..color =
          const Color(0xFF2D1D18) // Matching default deep text color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.07, spindleHolePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
