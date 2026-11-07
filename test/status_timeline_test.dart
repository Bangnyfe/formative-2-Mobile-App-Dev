import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formative_2_mobile_app_dev/models/incident.dart';
import 'package:formative_2_mobile_app_dev/models/incident_status.dart';
import 'package:formative_2_mobile_app_dev/widgets/status_timeline.dart';

import 'test_helpers.dart';

void main() {
  Future<void> pumpTimeline(WidgetTester tester, Incident incident) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StatusTimeline(incident: incident)),
      ),
    );
  }

  testWidgets('shows all four stages', (tester) async {
    await pumpTimeline(tester, makeIncident());

    for (final label in ['Submitted', 'In Review', 'In Progress', 'Resolved']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.textContaining('rejected'), findsNothing);
  });

  testWidgets('shows a notice for rejected reports', (tester) async {
    final incident = makeIncident(
      status: IncidentStatus.rejected,
      statusHistory: [
        StatusChange(
          status: IncidentStatus.submitted,
          changedBy: 'Reporter',
          at: DateTime(2026, 11, 1),
        ),
        StatusChange(
          status: IncidentStatus.rejected,
          changedBy: 'Grace Uwase',
          at: DateTime(2026, 11, 2),
          note: 'Duplicate report',
        ),
      ],
    );
    await pumpTimeline(tester, incident);

    expect(
      find.text('This report was rejected by campus staff.'),
      findsOneWidget,
    );
  });
}
