import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'auth/verify_email_screen.dart';
import 'home/home_screen.dart';

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
        if (auth.appUser == null) return const _LoadingScreen();
        return const HomeScreen();
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
