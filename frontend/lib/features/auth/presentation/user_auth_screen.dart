import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import 'post_auth_router.dart';
import 'widgets/auth_phase_card.dart';

/// Any role can authenticate here — once OTP verification succeeds,
/// [routeToDashboard] sends the user to the dashboard matching their
/// *actual* role, so an admin signing in from this screen still lands on
/// the admin console.
class UserAuthScreen extends StatelessWidget {
  const UserAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AuthPhaseCard(
                accentColor: AppColors.crimson,
                icon: Icons.album,
                title: 'Welcome back',
                subtitle: 'Sign in to keep the memories playing',
                allowSignUp: true,
                onAuthenticated: (user) => routeToDashboard(context, user),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
