import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';

/// Keeps the signed-in user's reports in sync with Firestore and applies
/// search and filters for the reports list.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider({IncidentService? service})
    : _service = service ?? IncidentService();

  final IncidentService _service;

  StreamSubscription<List<Incident>>? _sub;
  String? _uid;

  List<Incident> _myIncidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;

  List<Incident> get myIncidents => _myIncidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != null ||
      _categoryFilter != null;

  List<Incident> get recentIncidents => _myIncidents.take(3).toList();

  int countByStatus(IncidentStatus status) =>
      _myIncidents.where((i) => i.status == status).length;

  int get activeCount =>
      countByStatus(IncidentStatus.inReview) +
      countByStatus(IncidentStatus.inProgress);

  List<Incident> get filteredIncidents {
    final query = _searchQuery.toLowerCase();
    return _myIncidents.where((incident) {
      if (_statusFilter != null && incident.status != _statusFilter) {
        return false;
      }
      if (_categoryFilter != null && incident.category != _categoryFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return incident.title.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query);
    }).toList();
  }

  /// Called by the ProxyProvider whenever AuthProvider changes. It runs during
  /// a build, so it must not call notifyListeners() directly.
  void updateUser(AppUser? user) {
    if (user?.uid == _uid) return;
    _uid = user?.uid;
    _sub?.cancel();
    _myIncidents = [];
    _errorMessage = null;
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;

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

  void setSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
