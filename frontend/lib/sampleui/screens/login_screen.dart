import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/post_auth_router.dart';
import '../../core/config/theme_config.dart';
import '../../core/widgets/auth_form_card.dart';
import '../widgets/auth_secondary_button.dart';
import '../widgets/retro_doodle_background.dart';

const _pendingApprovalMessage = 'waiting for approval for this mobile number';

/// Login form reached from the landing screen's "Login" button. Phone +
/// password are validated server-side in a single request — the backend
/// used to require a second OTP-verification round-trip here, but that
/// step was removed, so a successful `login()` call goes straight to
/// [AuthStatus.authenticated].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Timer? _slowServerTimer;
  bool _showSlowServerHint = false;

  @override
  void dispose() {
    _slowServerTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitCredentials() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _startSlowServerTimer();
    ref
        .read(authNotifierProvider.notifier)
        .login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  // The production backend can take up to ~90s to wake from Render's
  // free-tier idle spin-down (see dio_client.dart's matching timeout) —
  // this hint only appears once a login is taking noticeably longer than
  // a warm request would, so it doesn't flash on every normal login.
  void _startSlowServerTimer() {
    _slowServerTimer?.cancel();
    setState(() => _showSlowServerHint = false);
    _slowServerTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showSlowServerHint = true);
    });
  }

  void _stopSlowServerTimer() {
    _slowServerTimer?.cancel();
    if (_showSlowServerHint) setState(() => _showSlowServerHint = false);
  }

  void _showPendingApprovalDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Almost there!'),
        content: const Text(
          "Your registration was successful, but your account is still pending "
          "administrator approval. You'll be able to log in as soon as it's "
          'approved — please check back soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status != AuthStatus.loading) {
        _stopSlowServerTimer();
      }
      if (next.status == AuthStatus.authenticated && next.user != null) {
        routeToDashboard(context, next.user!);
      }
      if (next.status == AuthStatus.error &&
          next.errorMessage == _pendingApprovalMessage &&
          previous?.status == AuthStatus.loading) {
        _showPendingApprovalDialog();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

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
            child: AuthFormCard(
              maxWidth: 460,
              child: Form(
                key: _formKey,
                child: Column(
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
                    if (authState.status == AuthStatus.error) ...[
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
                    if (isLoading && _showSlowServerHint) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Waking up the server — this can take up to a '
                        'minute after a period of inactivity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
