import 'package:flutter/material.dart';

import '../../core/config/theme_config.dart';

/// The vintage illustration row: gramophone, retro radio, a fanned stack of
/// vintage portrait cards, and a microphone, over soft pastel blob shapes.
/// No image assets exist for any of these — all stylized Flutter widgets
/// (icons, CustomPaint, composited shapes), not sourced photographs.
class VintageIllustrationRow extends StatelessWidget {
  const VintageIllustrationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(left: -30, bottom: -10, child: _blob(130, Colors.orange.withValues(alpha: 0.14))),
          Positioned(right: -20, bottom: 0, child: _blob(150, AppColors.teal.withValues(alpha: 0.12))),
          Positioned(left: 90, bottom: -30, child: _blob(110, Colors.pinkAccent.withValues(alpha: 0.10))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Gramophone(),
                _RetroRadio(),
                _PhotoStack(),
                Icon(Icons.mic, size: 56, color: AppColors.charcoal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _Gramophone extends StatelessWidget {
  const _Gramophone();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 50,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.brown.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            child: Icon(Icons.album, size: 32, color: AppColors.charcoal),
          ),
          const Positioned(
            top: 0,
            child: SizedBox(
              width: 60,
              height: 76,
              child: CustomPaint(painter: _GramophoneHornPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

/// The one element with no reasonable Material icon equivalent — a flared
/// horn cone, narrow where it meets the turntable stand, widening to a
/// bell opening at the top.
class _GramophoneHornPainter extends CustomPainter {
  const _GramophoneHornPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFC9A227)
      ..style = PaintingStyle.fill;
    final rim = Paint()
      ..color = const Color(0xFFE8C547)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width * 0.42, size.height)
      ..lineTo(size.width * 0.58, size.height)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.55, size.width, 0)
      ..lineTo(0, 0)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.55, size.width * 0.42, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, rim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RetroRadio extends StatelessWidget {
  const _RetroRadio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 46,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.charcoal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD7CCC8)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoStack extends StatelessWidget {
  const _PhotoStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(angle: -0.25, child: _photoCard()),
          Transform.rotate(angle: 0.0, child: _photoCard()),
          Transform.rotate(angle: 0.25, child: _photoCard()),
        ],
      ),
    );
  }

  Widget _photoCard() {
    return Container(
      width: 38,
      height: 52,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Icon(Icons.person, size: 18, color: Colors.brown.shade500),
      ),
    );
  }
}
