import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../sampleui/screens/auth_landing_screen.dart';
import '../../admin/presentation/manage_audios_screen.dart';
import '../../admin/presentation/manage_shows_screen.dart';
import '../../admin/presentation/manage_users_screen.dart';
import '../../auth/application/auth_notifier.dart';

/// Management shell an ADMIN lands on after OTP verification. "Manage
/// Shows"/"Manage Audios" still route to placeholder screens — wiring them
/// to `/api/admin/shows`/`/api/admin/audios` is a follow-up once the admin
/// content upload flow is built. "Manage Users" is fully wired to
/// `/api/admin/users`.
class AdminDashboardShell extends ConsumerWidget {
  const AdminDashboardShell({super.key});

  static const _panels = [
    (
      title: 'Manage Shows',
      subtitle: 'Coming soon',
      icon: Icons.podcasts,
      accent: AppColors.crimson,
    ),
    (
      title: 'Manage Audios',
      subtitle: 'Coming soon',
      icon: Icons.audiotrack,
      accent: AppColors.teal,
    ),
    (
      title: 'Manage Users',
      subtitle: 'View accounts, suspend access',
      icon: Icons.people_alt,
      accent: AppColors.gold,
    ),
  ];

  static const _destinations = [
    ManageShowsScreen(),
    ManageAudiosScreen(),
    ManageUsersScreen(),
  ];

  void _openPanel(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _destinations[index]),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
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
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout, color: AppColors.charcoal),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _panels.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final panel = _panels[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openPanel(context, index),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.panelCream,
                border: Border.all(color: panel.accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: panel.accent.withValues(alpha: 0.18),
                    child: Icon(panel.icon, color: panel.accent),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(panel.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          panel.subtitle,
                          style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.charcoal.withValues(alpha: 0.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
