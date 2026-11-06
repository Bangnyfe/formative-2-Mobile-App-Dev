import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';
import 'auth/login_screen.dart';
import 'auth/verify_email_screen.dart';
import 'main_shell.dart';

/// Chooses the first screen based on the current auth state.
/// Because it rebuilds whenever [AuthProvider] notifies, signing in,
/// verifying and signing out all switch screens automatically.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const _LoadingScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.unverified:
        return const VerifyEmailScreen();
      case AuthStatus.authenticated:
        // Wait for the Firestore profile so the role is known before showing
        // any role-specific UI.
        if (auth.profileError != null) return const _ProfileErrorScreen();
        if (auth.appUser == null) return const _LoadingScreen();
        return const MainShell();
    }
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  const _ProfileErrorScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  icon: Icons.cloud_off_rounded,
                  title: 'Something went wrong',
                  subtitle: 'We could not load your profile. Check your connection and try again.',
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Try again',
                  icon: Icons.refresh_rounded,
                  onPressed: auth.retryProfile,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: auth.signOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
