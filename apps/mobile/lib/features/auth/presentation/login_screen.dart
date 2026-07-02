import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:power_alert/core/config/app_environment.dart';
import 'package:power_alert/core/localization/app_localizations.dart';
import 'package:power_alert/core/theme/app_theme.dart';
import 'package:power_alert/domain/models/app_user.dart';

enum LoginMethod { mobile, email }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginMethod _method = LoginMethod.mobile;
  UserRole _demoRole = UserRole.consumer;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!AppEnvironment.useDemoData &&
        Firebase.apps.isNotEmpty &&
        FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateForCurrentUser();
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (AppEnvironment.useDemoData) {
      _navigateForRole(_demoRole.name);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_method == LoginMethod.email) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await _navigateForCurrentUser();
      } else {
        await _sendOtp();
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message ?? 'Authentication failed.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendOtp() async {
    final input = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (input.length < 10) {
      throw FirebaseAuthException(
        code: 'invalid-phone-number',
        message: 'Enter a valid mobile number.',
      );
    }
    final phoneNumber = input.startsWith('91') ? '+$input' : '+91$input';
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) await _navigateForCurrentUser();
        } on FirebaseAuthException catch (error) {
          _showAuthError(error);
        }
      },
      verificationFailed: (error) {
        if (mounted) {
          setState(() => _error = error.message ?? 'OTP verification failed.');
        }
      },
      codeSent: (verificationId, _) async {
        try {
          final code = await _requestOtpCode();
          if (code == null || code.isEmpty) return;
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: code,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) await _navigateForCurrentUser();
        } on FirebaseAuthException catch (error) {
          _showAuthError(error);
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<String?> _requestOtpCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter verification code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: '6-digit OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    controller.dispose();
    return code;
  }

  Future<void> _signInWithGoogle() async {
    if (AppEnvironment.useDemoData) {
      _navigateForRole(_demoRole.name);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _navigateForCurrentUser();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message ?? 'Google Sign-In failed.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Google Sign-In was not completed.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _navigateForCurrentUser() async {
    final result = await FirebaseAuth.instance.currentUser?.getIdTokenResult(
      true,
    );
    final role = result?.claims?['role'] as String? ?? 'consumer';
    if (mounted) _navigateForRole(role);
  }

  void _navigateForRole(String role) {
    final route = switch (role) {
      'providerStaff' => '/provider',
      'technician' => '/technician',
      'superAdmin' => '/admin',
      _ => '/home',
    };
    context.go(route);
  }

  void _showAuthError(FirebaseAuthException error) {
    if (mounted) {
      setState(() => _error = error.message ?? 'Authentication failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _BrandMark(),
                            const SizedBox(height: 18),
                            Text(
                              strings.text('appName'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.text('tagline'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 28),
                            SegmentedButton<LoginMethod>(
                              segments: const [
                                ButtonSegment(
                                  value: LoginMethod.mobile,
                                  icon: Icon(Icons.phone_android_rounded),
                                  label: Text('Mobile OTP'),
                                ),
                                ButtonSegment(
                                  value: LoginMethod.email,
                                  icon: Icon(Icons.mail_outline_rounded),
                                  label: Text('Email'),
                                ),
                              ],
                              selected: {_method},
                              onSelectionChanged: (value) =>
                                  setState(() => _method = value.first),
                            ),
                            const SizedBox(height: 18),
                            if (_method == LoginMethod.mobile)
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                autofillHints: [AutofillHints.telephoneNumber],
                                decoration: const InputDecoration(
                                  labelText: 'Mobile number',
                                  prefixText: '+91  ',
                                  prefixIcon: Icon(Icons.phone_rounded),
                                ),
                              )
                            else ...[
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                autofillHints: [AutofillHints.password],
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_rounded),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            if (AppEnvironment.useDemoData)
                              DropdownButtonFormField<UserRole>(
                                initialValue: _demoRole,
                                decoration: const InputDecoration(
                                  labelText: 'Preview role',
                                  prefixIcon: Icon(
                                    Icons.admin_panel_settings_rounded,
                                  ),
                                ),
                                items: UserRole.values
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (role) =>
                                    setState(() => _demoRole = role!),
                              ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _busy ? null : _continue,
                              child: Text(
                                _busy
                                    ? 'Please wait...'
                                    : strings.text('continueLabel'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _signInWithGoogle,
                              icon: const Icon(Icons.g_mobiledata_rounded),
                              label: const Text('Continue with Google'),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              AppEnvironment.useDemoData
                                  ? 'Demo mode is active. No credentials are sent.'
                                  : 'Protected by Firebase Authentication and '
                                        'device verification.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            _Preferences(ref: ref),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.secondary.withValues(alpha: 0.9),
          Theme.of(context).colorScheme.surface,
          AppColors.primary.withValues(alpha: 0.75),
        ],
      ),
    ),
    child: CustomPaint(painter: _GridPainter()),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Color(0xFF2A1B00), size: 46),
    ),
  );
}

class _Preferences extends StatelessWidget {
  const _Preferences({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeModeProvider);
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Locale>(
            initialValue: locale,
            decoration: const InputDecoration(
              labelText: 'Language',
              isDense: true,
            ),
            items:
                const [
                      ('English', Locale('en')),
                      ('हिन्दी', Locale('hi')),
                      ('বাংলা', Locale('bn')),
                      ('मराठी', Locale('mr')),
                      ('தமிழ்', Locale('ta')),
                      ('తెలుగు', Locale('te')),
                      ('ગુજરાતી', Locale('gu')),
                    ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.$2,
                        child: Text(item.$1),
                      ),
                    )
                    .toList(),
            onChanged: (value) =>
                ref.read(localeProvider.notifier).setLocale(value!),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: 'Change theme',
          onPressed: () {
            final next = theme == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
            ref.read(themeModeProvider.notifier).setMode(next);
          },
          icon: Icon(
            theme == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
        ),
      ],
    );
  }
}
