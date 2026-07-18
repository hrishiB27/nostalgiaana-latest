import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/layout/adaptive_content_wrapper.dart';
import '../../../core/layout/adaptive_list_grid.dart';
import '../../../core/widgets/tier_badge.dart';
import '../application/admin_users_notifier.dart';
import '../data/models/admin_user_response_model.dart';
import 'widgets/admin_error_view.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminUsersProvider.notifier).load());
  }

  Future<void> _confirmSuspend(AdminUserResponseModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend account?'),
        content: Text(
          '${user.displayName} will lose access immediately. '
          'This does not delete their account or data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.crimson),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminUsersProvider.notifier).banUser(user.id);
    }
  }

  Widget _buildBody(AdminUsersState state) {
    if (state.users.isEmpty) {
      if (state.status == AdminUsersStatus.error) {
        return AdminErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref.read(adminUsersProvider.notifier).load(),
        );
      }
      if (state.status == AdminUsersStatus.loaded) {
        return const Center(
          child: Text(
            'No users yet.',
            style: TextStyle(color: AppColors.charcoal),
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    return AdaptiveListGrid(
      // Bottom clearance matches manage_shows/audios_screen's FAB-safe
      // padding, so the last row doesn't sit flush against a bottom
      // gesture bar/home indicator on devices without a FAB here.
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return _UserRow(
          user: user,
          onSuspend: () => _confirmSuspend(user),
          onApprove: () => ref.read(adminUsersProvider.notifier).approveUser(user.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Manage Users')) : null,
      body: AdaptiveContentWrapper(child: _buildBody(state)),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onSuspend, required this.onApprove});

  final AdminUserResponseModel user;
  final VoidCallback onSuspend;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final isPremium = user.membershipTier == 'PREMIUM';
    final tierColor = isPremium ? AppColors.gold : AppColors.teal;

    return Opacity(
      opacity: user.isActive ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.panelCream,
          border: Border.all(
            color: user.approved ? AppColors.charcoal.withValues(alpha: 0.08) : AppColors.crimson,
            width: user.approved ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: tierColor.withValues(alpha: 0.18),
              child: Text(
                user.displayName[0].toUpperCase(),
                style: TextStyle(color: tierColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TierBadge(
                        label: isPremium ? 'PREMIUM' : 'STANDARD',
                        color: tierColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone ?? '—',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!user.approved) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'PENDING APPROVAL',
                      style: TextStyle(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                  if (!user.isActive) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'SUSPENDED',
                      style: TextStyle(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!user.approved)
              IconButton(
                onPressed: onApprove,
                icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.crimson),
                tooltip: 'Approve account',
              ),
            if (user.isActive)
              IconButton(
                onPressed: onSuspend,
                icon: const Icon(Icons.block, color: AppColors.crimson),
                tooltip: 'Suspend account',
              ),
          ],
        ),
      ),
    );
  }
}
