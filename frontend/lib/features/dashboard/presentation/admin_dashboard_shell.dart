import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/presentation/role_selection_screen.dart';

/// Placeholder management shell an ADMIN lands on after OTP verification.
/// Panels are static for now — wiring "Manage Shows"/"Manage Audios" to
/// `/api/admin/shows` and "Manage Users" to `/api/admin/users` is a
/// follow-up once the actual management screens are designed.
class AdminDashboardShell extends ConsumerWidget {
  const AdminDashboardShell({super.key});

  static const _panels = [
    (title: 'Manage Shows', icon: Icons.podcasts, accent: AppColors.crimson),
    (title: 'Manage Audios', icon: Icons.audiotrack, accent: AppColors.teal),
    (title: 'Manage Users', icon: Icons.people_alt, accent: AppColors.gold),
  ];

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
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
            icon: const Icon(Icons.logout, color: AppColors.offWhite),
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
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${panel.title} is coming soon')),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.05),
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
                          'Coming soon',
                          style: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.offWhite.withValues(alpha: 0.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
