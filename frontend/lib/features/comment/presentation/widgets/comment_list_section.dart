import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../application/comments_notifier.dart';
import '../../application/comments_state.dart';
import 'comment_row.dart';
import 'comments_empty_state.dart';

class CommentListSection extends ConsumerWidget {
  const CommentListSection({super.key, required this.contentId, required this.accent});

  final String contentId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsProvider(contentId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        switch (state.status) {
          CommentsStatus.initial || CommentsStatus.loading => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: accent),
                ),
              ),
            ),
          CommentsStatus.error => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.errorMessage ?? 'Something went wrong. Please try again.',
                      style: const TextStyle(color: AppColors.crimson),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(commentsProvider(contentId).notifier).load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          CommentsStatus.loaded when state.items.isEmpty => const CommentsEmptyState(),
          CommentsStatus.loaded => Column(
              children: [
                for (final comment in state.items) ...[
                  CommentRow(comment: comment),
                  if (comment != state.items.last) ...[
                    const SizedBox(height: 12),
                    Divider(color: AppColors.charcoal.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
        },
      ],
    );
  }
}
