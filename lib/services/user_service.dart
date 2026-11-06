import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/app_user.dart';

/// Reads and writes user profiles in the `users` collection.
class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  Stream<AppUser?> watchUser(String uid) {
    return _doc(uid).snapshots().map(
      (snap) => snap.exists ? AppUser.fromMap(snap.id, snap.data()!) : null,
    );
  }

  /// Creates the profile the first time a verified user signs in.
  /// New accounts are always students; staff are promoted in the Console.
  Future<void> createProfileIfMissing({
    required String uid,
    required String name,
    required String email,
  }) async {
    final doc = _doc(uid);
    final snap = await doc.get();
    if (snap.exists) return;

    final user = AppUser(
      uid: uid,
      name: name,
      email: email,
      role: UserRole.student,
    );
    await doc.set(user.toMap());
  }
}
