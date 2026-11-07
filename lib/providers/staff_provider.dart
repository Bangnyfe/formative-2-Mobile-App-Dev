import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import 'incident_filters.dart';

enum StaffSort { newest, mostAffected }

/// Staff-only tools: filters and sorting for the Manage tab, and the status
/// update action. The reports themselves come from IncidentProvider.
class StaffProvider extends ChangeNotifier with IncidentFilters {
  StaffProvider({IncidentService? service})
    : _service = service ?? IncidentService();

  final IncidentService _service;

  AppUser? _staff;
  StaffSort _sort = StaffSort.newest;

  StaffSort get sort => _sort;

  /// Runs during a build (from the ProxyProvider), so no notifyListeners().
  void updateUser(AppUser? user) {
    final staff = (user != null && user.isStaff) ? user : null;
    if (staff?.uid != _staff?.uid) {
      resetFilters();
      _sort = StaffSort.newest;
    }
    _staff = staff;
  }

  void setSort(StaffSort sort) {
    _sort = sort;
    notifyListeners();
  }

  List<Incident> visibleIncidents(List<Incident> all) {
    final list = applyFilters(all);
    if (_sort == StaffSort.mostAffected) {
      list.sort((a, b) {
        final byCount = b.affectedCount.compareTo(a.affectedCount);
        return byCount != 0 ? byCount : b.createdAt.compareTo(a.createdAt);
      });
    }
    return list;
  }

  /// Returns an error message, or null on success.
  Future<String?> updateStatus({
    required Incident incident,
    required IncidentStatus status,
    String? note,
  }) async {
    final staff = _staff;
    if (staff == null) return 'Only campus staff can update a report.';
    if (status == incident.status) return 'The report already has this status.';

    try {
      await _service.updateStatus(
        id: incident.id,
        status: status,
        changedBy: staff.name,
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      );
      return null;
    } catch (_) {
      return 'Could not update the status. Check your connection.';
    }
  }
}
