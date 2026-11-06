import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

/// Shown to signed-in users whose email is not verified yet. It checks in the
/// background every few seconds so the user is let in as soon as they click
/// the link in their inbox.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendCooldown = 60;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _secondsLeft = _resendCooldown;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => context.read<AuthProvider>().checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    final sent = await context.read<AuthProvider>().resendVerificationEmail();
    if (!mounted) return;
    if (sent) {
      _startCooldown();
      messenger.showSnackBar(
        const SnackBar(content: Text('Verification email sent again.')),
      );
    }
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    final messenger = ScaffoldMessenger.of(context);
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!verified) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Not verified yet. Open the link in your email first.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canResend = _secondsLeft <= 0 && !auth.isBusy;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Verify your email',
                  subtitle:
                      'We sent a verification link to\n${auth.email ?? 'your email'}.\nOpen it to activate your account.',
                ),
                const SizedBox(height: 12),
                const Text(
                  "Can't find it? Check your spam or junk folder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                if (auth.errorMessage != null) ...[
                  ErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  label: "I've verified my email",
                  isLoading: _checking,
                  onPressed: _checkNow,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: canResend ? _resend : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    canResend
                        ? 'Resend email'
                        : 'Resend email in ${_secondsLeft}s',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: auth.signOut,
                  child: const Text('Use a different account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
