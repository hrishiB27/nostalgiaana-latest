import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/config/theme_config.dart';

/// "By continuing, you agree to our Terms of Use and Privacy Policy" —
/// anchored near the bottom of the auth landing screen. No Terms/Privacy
/// screens exist yet, so the links just acknowledge the tap rather than
/// silently doing nothing.
class FooterLegalText extends StatelessWidget {
  const FooterLegalText({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(color: AppColors.charcoal, fontSize: 12);
    const linkStyle = TextStyle(
      color: AppColors.crimson,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Use',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _showComingSoon(context, 'Terms of Use'),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _showComingSoon(context, 'Privacy Policy'),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
