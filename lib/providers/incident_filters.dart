import 'package:flutter/foundation.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

/// Search and filter state shared by the student and staff report lists.
mixin IncidentFilters on ChangeNotifier {
  String _searchQuery = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;

  String get searchQuery => _searchQuery;
  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != null ||
      _categoryFilter != null;

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
    resetFilters();
    notifyListeners();
  }

  /// Resets without notifying, for use while a provider is being updated.
  void resetFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
  }

  List<Incident> applyFilters(List<Incident> incidents) {
    final query = _searchQuery.toLowerCase();
    return incidents.where((incident) {
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
}
