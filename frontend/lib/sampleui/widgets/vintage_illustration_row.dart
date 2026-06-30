import 'package:flutter/material.dart';

/// The vintage illustration row: a high-fidelity retro collage image
/// (gramophone, radio, photo stack, mic) sourced from `retro_collage.png`.
class VintageIllustrationRow extends StatelessWidget {
  const VintageIllustrationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: 140.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/retro_collage.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
