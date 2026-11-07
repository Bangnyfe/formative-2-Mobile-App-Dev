import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import 'incident_filters.dart';

/// All campus reports for staff, plus the status update action.
/// Only listens to Firestore while the signed-in user is staff.
class StaffProvider extends ChangeNotifier with IncidentFilters {
  StaffProvider({IncidentService? service})
    : _service = service ?? IncidentService();

  final IncidentService _service;

  StreamSubscription<List<Incident>>? _sub;
  AppUser? _staff;

  List<Incident> _allIncidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Incident> get allIncidents => _allIncidents;
  List<Incident> get filteredIncidents => applyFilters(_allIncidents);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int countByStatus(IncidentStatus status) =>
      _allIncidents.where((i) => i.status == status).length;

  /// Runs during a build (from the ProxyProvider), so no notifyListeners().
  void updateUser(AppUser? user) {
    final staff = (user != null && user.isStaff) ? user : null;
    final previousUid = _staff?.uid;
    _staff = staff;
    if (staff?.uid == previousUid) return;

    _sub?.cancel();
    _allIncidents = [];
    _errorMessage = null;
    resetFilters();

    if (staff == null) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    _sub = _service.watchAllIncidents().listen(
      (incidents) {
        _allIncidents = incidents;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'Could not load campus reports.';
        notifyListeners();
      },
    );
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
