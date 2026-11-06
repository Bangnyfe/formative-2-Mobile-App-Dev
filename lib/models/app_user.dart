import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  staff;

  static UserRole fromName(String? name) =>
      name == UserRole.staff.name ? UserRole.staff : UserRole.student;
}

/// Profile stored in `users/{uid}`. The role is only ever changed by an
/// administrator in the Firebase Console; security rules block self-promotion.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final DateTime? createdAt;

  bool get isStaff => role == UserRole.staff;

  String get firstName => name.trim().split(' ').first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromName(data['role'] as String?),
      department: data['department'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
