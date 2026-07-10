import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/post_auth_router.dart';
import '../../core/config/theme_config.dart';
import '../widgets/auth_secondary_button.dart';
import '../widgets/retro_doodle_background.dart';

/// Login form reached from the landing screen's "Login" button. Unlike
/// [CreateAccountScreen], login has a real OTP step on the backend
/// (`AuthStatus.otpRequired` between `.login()` and `.verifyOtp()`), so
/// this screen has two internal phases, mirroring the existing
/// `AuthPhaseCard` structure but newly written and cream-themed — it does
/// not reuse `OtpInputGrid`, which hardcodes the dark theme's colors.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpGridKey = GlobalKey<_SampleUiOtpGridState>();
  bool _obscurePassword = true;

  Timer? _resendTimer;
  int _resendSecondsRemaining = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsRemaining = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
      } else {
        setState(() => _resendSecondsRemaining -= 1);
      }
    });
  }

  void _submitCredentials() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authNotifierProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _resend() {
    if (_resendSecondsRemaining > 0) return;
    ref
        .read(authNotifierProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.otpRequired &&
          previous?.status != AuthStatus.otpRequired) {
        _startResendCooldown();
      }
      if (next.status == AuthStatus.authenticated && next.user != null) {
        routeToDashboard(context, next.user!);
      }
      if (next.status == AuthStatus.error &&
          next.otpIdentifier != null &&
          previous?.status == AuthStatus.loading) {
        _otpGridKey.currentState?.clear();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final isOtpPhase = authState.otpIdentifier != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RetroDoodleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            // `extendBodyBehindAppBar` + a transparent AppBar means SafeArea
            // only accounts for the status bar, not the AppBar's own height
            // — without this extra top padding, content starts underneath
            // the "Login" title instead of below it.
            padding: EdgeInsets.fromLTRB(24, 24 + kToolbarHeight, 24, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: isOtpPhase
                  ? _buildOtpPhase(authState, isLoading)
                  : _buildCredentialsPhase(authState, isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsPhase(AuthState authState, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('credentials-phase'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome back', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Sign in to keep the memories playing',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Phone Number',
            ),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return 'Required';
              if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
                return 'Enter a 10-digit phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Required' : null,
          ),
          if (authState.status == AuthStatus.error &&
              authState.otpIdentifier == null) ...[
            const SizedBox(height: 10),
            Text(
              authState.errorMessage ?? 'Something went wrong.',
              style: const TextStyle(
                color: AppColors.crimson,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          AuthSecondaryButton(
            label: 'Login',
            isLoading: isLoading,
            onPressed: _submitCredentials,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpPhase(AuthState authState, bool isLoading) {
    return Column(
      key: const ValueKey('otp-phase'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: isLoading
                ? null
                : () => ref.read(authNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          ),
        ),
        const Icon(Icons.sms_outlined, color: AppColors.crimson, size: 28),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Sent to ${authState.otpIdentifier}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _SampleUiOtpGrid(
          key: _otpGridKey,
          enabled: !isLoading,
          onCompleted: (code) =>
              ref.read(authNotifierProvider.notifier).verifyOtp(code),
        ),
        if (authState.status == AuthStatus.error) ...[
          const SizedBox(height: 10),
          Text(
            authState.errorMessage ?? 'Invalid OTP.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.crimson,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (isLoading)
          const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.crimson,
              ),
            ),
          )
        else
          Center(
            child: TextButton(
              onPressed: _resendSecondsRemaining > 0 ? null : _resend,
              child: Text(
                _resendSecondsRemaining > 0
                    ? 'Resend OTP in ${_resendSecondsRemaining}s'
                    : 'Resend OTP',
                style: TextStyle(
                  color: _resendSecondsRemaining > 0
                      ? AppColors.crimson.withValues(alpha: 0.6)
                      : AppColors.crimson,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Cream-themed 6-box OTP input, built fresh for sampleui rather than
/// reusing the existing `OtpInputGrid` (which hardcodes the dark theme's
/// `AppColors`). Same auto-advance/backspace-to-previous behavior.
class _SampleUiOtpGrid extends StatefulWidget {
  const _SampleUiOtpGrid({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  static const length = 6;

  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<_SampleUiOtpGrid> createState() => _SampleUiOtpGridState();
}

class _SampleUiOtpGridState extends State<_SampleUiOtpGrid> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _SampleUiOtpGrid.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(_SampleUiOtpGrid.length, (_) => FocusNode());
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
    if (value.isNotEmpty && index < _SampleUiOtpGrid.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emitIfComplete();
  }

  void _distributePaste(int index, String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (
      var i = 0;
      i < digits.length && (index + i) < _SampleUiOtpGrid.length;
      i++
    ) {
      _controllers[index + i].text = digits[i];
    }
    final nextIndex = (index + digits.length).clamp(
      0,
      _SampleUiOtpGrid.length - 1,
    );
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
    if (code.length == _SampleUiOtpGrid.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _SampleUiOtpGrid.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _SampleUiOtpBox(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              onChanged: (value) => _onChanged(index, value),
              onBackspace: () => _onBackspace(index),
            ),
          ),
        ],
      ],
    );
  }
}

class _SampleUiOtpBox extends StatefulWidget {
  const _SampleUiOtpBox({
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
  State<_SampleUiOtpBox> createState() => _SampleUiOtpBoxState();
}

class _SampleUiOtpBoxState extends State<_SampleUiOtpBox> {
  // KeyboardListener requires its own FocusNode — reusing widget.focusNode
  // (the TextField's own node) would make that node an ancestor and
  // descendant of itself in the focus tree at once ('child != this'
  // assertion in FocusNode._reparent). This node never requests focus
  // itself; backspace still reaches onKeyEvent via bubbling from the
  // focused TextField.
  final _keyboardFocusNode = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onBackspace();
          }
        },
        child: ListenableBuilder(
          listenable: widget.focusNode,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.panelCream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.focusNode.hasFocus
                      ? AppColors.crimson
                      : AppColors.crimson.withValues(alpha: 0.2),
                  width: 1.4,
                ),
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
              color: AppColors.charcoal,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );
  }
}
