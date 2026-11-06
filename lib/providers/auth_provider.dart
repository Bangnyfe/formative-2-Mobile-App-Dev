import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/validators.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, unauthenticated, unverified, authenticated }

/// Holds the signed-in session and exposes auth actions to the UI.
///
/// The gate in main.dart rebuilds from [status], so screens never have to
/// navigate manually after signing in, verifying or signing out.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, UserService? userService})
    : _authService = authService ?? AuthService(),
      _userService = userService ?? UserService() {
    _authSub = _authService.userChanges().listen(_onUserChanged);
  }

  final AuthService _authService;
  final UserService _userService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;
  String? _profileUid;

  AuthStatus _status = AuthStatus.unknown;
  User? _firebaseUser;
  AppUser? _appUser;
  bool _isBusy = false;
  String? _errorMessage;
  String? _profileError;

  AuthStatus get status => _status;
  String? get profileError => _profileError;
  AppUser? get appUser => _appUser;
  String? get email => _firebaseUser?.email;
  bool get isStaff => _appUser?.isStaff ?? false;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> _onUserChanged(User? user) async {
    _firebaseUser = user;

    if (user == null) {
      _clearProfile();
      _status = AuthStatus.unauthenticated;
    } else if (!user.emailVerified) {
      _clearProfile();
      _status = AuthStatus.unverified;
    } else {
      _status = AuthStatus.authenticated;
      await _loadProfile(user);
    }
    notifyListeners();
  }

  Future<void> _loadProfile(User user) async {
    if (_profileUid == user.uid) return;
    _profileUid = user.uid;
    _profileError = null;
    try {
      await _userService.createProfileIfMissing(
        uid: user.uid,
        name: user.displayName ?? user.email!.split('@').first,
        email: user.email!,
      );
    } catch (_) {
      _setProfileError();
      return;
    }
    _profileSub = _userService
        .watchUser(user.uid)
        .listen(
          (profile) {
            _appUser = profile;
            _profileError = null;
            notifyListeners();
          },
          onError: (_) {
            _setProfileError();
            notifyListeners();
          },
        );
  }

  void _setProfileError() {
    _profileError =
        'We could not load your profile. Check your connection and try again.';
    _profileSub?.cancel();
    _profileSub = null;
    _profileUid = null;
  }

  Future<void> retryProfile() async {
    final user = _firebaseUser;
    if (user == null) return;
    _profileError = null;
    notifyListeners();
    await _loadProfile(user);
    notifyListeners();
  }

  void _clearProfile() {
    _profileSub?.cancel();
    _profileSub = null;
    _profileUid = null;
    _appUser = null;
    _profileError = null;
  }

  /// Runs an auth action with shared busy/error handling.
  /// Returns true on success so screens can react (e.g. pop or show a message).
  Future<bool> _run(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      if (!Validators.isAluEmail(email)) {
        throw const AuthException('Only ALU email addresses can register.');
      }
      await _authService.register(name: name, email: email, password: password);
    });
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() async {
      if (!Validators.isAluEmail(email)) {
        throw const AuthException('Only ALU email addresses can sign in.');
      }
      await _authService.signIn(email: email, password: password);
    });
  }

  Future<bool> resendVerificationEmail() =>
      _run(_authService.sendEmailVerification);

  /// Called from the verify screen. If verified, userChanges() fires and the
  /// gate moves the user into the app.
  Future<bool> checkEmailVerified() async {
    try {
      return await _authService.reloadAndCheckVerified();
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _authService.sendPasswordReset(email));

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
