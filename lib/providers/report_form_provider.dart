import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';

/// State for the report form, used both to create a new report and to edit
/// an existing one. Scoped to the form screen.
class ReportFormProvider extends ChangeNotifier {
  ReportFormProvider({
    IncidentService? incidentService,
    StorageService? storageService,
    Incident? existing,
  }) : _service = incidentService ?? IncidentService(),
       _storage = storageService ?? StorageService(),
       _existing = existing,
       _category = existing?.category,
       _isAnonymous = existing?.isAnonymous ?? false,
       _existingPhotoUrl = existing?.photoUrl;

  final IncidentService _service;
  final StorageService _storage;
  final Incident? _existing;

  File? _newPhoto;
  String? _existingPhotoUrl;

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
  File? get newPhoto => _newPhoto;
  String? get existingPhotoUrl => _existingPhotoUrl;
  bool get hasPhoto => _newPhoto != null || _existingPhotoUrl != null;

  /// Returns an error message if the photo is too large, otherwise null.
  Future<String?> setPhoto(File file) async {
    if (await file.length() > AppConstants.maxPhotoBytes) {
      return 'Photo is too large. Please choose one under 5 MB.';
    }
    _newPhoto = file;
    notifyListeners();
    return null;
  }

  void removePhoto() {
    _newPhoto = null;
    _existingPhotoUrl = null;
    notifyListeners();
  }

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
      final photoUrl = _newPhoto != null
          ? await _storage.uploadIncidentPhoto(_newPhoto!)
          : _existingPhotoUrl;

      if (isEditing) {
        await _service.updateIncidentDetails(
          id: _existing!.id,
          title: title.trim(),
          description: description.trim(),
          category: _category!,
          location: location.trim(),
          isAnonymous: _isAnonymous,
          photoUrl: photoUrl,
        );
      } else {
        await _service.createIncident(
          _buildNewIncident(title, description, location, reporter, photoUrl),
        );
      }
      return true;
    } on IncidentLockedException catch (e) {
      _errorMessage = e.toString();
      return false;
    } on StorageException catch (e) {
      _errorMessage = e.message;
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
    String? photoUrl,
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
      photoUrl: photoUrl,
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
