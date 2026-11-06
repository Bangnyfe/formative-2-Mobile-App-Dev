import 'constants.dart';

/// Form field validators. Each returns an error message, or null when valid.
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

  static bool isAluEmail(String email) {
    final domain = email.trim().toLowerCase().split('@').last;
    return AppConstants.allowedEmailDomains.contains(domain);
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your full name';
    if (text.length < 2) return 'Name is too short';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address';
    if (!isAluEmail(text)) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please enter a password';
    if (text.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(text) || !RegExp(r'\d').hasMatch(text)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  /// Login only checks presence; strength rules apply at registration.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? incidentTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please add a short title';
    if (text.length < 5) return 'Title should be at least 5 characters';
    return null;
  }

  static String? incidentDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please describe the issue';
    if (text.length < 15) {
      return 'Add a bit more detail (at least 15 characters)';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
