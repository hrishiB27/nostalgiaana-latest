import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/layout/adaptive_content_wrapper.dart';
import '../../application/audio_player_notifier.dart';

/// Sticky mini-player anchored to the bottom of the dashboard shell.
/// Collapses to nothing when no track has ever been loaded — safe to drop
/// into a `Scaffold.bottomNavigationBar` unconditionally.
class NowPlayingBar extends ConsumerStatefulWidget {
  const NowPlayingBar({super.key});

  @override
  ConsumerState<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends ConsumerState<NowPlayingBar> {
  /// Seconds the user is currently dragging the scrubber to, while the
  /// drag is in progress — kept separate from the live playback position
  /// so the thumb doesn't jump back mid-drag as position-stream updates
  /// arrive. Cleared (and the real seek fired) on drag end.
  double? _dragSeconds;

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioPlayerProvider);
    if (!state.hasActiveTrack) return const SizedBox.shrink();

    final duration = state.duration ?? Duration.zero;
    final maxSeconds = duration.inMilliseconds / 1000;
    final seekable = maxSeconds > 0;
    final positionSeconds =
        (_dragSeconds ?? state.position.inMilliseconds / 1000).clamp(0.0, seekable ? maxSeconds : 0.0);
    final displayPosition = _dragSeconds != null
        ? Duration(milliseconds: (_dragSeconds! * 1000).round())
        : state.position;

    return Material(
      color: AppColors.panelCream,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveContentWrapper(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.teal,
                  inactiveTrackColor: AppColors.charcoal.withValues(alpha: 0.12),
                  thumbColor: AppColors.teal,
                  overlayColor: AppColors.teal.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: positionSeconds,
                  max: seekable ? maxSeconds : 1.0,
                  onChanged: seekable
                      ? (value) => setState(() => _dragSeconds = value)
                      : null,
                  onChangeEnd: seekable
                      ? (value) {
                          ref
                              .read(audioPlayerProvider.notifier)
                              .seek(Duration(milliseconds: (value * 1000).round()));
                          setState(() => _dragSeconds = null);
                        }
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: AdaptiveContentWrapper(
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
                            style: const TextStyle(color: AppColors.charcoal, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_format(displayPosition)} / ${_format(duration)}',
                            style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.55), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: seekable
                          ? () => ref.read(audioPlayerProvider.notifier).skipBackward()
                          : null,
                      icon: const Icon(Icons.replay_10, color: AppColors.charcoal),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: 'Back 10 seconds',
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
                          color: AppColors.charcoal,
                          size: 32,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    IconButton(
                      onPressed: seekable
                          ? () => ref.read(audioPlayerProvider.notifier).skipForward()
                          : null,
                      icon: const Icon(Icons.forward_10, color: AppColors.charcoal),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      tooltip: 'Forward 10 seconds',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
