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

class _OtpBox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AppColors.teal
                      : Colors.white.withValues(alpha: 0.16),
                  width: 1.4,
                ),
                boxShadow: focusNode.hasFocus
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
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            onChanged: onChanged,
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
