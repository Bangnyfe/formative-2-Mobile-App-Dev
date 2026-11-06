import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';

/// State for the "Report an Incident" form, scoped to that screen.
class ReportFormProvider extends ChangeNotifier {
  ReportFormProvider({IncidentService? incidentService})
    : _service = incidentService ?? IncidentService();

  final IncidentService _service;

  IncidentCategory? _category;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _showCategoryError = false;
  String? _errorMessage;

  IncidentCategory? get category => _category;
  bool get isAnonymous => _isAnonymous;
  bool get isSubmitting => _isSubmitting;
  bool get showCategoryError => _showCategoryError;
  String? get errorMessage => _errorMessage;

  void selectCategory(IncidentCategory category) {
    _category = category;
    _showCategoryError = false;
    notifyListeners();
  }

  void setAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  /// The category isn't a form field, so it's validated here alongside the
  /// form's own validation.
  bool validateCategory() {
    _showCategoryError = _category == null;
    notifyListeners();
    return !_showCategoryError;
  }

  Future<bool> submit({
    required String title,
    required String description,
    required String location,
    required AppUser reporter,
  }) async {
    if (!validateCategory()) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final now = DateTime.now();
    final incident = Incident(
      id: '',
      title: title.trim(),
      description: description.trim(),
      category: _category!,
      location: location.trim(),
      status: IncidentStatus.submitted,
      reporterId: reporter.uid,
      reporterName: reporter.name,
      isAnonymous: _isAnonymous,
      createdAt: now,
      updatedAt: now,
      statusHistory: [
        StatusChange(
          status: IncidentStatus.submitted,
          changedBy: reporter.name,
          at: now,
          note: 'Report submitted',
        ),
      ],
    );

    try {
      await _service.createIncident(incident);
      return true;
    } catch (_) {
      _errorMessage = 'Could not submit your report. Check your connection.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
