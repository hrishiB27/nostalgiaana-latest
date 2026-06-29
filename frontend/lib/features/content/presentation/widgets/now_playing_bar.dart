import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../application/audio_player_notifier.dart';

/// Sticky mini-player anchored to the bottom of the dashboard shell.
/// Collapses to nothing when no track has ever been loaded — safe to drop
/// into a `Scaffold.bottomNavigationBar` unconditionally.
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    if (!state.hasActiveTrack) return const SizedBox.shrink();

    final duration = state.duration ?? Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (state.position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      color: AppColors.charcoal,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: AppColors.teal,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.title ?? '',
                          style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_format(state.position)} / ${_format(duration)}',
                          style: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.55), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (state.isBuffering)
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.teal),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
                      icon: Icon(
                        state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppColors.offWhite,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
