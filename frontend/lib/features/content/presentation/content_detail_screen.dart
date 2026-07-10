import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/layout/adaptive_content_wrapper.dart';
import '../../../core/network/api_error.dart';
import '../../../core/widgets/tier_badge.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/data/models/user_role.dart';
import '../../payment/presentation/premium_upgrade_sheet.dart';
import '../application/audio_player_notifier.dart';
import '../data/listener_content_api.dart';
import '../data/models/content_response_model.dart';
import '../data/models/content_type.dart';
import 'video_player_screen.dart';
import 'widgets/now_playing_bar.dart';

/// Detail view for either a Show or an Audio. Audio plays via the
/// persistent Now Playing bar; Shows push a dedicated full-screen
/// [VideoPlayerScreen] instead, since video isn't meant to keep playing
/// in the background while browsing other screens.
class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.content});

  final ContentResponseModel content;

  @override
  ConsumerState<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  bool _isLoadingStream = false;

  bool get _isPremiumGated {
    final role = ref.read(authNotifierProvider).user?.role;
    return widget.content.isPremium && role == UserRole.listener;
  }

  Future<void> _playNow() async {
    final content = widget.content;
    if (_isPremiumGated) {
      PremiumUpgradeSheet.show(context);
      return;
    }

    setState(() => _isLoadingStream = true);
    try {
      final stream = await ref
          .read(listenerContentApiProvider)
          .getStreamUrl(content.id);
      if (content.contentType == ContentType.show) {
        if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(messageFor(error))));
      }
    } finally {
      if (mounted) setState(() => _isLoadingStream = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final isAudio = content.contentType == ContentType.audio;
    final accent = isAudio ? AppColors.teal : AppColors.crimson;

    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      bottomNavigationBar: const NowPlayingBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AdaptiveContentWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: content.coverUrl != null
                      ? Image.network(content.coverUrl!, fit: BoxFit.cover)
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
                          child: Center(
                            child: Icon(
                              isAudio ? Icons.graphic_eq : Icons.movie_outlined,
                              color: AppColors.charcoal,
                              size: 48,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (content.isPremium) ...[
                    const SizedBox(width: 8),
                    const TierBadge(label: 'PREMIUM', color: AppColors.gold),
                  ],
                ],
              ),
              if (content.speaker != null) ...[
                const SizedBox(height: 6),
                Text(
                  content.speaker!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (content.categoryName != null) ...[
                const SizedBox(height: 4),
                Text(
                  content.categoryName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (content.description != null && content.description!.isNotEmpty)
                Text(
                  content.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isLoadingStream ? null : _playNow,
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                icon: _isLoadingStream
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: const Text('Play Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
