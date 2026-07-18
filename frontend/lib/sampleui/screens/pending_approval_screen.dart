import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme_config.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/retro_doodle_background.dart';
import 'auth_landing_screen.dart';

/// Landed on right after a successful signup instead of the user dashboard
/// — every fresh signup defaults to `approved=false` on the backend, so
/// there's no case where skipping this screen would be correct. Reached via
/// `pushAndRemoveUntil` from `create_account_screen.dart`, so there's
/// nothing left in the stack for the hardware back button to return to.
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  Future<void> _backToLogin(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RetroDoodleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AuthFormCard(
                maxWidth: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: AppColors.gold,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Almost there!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thank you for registering, your account is waiting to be approved',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: 'Back to Login',
                      onPressed: () => _backToLogin(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
