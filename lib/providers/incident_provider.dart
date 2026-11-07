import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import 'incident_filters.dart';

enum FeedScope { campus, mine }

/// Keeps every campus report in sync with Firestore. "My reports" is the same
/// list filtered to the signed-in user, so only one stream is needed.
class IncidentProvider extends ChangeNotifier with IncidentFilters {
  IncidentProvider({IncidentService? service})
    : _service = service ?? IncidentService();

  final IncidentService _service;

  StreamSubscription<List<Incident>>? _sub;
  String? _uid;

  List<Incident> _allIncidents = [];
  bool _isLoading = false;
  String? _errorMessage;
  FeedScope _scope = FeedScope.campus;

  List<Incident> get allIncidents => _allIncidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FeedScope get scope => _scope;

  List<Incident> get myIncidents =>
      _allIncidents.where((i) => i.reporterId == _uid).toList();

  List<Incident> get recentIncidents => myIncidents.take(3).toList();

  List<Incident> get scopedIncidents =>
      _scope == FeedScope.mine ? myIncidents : _allIncidents;

  List<Incident> get filteredIncidents => applyFilters(scopedIncidents);

  int countByStatus(IncidentStatus status) =>
      myIncidents.where((i) => i.status == status).length;

  int get activeCount =>
      countByStatus(IncidentStatus.inReview) +
      countByStatus(IncidentStatus.inProgress);

  void setScope(FeedScope scope) {
    if (_scope == scope) return;
    _scope = scope;
    notifyListeners();
  }

  /// Called by the ProxyProvider whenever AuthProvider changes. It runs during
  /// a build, so it must not call notifyListeners() directly.
  void updateUser(AppUser? user) {
    if (user?.uid == _uid) return;
    _uid = user?.uid;
    _sub?.cancel();
    _allIncidents = [];
    _errorMessage = null;
    _scope = FeedScope.campus;
    resetFilters();

    if (_uid == null) {
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
        _errorMessage = 'Could not load reports.';
        notifyListeners();
      },
    );
  }

  Stream<Incident?> watchIncident(String id) => _service.watchIncident(id);

  /// Returns an error message, or null on success.
  Future<String?> toggleNoticed(Incident incident) async {
    final uid = _uid;
    if (uid == null || incident.reporterId == uid) return null;
    if (incident.status.isClosed) {
      return 'This report is already closed.';
    }
    try {
      await _service.setNoticed(
        id: incident.id,
        uid: uid,
        noticed: !incident.isNoticedBy(uid),
      );
      return null;
    } catch (_) {
      return 'Could not update. Check your connection.';
    }
  }

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
