import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';

/// State for the report form, used both to create a new report and to edit
/// an existing one. Scoped to the form screen.
class ReportFormProvider extends ChangeNotifier {
  ReportFormProvider({IncidentService? incidentService, Incident? existing})
    : _service = incidentService ?? IncidentService(),
      _existing = existing,
      _category = existing?.category,
      _isAnonymous = existing?.isAnonymous ?? false;

  final IncidentService _service;
  final Incident? _existing;

  IncidentCategory? _category;
  bool _isAnonymous;
  bool _isSubmitting = false;
  bool _showCategoryError = false;
  String? _errorMessage;

  bool get isEditing => _existing != null;
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

    try {
      if (isEditing) {
        await _service.updateIncidentDetails(
          id: _existing!.id,
          title: title.trim(),
          description: description.trim(),
          category: _category!,
          location: location.trim(),
          isAnonymous: _isAnonymous,
        );
      } else {
        await _service.createIncident(
          _buildNewIncident(title, description, location, reporter),
        );
      }
      return true;
    } on IncidentLockedException catch (e) {
      _errorMessage = e.toString();
      return false;
    } catch (_) {
      _errorMessage = isEditing
          ? 'Could not save your changes. Check your connection.'
          : 'Could not submit your report. Check your connection.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Incident _buildNewIncident(
    String title,
    String description,
    String location,
    AppUser reporter,
  ) {
    final now = DateTime.now();
    return Incident(
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
      // "Reporter" rather than the name, so anonymity can be switched on or
      // off later without the timeline giving the name away.
      statusHistory: [
        StatusChange(
          status: IncidentStatus.submitted,
          changedBy: 'Reporter',
          at: now,
          note: 'Report submitted',
        ),
      ],
    );
  }
}
