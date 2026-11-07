/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const appName = 'Campus Incident Reporter';

  /// Only ALU accounts may register or sign in.
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  // Firestore collection names.
  static const usersCollection = 'users';
  static const incidentsCollection = 'incidents';

  // Cloudinary is used for photos instead of Firebase Storage (needs Blaze).
  // The unsigned preset only accepts jpg/png/webp into incident_photos.
  static const cloudinaryCloudName = 'w4skobz9';
  static const cloudinaryUploadPreset = 'incident_photos';
  static const maxPhotoBytes = 5 * 1024 * 1024;

  static const titleMaxLength = 60;
  static const descriptionMaxLength = 500;

  // Classrooms are named after African countries, e.g. "Social Commons, Egypt".
  static const campusLocations = [
    'Social Commons',
    'Learning Commons',
    'Enterprise Commons',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Innovation Lab',
    'Parking Area',
    'Main Gate',
  ];
}
