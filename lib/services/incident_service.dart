import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/incident.dart';

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

  Stream<Incident?> watchIncident(String id) {
    return _incidents
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Incident.fromDoc(doc) : null);
  }
}
