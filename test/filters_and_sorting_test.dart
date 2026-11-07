import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formative_2_mobile_app_dev/models/incident_category.dart';
import 'package:formative_2_mobile_app_dev/models/incident_status.dart';
import 'package:formative_2_mobile_app_dev/providers/incident_filters.dart';
import 'package:formative_2_mobile_app_dev/providers/staff_provider.dart';

import 'test_helpers.dart';

class _Filters extends ChangeNotifier with IncidentFilters {}

void main() {
  final incidents = [
    makeIncident(id: 'projector'),
    makeIncident(
      id: 'water',
      title: 'No water on second floor',
      location: 'Student Residence',
      category: IncidentCategory.water,
      status: IncidentStatus.resolved,
    ),
    makeIncident(
      id: 'gate',
      title: 'Gate left open at night',
      location: 'Main Gate',
      category: IncidentCategory.safety,
      status: IncidentStatus.inReview,
    ),
  ];

  List<String> ids(List list) => list.map((i) => i.id as String).toList();

  group('IncidentFilters', () {
    test('returns everything with no filters', () {
      expect(_Filters().applyFilters(incidents).length, 3);
    });

    test('filters by status and category', () {
      final filters = _Filters()..setStatusFilter(IncidentStatus.resolved);
      expect(ids(filters.applyFilters(incidents)), ['water']);

      filters
        ..setStatusFilter(null)
        ..setCategoryFilter(IncidentCategory.safety);
      expect(ids(filters.applyFilters(incidents)), ['gate']);
    });

    test('search matches title and location, ignoring case', () {
      final filters = _Filters()..setSearchQuery('RESIDENCE');
      expect(ids(filters.applyFilters(incidents)), ['water']);

      filters.setSearchQuery('egypt');
      expect(ids(filters.applyFilters(incidents)), ['projector']);
    });

    test('clearFilters resets everything', () {
      final filters = _Filters()
        ..setSearchQuery('gate')
        ..setCategoryFilter(IncidentCategory.water);
      expect(filters.hasActiveFilters, isTrue);

      filters.clearFilters();
      expect(filters.hasActiveFilters, isFalse);
      expect(filters.applyFilters(incidents).length, 3);
    });
  });

  group('StaffProvider sorting', () {
    final reports = [
      makeIncident(
        id: 'old-popular',
        affectedUserIds: ['a', 'b'],
        createdAt: DateTime(2026, 10, 1),
      ),
      makeIncident(id: 'new-quiet', createdAt: DateTime(2026, 11, 5)),
      makeIncident(
        id: 'new-popular',
        affectedUserIds: ['a', 'b'],
        createdAt: DateTime(2026, 11, 4),
      ),
    ];

    test('keeps the original order when sorting by newest', () {
      final staff = StaffProvider();
      expect(ids(staff.visibleIncidents(reports)), [
        'old-popular',
        'new-quiet',
        'new-popular',
      ]);
    });

    test('most affected first, newest first on ties', () {
      final staff = StaffProvider()..setSort(StaffSort.mostAffected);
      expect(ids(staff.visibleIncidents(reports)), [
        'new-popular',
        'old-popular',
        'new-quiet',
      ]);
    });
  });
}
