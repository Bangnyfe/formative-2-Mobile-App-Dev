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
}
