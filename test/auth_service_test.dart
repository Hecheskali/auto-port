import 'package:auto_port/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService.mapFirebaseError', () {
    test('maps invalid-email', () {
      expect(
        AuthService.mapFirebaseError('invalid-email'),
        'The email address is not valid.',
      );
    });

    test('maps user-not-found', () {
      expect(
        AuthService.mapFirebaseError('user-not-found'),
        'No account was found with this email address.',
      );
    });

    test('maps wrong-password and invalid-credential', () {
      expect(
        AuthService.mapFirebaseError('wrong-password'),
        'The email or password is incorrect.',
      );
      expect(
        AuthService.mapFirebaseError('invalid-credential'),
        'The email or password is incorrect.',
      );
    });

    test('maps fallback error', () {
      expect(
        AuthService.mapFirebaseError('unknown-error-code'),
        'Authentication failed. Please try again.',
      );
    });
  });
}
