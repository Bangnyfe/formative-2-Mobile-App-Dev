import 'package:flutter_test/flutter_test.dart';
import 'package:formative_2_mobile_app_dev/models/incident_category.dart';
import 'package:formative_2_mobile_app_dev/models/incident_status.dart';

import 'test_helpers.dart';

void main() {
  group('Incident', () {
    test('affected count includes the reporter', () {
      expect(makeIncident().affectedCount, 1);
      expect(makeIncident(affectedUserIds: ['a', 'b']).affectedCount, 3);
    });

    test('knows who noticed it', () {
      final incident = makeIncident(affectedUserIds: ['a']);
      expect(incident.isNoticedBy('a'), isTrue);
      expect(incident.isNoticedBy('b'), isFalse);
    });

    test('is only editable while submitted', () {
      expect(makeIncident().isEditable, isTrue);
      expect(makeIncident(status: IncidentStatus.inReview).isEditable, isFalse);
    });

    test('hides the reporter name when anonymous', () {
      expect(makeIncident().displayReporter, 'Amina Hassan');
      expect(makeIncident(isAnonymous: true).displayReporter, 'Anonymous');
    });
  });

  group('IncidentStatus', () {
    test('resolved and rejected are closed', () {
      expect(IncidentStatus.resolved.isClosed, isTrue);
      expect(IncidentStatus.rejected.isClosed, isTrue);
      expect(IncidentStatus.inProgress.isClosed, isFalse);
    });

    test('unknown values fall back safely', () {
      expect(IncidentStatus.fromName('unknown'), IncidentStatus.submitted);
      expect(IncidentCategory.fromName(null), IncidentCategory.other);
    });
  });
}
