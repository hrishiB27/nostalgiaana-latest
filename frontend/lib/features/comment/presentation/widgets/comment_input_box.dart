import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/layout/adaptive_content_wrapper.dart';
import '../../application/comments_notifier.dart';

class CommentInputBox extends ConsumerStatefulWidget {
  const CommentInputBox({super.key, required this.contentId, required this.accent});

  final String contentId;
  final Color accent;

  @override
  ConsumerState<CommentInputBox> createState() => _CommentInputBoxState();
}

class _CommentInputBoxState extends ConsumerState<CommentInputBox> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isSubmitting) async {
    final text = _controller.text.trim();
    if (text.isEmpty || isSubmitting) return;
    final notifier = ref.read(commentsProvider(widget.contentId).notifier);
    await notifier.post(text);
    if (ref.read(commentsProvider(widget.contentId)).submitError == null) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(widget.contentId));
    final canSubmit = _hasText && !state.isSubmitting;

    return Material(
      color: AppColors.panelCream,
      child: SafeArea(
        top: false,
        child: AdaptiveContentWrapper(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.submitError != null) ...[
                  Text(
                    state.submitError!,
                    style: const TextStyle(color: AppColors.crimson, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !state.isSubmitting,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: 'Add a comment…', isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (canSubmit || state.isSubmitting)
                            ? widget.accent
                            : AppColors.charcoal.withValues(alpha: 0.2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: canSubmit ? () => _submit(state.isSubmitting) : null,
                          child: Center(
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                  )
                                : const Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
