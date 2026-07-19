import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/layout/adaptive_content_wrapper.dart';
import '../../../core/widgets/floating_play_button.dart';
import '../application/content_playback.dart';
import '../data/models/content_response_model.dart';
import '../data/models/content_type.dart';
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

  Future<void> _playNow() async {
    setState(() => _isLoadingStream = true);
    await playContent(context: context, ref: ref, content: widget.content);
    if (mounted) setState(() => _isLoadingStream = false);
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      content.coverUrl != null
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
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: FloatingPlayButton(
                          onPressed: _isLoadingStream ? null : _playNow,
                          color: accent,
                          isLoading: _isLoadingStream,
                          frosted: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                content.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
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
            ],
          ),
        ),
      ),
    );
  }
}
