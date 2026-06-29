import 'package:flutter/material.dart';

import '../../../../core/config/theme_config.dart';

/// Full-body error state shared by the admin list screens (Users, Shows,
/// Audios) — shown only when a list failed to load with nothing cached to
/// fall back on.
class AdminErrorView extends StatelessWidget {
  const AdminErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.offWhite)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
