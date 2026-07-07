import 'package:flutter/material.dart';

/// The vintage illustration row: a high-fidelity retro collage image
/// sourced from `new_retro_collage.jpeg`.
///
/// The image is wrapped in a [ShaderMask] with a horizontal linear gradient
/// (transparent → opaque → opaque → transparent, BlendMode.dstIn) so the
/// left and right edges dissolve into the cream background rather than
/// showing a hard border.
class VintageIllustrationRow extends StatelessWidget {
  const VintageIllustrationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: 180.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0.0, 0.12, 0.88, 1.0],
        ).createShader(bounds),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.12, 0.88, 1.0],
          ).createShader(bounds),
          child: Image.asset(
            'assets/images/new_retro_collage.jpeg',
            height: 180.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
