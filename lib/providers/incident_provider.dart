import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import 'incident_filters.dart';

/// Keeps the signed-in user's own reports in sync with Firestore.
class IncidentProvider extends ChangeNotifier with IncidentFilters {
  IncidentProvider({IncidentService? service})
    : _service = service ?? IncidentService();

  final IncidentService _service;

  StreamSubscription<List<Incident>>? _sub;
  String? _uid;

  List<Incident> _myIncidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Incident> get myIncidents => _myIncidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Incident> get recentIncidents => _myIncidents.take(3).toList();

  List<Incident> get filteredIncidents => applyFilters(_myIncidents);

  int countByStatus(IncidentStatus status) =>
      _myIncidents.where((i) => i.status == status).length;

  int get activeCount =>
      countByStatus(IncidentStatus.inReview) +
      countByStatus(IncidentStatus.inProgress);

  /// Called by the ProxyProvider whenever AuthProvider changes. It runs during
  /// a build, so it must not call notifyListeners() directly.
  void updateUser(AppUser? user) {
    if (user?.uid == _uid) return;
    _uid = user?.uid;
    _sub?.cancel();
    _myIncidents = [];
    _errorMessage = null;
    resetFilters();

    if (_uid == null) {
      _isLoading = false;
      return;
    }

    _isLoading = true;
    _sub = _service
        .watchUserIncidents(_uid!)
        .listen(
          (incidents) {
            _myIncidents = incidents;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Could not load your reports.';
            notifyListeners();
          },
        );
  }

  Stream<Incident?> watchIncident(String id) => _service.watchIncident(id);

  /// Returns an error message, or null when the report was deleted.
  Future<String?> deleteIncident(String id) async {
    try {
      await _service.deleteIncident(id);
      return null;
    } on IncidentLockedException catch (e) {
      return e.toString();
    } catch (_) {
      return 'Could not delete the report. Check your connection.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
