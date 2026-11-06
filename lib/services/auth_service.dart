import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so the rest of the app never imports it
/// directly. Errors are converted to [AuthException] with readable messages.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  /// Emits on sign-in, sign-out and profile changes (including after reload,
  /// which is how we notice that the email has been verified).
  Stream<User?> userChanges() => _auth.userChanges();

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name.trim());
      await user.sendEmailVerification();
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Refreshes the cached user and returns whether the email is now verified.
  /// The ID token is refreshed too so Firestore rules see `email_verified`.
  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed != null && refreshed.emailVerified) {
      await refreshed.getIdToken(true);
      return true;
    }
    return false;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signOut() => _auth.signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('An account already exists for this email.');
      case 'invalid-email':
        return const AuthException('That email address is not valid.');
      case 'weak-password':
        return const AuthException('Please choose a stronger password.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException('Incorrect email or password.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please wait a moment and try again.',
        );
      case 'network-request-failed':
        return const AuthException('No internet connection. Please try again.');
      default:
        return AuthException(e.message ?? 'Something went wrong. Try again.');
    }
  }

  @override
  String toString() => message;
}
