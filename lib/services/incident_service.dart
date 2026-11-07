import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

class IncidentService {
  IncidentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection(AppConstants.incidentsCollection);

  Future<String> createIncident(Incident incident) async {
    final doc = await _incidents.add(incident.toNewDocMap());
    return doc.id;
  }

  // Sorted on the device instead of with orderBy(), which would need a
  // composite index together with the where() filter.
  Stream<List<Incident>> watchUserIncidents(String uid) {
    return _incidents.where('reporterId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs.map(Incident.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Incident>> watchAllIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Incident.fromDoc).toList());
  }

  /// Staff only. arrayUnion appends to the timeline without rewriting it.
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
    String? note,
  }) {
    final change = StatusChange(
      status: status,
      changedBy: changedBy,
      at: DateTime.now(),
      note: note,
    );
    return _incidents.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([change.toMap()]),
    });
  }

  Stream<Incident?> watchIncident(String id) {
    return _incidents
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Incident.fromDoc(doc) : null);
  }

  // Uses a transaction so the edit fails if staff changed the status
  // while the student was editing.
  Future<void> updateIncidentDetails({
    required String id,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool isAnonymous,
  }) {
    final ref = _incidents.doc(id);
    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      _ensureStillSubmitted(snap);
      tx.update(ref, {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'isAnonymous': isAnonymous,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteIncident(String id) {
    final ref = _incidents.doc(id);
    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      _ensureStillSubmitted(snap);
      tx.delete(ref);
    });
  }

  void _ensureStillSubmitted(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists ||
        snap.data()!['status'] != IncidentStatus.submitted.name) {
      throw const IncidentLockedException();
    }
  }
}

class IncidentLockedException implements Exception {
  const IncidentLockedException();

  @override
  String toString() =>
      'This report is already being handled by staff and can no longer be changed.';
}
