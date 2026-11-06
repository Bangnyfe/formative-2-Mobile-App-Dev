import 'package:flutter_test/flutter_test.dart';
import 'package:formative_2_mobile_app_dev/core/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts ALU student and staff emails', () {
      expect(Validators.email('a.daib@alustudent.com'), isNull);
      expect(Validators.email('j.doe@alueducation.com'), isNull);
      expect(Validators.email('  Mixed.Case@ALUSTUDENT.com '), isNull);
    });

    test('rejects non-ALU domains', () {
      expect(Validators.email('someone@gmail.com'), isNotNull);
      expect(Validators.email('someone@alustudent.com.evil.io'), isNotNull);
    });

    test('rejects empty and malformed input', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('requires 8+ characters with letters and numbers', () {
      expect(Validators.password('abc123'), isNotNull);
      expect(Validators.password('abcdefgh'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('campus2026'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match the original password', () {
      expect(Validators.confirmPassword('campus2026', 'campus2026'), isNull);
      expect(Validators.confirmPassword('campus2025', 'campus2026'), isNotNull);
    });
  });

  group('Incident validators', () {
    test('title needs at least 5 characters', () {
      expect(Validators.incidentTitle('Leak'), isNotNull);
      expect(Validators.incidentTitle('Water leak'), isNull);
    });

    test('description needs at least 15 characters', () {
      expect(Validators.incidentDescription('Broken tap'), isNotNull);
      expect(
        Validators.incidentDescription('The tap in room 204 is broken.'),
        isNull,
      );
    });
  });

  group('Validators.name', () {
    test('requires a non-empty name', () {
      expect(Validators.name('  '), isNotNull);
      expect(Validators.name('Amina Hassan'), isNull);
    });
  });
}
