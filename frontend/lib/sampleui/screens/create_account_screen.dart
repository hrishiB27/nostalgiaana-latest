import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/data/models/signup_request.dart';
import '../../core/config/theme_config.dart';
import '../../core/data/countries.dart';
import '../../core/widgets/auth_form_card.dart';
import '../../core/widgets/nostalgiaana_brand_text.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/retro_doodle_background.dart';
import 'pending_approval_screen.dart';

const _fieldDecoration = InputDecoration(isDense: true);

/// Signup form reached from the landing screen's "Create Account" button.
/// Signup has no OTP step on the backend — `AuthNotifier.signup()` goes
/// straight to `AuthStatus.authenticated` on success, so this screen has
/// only one phase, unlike [LoginScreen].
///
/// Fields are paired into rows and tightly spaced (`isDense` decorations,
/// small gaps) so the whole form fits one screen without scrolling on most
/// devices — scrolling itself stays enabled as a fallback for short screens
/// or when the keyboard is open, rather than risking a hard overflow.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Country is selected first and drives the dial-code prefix shown next to
  // the phone field below — the prefix is cosmetic only. `User.phone` always
  // stores the bare local number; the dial code is never appended to it.
  Country _selectedCountry = countries.first;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authNotifierProvider.notifier)
        .signup(
          SignupRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
            country: _selectedCountry.name,
            city: _cityController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          (route) => false,
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RetroDoodleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            // `extendBodyBehindAppBar` + a transparent AppBar means SafeArea
            // only accounts for the status bar, not the AppBar's own height
            // — without this extra top padding, content starts underneath
            // the "Create Account" title instead of below it.
            padding: EdgeInsets.fromLTRB(24, 24 + kToolbarHeight, 24, 24),
            child: AuthFormCard(
              maxWidth: 560,
              child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Join ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      NostalgiaanaBrandText(
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleLarge!.fontSize,
                          fontWeight: Theme.of(
                            context,
                          ).textTheme.titleLarge!.fontWeight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to start listening',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: _fieldDecoration.copyWith(
                            labelText: 'First name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: _fieldDecoration.copyWith(
                            labelText: 'Last name',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: DropdownButtonFormField<Country>(
                          initialValue: _selectedCountry,
                          isExpanded: true,
                          decoration: _fieldDecoration.copyWith(
                            labelText: 'Country',
                          ),
                          items: countries
                              .map(
                                (country) => DropdownMenuItem(
                                  value: country,
                                  child: Text(
                                    country.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedCountry = value);
                          },
                          validator: (value) =>
                              value == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: _fieldDecoration.copyWith(
                            labelText: 'City',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration.copyWith(
                      labelText: 'Phone Number',
                      prefixText: '${_selectedCountry.dialCode} ',
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _fieldDecoration.copyWith(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (value.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  if (authState.status == AuthStatus.error) ...[
                    const SizedBox(height: 16),
                    Text(
                      authState.errorMessage ?? 'Something went wrong.',
                      style: const TextStyle(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  AuthPrimaryButton(
                    label: 'Create Account',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
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
