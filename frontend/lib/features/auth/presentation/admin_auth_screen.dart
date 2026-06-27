import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../application/auth_notifier.dart';
import '../data/models/user_role.dart';
import '../domain/authenticated_user.dart';
import 'post_auth_router.dart';
import 'widgets/auth_phase_card.dart';

/// Same login/OTP flow as [UserAuthScreen] hitting the same `/api/auth/**`
/// endpoints — there's no separate backend admin login. The gate here is
/// client-side UX only: if OTP verification succeeds for a non-ADMIN
/// account, we don't trust the portal they happened to use, so we log them
/// straight back out instead of granting console access.
class AdminAuthScreen extends ConsumerWidget {
  const AdminAuthScreen({super.key});

  Future<void> _handleAuthenticated(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedUser user,
  ) async {
    if (user.role != UserRole.admin) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.charcoal,
          content: Text(
            'This account does not have admin access.',
            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }
    routeToDashboard(context, user);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AuthPhaseCard(
                accentColor: AppColors.teal,
                icon: Icons.equalizer,
                title: 'Admin Console',
                subtitle: 'Sign in with your administrator account',
                onAuthenticated: (user) => _handleAuthenticated(context, ref, user),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
