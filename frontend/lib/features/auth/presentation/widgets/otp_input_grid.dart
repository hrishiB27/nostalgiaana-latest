import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/config/theme_config.dart';

/// Six glassmorphic OTP boxes that auto-forward focus as digits are typed
/// and step back on backspace. Call [clear] (via [GlobalKey]) to wipe the
/// code after a failed verification attempt.
class OtpInputGrid extends StatefulWidget {
  const OtpInputGrid({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<OtpInputGrid> createState() => OtpInputGridState();
}

class OtpInputGridState extends State<OtpInputGrid> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _distributePaste(index, value);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emitIfComplete();
  }

  void _distributePaste(int index, String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < digits.length && (index + i) < widget.length; i++) {
      _controllers[index + i].text = digits[i];
    }
    final nextIndex = (index + digits.length).clamp(0, widget.length - 1);
    _focusNodes[nextIndex].requestFocus();
    _emitIfComplete();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _emitIfComplete() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return _OtpBox(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          onChanged: (value) => _onChanged(index, value),
          onBackspace: () => _onBackspace(index),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  // KeyboardListener requires its own FocusNode. Handing it widget.focusNode
  // — the same node the TextField below attaches — would make that node an
  // ancestor and descendant of itself in the focus tree at once, which trips
  // a 'child != this' assertion in FocusNode._reparent. This node never
  // requests focus itself; it only exists to host onKeyEvent, which still
  // fires for backspace because unhandled key events bubble up from the
  // focused TextField through its ancestors.
  final _keyboardFocusNode = FocusNode(canRequestFocus: false, skipTraversal: true);

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onBackspace();
          }
        },
        child: ListenableBuilder(
          listenable: widget.focusNode,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.focusNode.hasFocus
                      ? AppColors.teal
                      : Colors.white.withValues(alpha: 0.16),
                  width: 1.4,
                ),
                boxShadow: widget.focusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              color: AppColors.offWhite,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );
  }
}
