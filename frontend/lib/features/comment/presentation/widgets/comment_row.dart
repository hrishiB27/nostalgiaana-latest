import 'package:flutter/material.dart';

import '../../../../core/config/theme_config.dart';
import '../../data/models/comment_model.dart';

class CommentRow extends StatelessWidget {
  const CommentRow({super.key, required this.comment});

  final CommentModel comment;

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              comment.authorName,
              style: const TextStyle(color: AppColors.charcoal, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(_relativeTime(comment.createdAt), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(comment.text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
