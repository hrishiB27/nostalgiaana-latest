import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/data/models/user_role.dart';
import '../../payment/presentation/premium_upgrade_sheet.dart';
import 'audio_player_notifier.dart';
import '../data/listener_content_api.dart';
import '../data/models/content_response_model.dart';
import '../data/models/content_type.dart';
import '../presentation/video_player_screen.dart';

/// Shared "play" action for a piece of content: gates premium content
/// behind the upgrade sheet, then fetches a fresh presigned stream URL and
/// either starts the persistent audio player or pushes the full-screen
/// video player. Shared between [ContentDetailScreen]'s hero play button
/// and the home shelf's content-card play button so the two entry points
/// can't drift out of sync. Callers own their own loading-state flag around
/// the `await` — this only handles the fetch/dispatch/error-toast, not UI.
Future<void> playContent({
  required BuildContext context,
  required WidgetRef ref,
  required ContentResponseModel content,
}) async {
  final role = ref.read(authNotifierProvider).user?.role;
  if (content.isPremium && role == UserRole.listener) {
    PremiumUpgradeSheet.show(context);
    return;
  }

  try {
    final stream = await ref.read(listenerContentApiProvider).getStreamUrl(content.id);
    if (content.contentType == ContentType.show) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              streamUrl: stream.url,
              contentId: content.id,
              title: content.title,
            ),
          ),
        );
      }
    } else {
      await ref
          .read(audioPlayerProvider.notifier)
          .play(stream.url, contentId: content.id, title: content.title);
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageFor(error))));
    }
  }
}
