import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';
import 'incident_status.dart';

/// One entry in a report's status timeline.
class StatusChange {
  const StatusChange({
    required this.status,
    required this.changedBy,
    required this.at,
    this.note,
  });

  final IncidentStatus status;
  final String changedBy;
  final DateTime at;
  final String? note;

  factory StatusChange.fromMap(Map<String, dynamic> data) {
    return StatusChange(
      status: IncidentStatus.fromName(data['status'] as String?),
      changedBy: data['changedBy'] as String? ?? '',
      at: (data['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
    );
  }

  // serverTimestamp() is not allowed inside arrays, so the client time is used.
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'changedBy': changedBy,
      'at': Timestamp.fromDate(at),
      'note': note,
    };
  }
}

/// An incident report stored in `incidents/{id}`.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.statusHistory = const [],
    this.affectedUserIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;
  final List<StatusChange> statusHistory;

  /// Other users who tapped "I noticed this too".
  final List<String> affectedUserIds;

  /// Students may only edit or delete a report before staff pick it up.
  bool get isEditable => status == IncidentStatus.submitted;

  /// The reporter plus everyone who said they noticed it too.
  int get affectedCount => 1 + affectedUserIds.length;

  bool isNoticedBy(String uid) => affectedUserIds.contains(uid);

  /// Name shown to other users; hides the reporter when anonymous.
  String get displayReporter => isAnonymous ? 'Anonymous' : reporterName;

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final history = (data['statusHistory'] as List<dynamic>? ?? [])
        .map((e) => StatusChange.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Incident(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: IncidentCategory.fromName(data['category'] as String?),
      location: data['location'] as String? ?? '',
      status: IncidentStatus.fromName(data['status'] as String?),
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      // Pending server timestamps are null on the first local snapshot.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: data['photoUrl'] as String?,
      statusHistory: history,
      affectedUserIds: List<String>.from(
        data['affectedUserIds'] as List<dynamic>? ?? [],
      ),
    );
  }

  /// Map used when creating a new report.
  Map<String, dynamic> toNewDocMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'status': status.name,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'isAnonymous': isAnonymous,
      'photoUrl': photoUrl,
      'statusHistory': statusHistory.map((s) => s.toMap()).toList(),
      'affectedUserIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
