/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const appName = 'Campus Fix';

  /// Only ALU accounts may register or sign in.
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  // Firestore collection names.
  static const usersCollection = 'users';
  static const incidentsCollection = 'incidents';
}
