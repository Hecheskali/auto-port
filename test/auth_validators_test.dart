import 'package:auto_port/auth/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.email', () {
    test('returns error for empty email', () {
      expect(AuthValidators.email('  '), 'Enter your email address.');
    });

    test('returns error for malformed email', () {
      expect(
        AuthValidators.email('invalid-email'),
        'Enter a valid email address.',
      );
    });

    test('accepts valid email', () {
      expect(AuthValidators.email('operator@autoport.io'), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('returns error for empty password', () {
      expect(AuthValidators.password(''), 'Enter your password.');
    });

    test('accepts non-empty password', () {
      expect(AuthValidators.password('secret123'), isNull);
    });
  });
}
