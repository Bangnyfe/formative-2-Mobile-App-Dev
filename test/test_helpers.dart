import 'package:formative_2_mobile_app_dev/models/incident.dart';
import 'package:formative_2_mobile_app_dev/models/incident_category.dart';
import 'package:formative_2_mobile_app_dev/models/incident_status.dart';

Incident makeIncident({
  String id = 'i1',
  String title = 'Projector not working',
  String description = 'The projector shows no signal with any laptop.',
  String location = 'Learning Commons, Egypt',
  IncidentCategory category = IncidentCategory.facilities,
  IncidentStatus status = IncidentStatus.submitted,
  String reporterId = 'reporter',
  bool isAnonymous = false,
  List<String> affectedUserIds = const [],
  List<StatusChange> statusHistory = const [],
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime(2026, 11, 1);
  return Incident(
    id: id,
    title: title,
    description: description,
    category: category,
    location: location,
    status: status,
    reporterId: reporterId,
    reporterName: 'Amina Hassan',
    isAnonymous: isAnonymous,
    createdAt: created,
    updatedAt: created,
    affectedUserIds: affectedUserIds,
    statusHistory: statusHistory,
  );
}
