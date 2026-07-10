import 'package:flutter/material.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/widgets/auth_form_card.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_secondary_button.dart';
import '../widgets/footer_legal_text.dart';
import '../widgets/golden_record_corner.dart';
import '../widgets/retro_doodle_background.dart';
import '../widgets/section_divider.dart';
import '../widgets/trust_strip.dart';
import '../widgets/vintage_illustration_row.dart';
import '../widgets/vintage_logo_badge.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

/// The redesigned auth landing screen from `sampleUI.png` — replaces
/// `RoleSelectionScreen` as the destination `SplashScreen` navigates to.
/// Uses the app's single global theme (`AppTheme.theme` in `main.dart`)
/// like every other screen — no local theme override needed.
class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RetroDoodleBackground(
        child: Stack(
          children: [
            const GoldenRecordCorner(radius: 125.0),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const VintageLogoBadge(),
                    const SizedBox(height: 28),
                    Text(
                      'Unlock the magic of',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'Retro Hindi Film Music',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    const SampleUiSectionDivider(),
                    const SizedBox(height: 14),
                    Text(
                      'Choose your journey below:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    AuthFormCard(
                      maxWidth: 420,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthPrimaryButton(
                            label: 'Create Account',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateAccountScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AuthSecondaryButton(
                            label: 'Login',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!AppBreakpoints.isDesktop(context)) ...[
                      const SizedBox(height: 48),
                      const VintageIllustrationRow(),
                    ],
                    const SizedBox(height: 24),
                    const TrustStrip(),
                    const SizedBox(height: 24),
                    const FooterLegalText(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
