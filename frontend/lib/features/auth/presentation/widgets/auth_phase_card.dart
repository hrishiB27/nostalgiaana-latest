import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/auth_notifier.dart';
import '../../application/auth_state.dart';
import '../../data/models/signup_request.dart';
import '../../domain/authenticated_user.dart';
import 'otp_input_grid.dart';

enum _FormMode { login, signup }

/// The single morphing card behind both the user and admin auth screens.
/// Phase is derived purely from [AuthState.otpIdentifier]: once it's set
/// (by [AuthNotifier.login]) the OTP layout takes over, and it clears again
/// via [AuthNotifier.reset] or [AuthNotifier.logout].
class AuthPhaseCard extends ConsumerStatefulWidget {
  const AuthPhaseCard({
    super.key,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAuthenticated,
    this.allowSignUp = false,
  });

  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool allowSignUp;
  final ValueChanged<AuthenticatedUser> onAuthenticated;

  @override
  ConsumerState<AuthPhaseCard> createState() => _AuthPhaseCardState();
}

class _AuthPhaseCardState extends ConsumerState<AuthPhaseCard> {
  final _formKey = GlobalKey<FormState>();
  final _otpGridKey = GlobalKey<OtpInputGridState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  _FormMode _mode = _FormMode.login;
  bool _obscurePassword = true;

  Timer? _resendTimer;
  int _resendSecondsRemaining = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  void _submitPhaseOne() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_mode == _FormMode.signup) {
      notifier.signup(SignupRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _identifierController.text.trim(),
        password: _passwordController.text,
      ));
    } else {
      notifier.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _resend() {
    if (_resendSecondsRemaining > 0) return;
    ref.read(authNotifierProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.otpRequired && previous?.status != AuthStatus.otpRequired) {
        _startResendCooldown();
      }
      if (next.status == AuthStatus.authenticated && next.user != null) {
        widget.onAuthenticated(next.user!);
      }
      if (next.status == AuthStatus.error &&
          next.otpIdentifier != null &&
          previous?.status == AuthStatus.loading) {
        _otpGridKey.currentState?.clear();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isPhaseTwo = authState.otpIdentifier != null;
    final isLoading = authState.status == AuthStatus.loading;

    return GlassCard(
      borderColor: widget.accentColor,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
                .animate(animation);
            return ClipRect(
              child: SlideTransition(
                position: slide,
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [...previousChildren, ?currentChild],
            );
          },
          child: isPhaseTwo
              ? _buildOtpPhase(authState, isLoading)
              : _buildCredentialsPhase(authState, isLoading),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: widget.accentColor.withValues(alpha: 0.18),
          child: Icon(widget.icon, color: widget.accentColor, size: 30),
        ),
        const SizedBox(height: 14),
        Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCredentialsPhase(AuthState authState, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('credentials-phase'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          if (_mode == _FormMode.signup) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: AppColors.offWhite),
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: AppColors.offWhite),
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _identifierController,
            style: const TextStyle(color: AppColors.offWhite),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _mode == _FormMode.signup ? 'Email' : 'Email or phone',
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: AppColors.offWhite),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.offWhite.withValues(alpha: 0.6),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              if (_mode == _FormMode.signup && value.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          if (authState.status == AuthStatus.error && authState.otpIdentifier == null) ...[
            const SizedBox(height: 12),
            Text(
              authState.errorMessage ?? 'Something went wrong.',
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submitPhaseOne,
            style: ElevatedButton.styleFrom(backgroundColor: widget.accentColor),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.offWhite),
                  )
                : Text(_mode == _FormMode.signup ? 'Create account' : 'Send OTP'),
          ),
          if (widget.allowSignUp) ...[
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(authNotifierProvider.notifier).reset();
                        setState(() {
                          _mode = _mode == _FormMode.login ? _FormMode.signup : _FormMode.login;
                        });
                      },
                child: Text(
                  _mode == _FormMode.login ? 'New here? Sign Up' : 'Already have an account? Log in',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpPhase(AuthState authState, bool isLoading) {
    return Column(
      key: const ValueKey('otp-phase'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: isLoading ? null : () => ref.read(authNotifierProvider.notifier).reset(),
            icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
          ),
        ),
        Icon(Icons.mark_email_read_outlined, color: widget.accentColor, size: 32),
        const SizedBox(height: 12),
        Text(
          'Enter the 6-digit code',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Sent to ${authState.otpIdentifier}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        OtpInputGrid(
          key: _otpGridKey,
          enabled: !isLoading,
          onCompleted: (code) => ref.read(authNotifierProvider.notifier).verifyOtp(code),
        ),
        if (authState.status == AuthStatus.error) ...[
          const SizedBox(height: 14),
          Text(
            authState.errorMessage ?? 'Invalid OTP.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 20),
        if (isLoading)
          const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.offWhite),
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
                      ? AppColors.gold.withValues(alpha: 0.7)
                      : AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
