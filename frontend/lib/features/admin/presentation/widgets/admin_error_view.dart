import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../../auth/application/auth_state.dart';

/// Full-body error state shared by the admin list screens (Users, Shows,
/// Audios) — shown only when a list failed to load with nothing cached to
/// fall back on.
class AdminErrorView extends ConsumerWidget {
  const AdminErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authNotifierProvider).status;
    // A list load can transiently 401 in the same frame the admin
    // dashboard is pushed right after login, before the dio interceptor's
    // retry (see dio_client.dart) has resolved — show a spinner rather
    // than the real error + Retry button while auth is still settling.
    if (authStatus == AuthStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.charcoal)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
