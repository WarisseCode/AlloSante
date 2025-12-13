import 'package:flutter_test/flutter_test.dart';
import 'package:allosante_benin/features/auth/data/repositories/auth_repository.dart';

void main() {
  late AuthRepository authRepository;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    authRepository = AuthRepository();
  });

  group('AuthRepository', () {
    group('login', () {
      test('should return User when credentials are valid', () async {
        // Arrange
        const email = 'test@allosante.bj';
        const password = 'password123';

        // Act
        final result = await authRepository.login(
          email: email,
          password: password,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (user) {
            expect(user.email, equals(email));
            expect(user.firstName, isNotEmpty);
            expect(user.lastName, isNotEmpty);
          },
        );
      });

      test('should return User for any valid email format', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'securePassword123';

        // Act
        final result = await authRepository.login(
          email: email,
          password: password,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (user) {
            expect(user.email, equals(email));
          },
        );
      });

      test('should return failure for invalid credentials', () async {
        // Arrange
        const email = 'invalid';
        const password = '123'; // Too short

        // Act
        final result = await authRepository.login(
          email: email,
          password: password,
        );

        // Assert
        result.fold(
          (failure) {
            expect(failure.code, equals('invalid_credentials'));
          },
          (user) => fail('Expected Left but got Right'),
        );
      });
    });

    group('register', () {
      test('should create new user successfully', () async {
        // Arrange
        const email = 'newuser@test.com';
        const password = 'password123';
        const firstName = 'Test';
        const lastName = 'User';
        const phone = '97000000';

        // Act
        final result = await authRepository.register(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (user) {
            expect(user.email, equals(email));
            expect(user.firstName, equals(firstName));
            expect(user.lastName, equals(lastName));
            expect(user.phone, equals(phone));
            expect(user.isVerified, isFalse);
          },
        );
      });
    });

    group('sendOtp', () {
      test('should send OTP successfully', () async {
        // Arrange
        const phone = '97000000';

        // Act
        final result = await authRepository.sendOtp(phone);

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (success) {
            expect(success, isTrue);
          },
        );
      });
    });

    group('verifyOtp', () {
      test('should verify OTP and return credentials for valid code', () async {
        // Arrange
        const phone = '97000000';
        const validOtp = '123456';

        // Act
        final result = await authRepository.verifyOtp(
          phone: phone,
          otp: validOtp,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (credentials) {
            expect(credentials.accessToken, isNotEmpty);
            expect(credentials.refreshToken, isNotEmpty);
            expect(credentials.user, isNotNull);
            expect(credentials.user.isVerified, isTrue);
          },
        );
      });

      test('should return failure for invalid OTP', () async {
        // Arrange
        const phone = '97000000';
        const invalidOtp = '000000';

        // Act
        final result = await authRepository.verifyOtp(
          phone: phone,
          otp: invalidOtp,
        );

        // Assert
        result.fold(
          (failure) {
            expect(failure.code, equals('invalid_otp'));
          },
          (credentials) => fail('Expected Left but got Right'),
        );
      });
    });

    group('requestPasswordReset', () {
      test('should request password reset successfully', () async {
        // Arrange
        const email = 'test@allosante.bj';

        // Act
        final result = await authRepository.requestPasswordReset(email);

        // Assert
        result.fold(
          (failure) => fail('Expected Right but got Left: ${failure.message}'),
          (success) {
            expect(success, isTrue);
          },
        );
      });
    });
  });

  group('AuthFailure', () {
    test('should create correct failure messages', () {
      expect(
        const AuthFailure.invalidCredentials().message,
        contains('incorrect'),
      );
      expect(
        const AuthFailure.invalidOtp().message,
        contains('OTP'),
      );
      expect(
        const AuthFailure.otpExpired().message,
        contains('expiré'),
      );
      expect(
        const AuthFailure.notAuthenticated().message,
        contains('authentifié'),
      );
      expect(
        const AuthFailure.networkError().message,
        contains('réseau'),
      );
    });
  });
}
