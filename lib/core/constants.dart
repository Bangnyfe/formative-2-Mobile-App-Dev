/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const appName = 'Campus Fix';

  /// Only ALU accounts may register or sign in.
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  // Firestore collection names.
  static const usersCollection = 'users';
  static const incidentsCollection = 'incidents';

  static const titleMaxLength = 60;
  static const descriptionMaxLength = 500;

  static const campusLocations = [
    'Main Building',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Block A',
    'Block B',
    'Innovation Lab',
    'Sports Ground',
    'Parking Area',
    'Main Gate',
  ];
}
