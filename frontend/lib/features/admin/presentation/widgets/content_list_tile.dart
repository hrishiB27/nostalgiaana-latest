import 'package:flutter/material.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/widgets/tier_badge.dart';
import '../../data/models/content_detail_response_model.dart';

/// One row on the Manage Shows / Manage Audios listings. Shared because the
/// two screens display the identical shape (`ContentDetailResponseModel`)
/// — only the API calls behind upload/delete differ between them.
class ContentListTile extends StatelessWidget {
  const ContentListTile({super.key, required this.item, required this.onDelete});

  final ContentDetailResponseModel item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.panelCream,
        border: Border.all(color: AppColors.charcoal.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.coverUrl != null
                  ? Image.network(item.coverUrl!, fit: BoxFit.cover)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.teal.withValues(alpha: 0.35),
                            AppColors.crimson.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.graphic_eq, color: AppColors.charcoal, size: 24),
                      ),
                    ),
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
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isPremium) ...[
                      const SizedBox(width: 8),
                      const TierBadge(label: 'PREMIUM', color: AppColors.gold),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [item.categoryName, item.speaker].where((part) => part != null).join(' · ').isEmpty
                      ? 'Uncategorized'
                      : [item.categoryName, item.speaker].where((part) => part != null).join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.uploadedByName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded by ${item.uploadedByName}',
                    style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.45), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.crimson),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
