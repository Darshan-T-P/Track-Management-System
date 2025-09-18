import 'package:flutter_test/flutter_test.dart';
import 'package:tms/core/storage/token_storage.dart';
import 'package:tms/data/models/auth_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Authentication System Tests', () {
    test('DeviceInfoHelper should return valid device info', () {
      final deviceInfo = DeviceInfoHelper.getDeviceInfo();

      expect(deviceInfo, isNotNull);
      expect(deviceInfo['platform'], equals('flutter'));
      expect(deviceInfo['timestamp'], isNotNull);
      expect(deviceInfo['version'], equals('1.0.0'));
    });

    test('SignupRequest should serialize to JSON correctly', () {
      final request = SignupRequest(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
        phone: '+1234567890',
        role: 'operator',
        zoneId: 'zone_123',
        divisionId: 'div_456',
        stationId: 'station_789',
        deviceInfo: DeviceInfoHelper.getDeviceInfo(),
      );

      final json = request.toJson();

      expect(json['name'], equals('Test User'));
      expect(json['email'], equals('test@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['confirmPassword'], equals('password123'));
      expect(json['phone'], equals('+1234567890'));
      expect(json['role'], equals('operator'));
      expect(json['zoneId'], equals('zone_123'));
      expect(json['divisionId'], equals('div_456'));
      expect(json['stationId'], equals('station_789'));
      expect(json['deviceInfo'], isNotNull);
    });

    test('LoginRequest should serialize to JSON correctly', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
        deviceInfo: DeviceInfoHelper.getDeviceInfo(),
      );

      final json = request.toJson();

      expect(json['email'], equals('test@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['deviceInfo'], isNotNull);
    });

    test('AuthResponse should deserialize from JSON correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'test_token_123',
          'refreshToken': 'refresh_token_123',
          'expiresAt': '2025-12-31T23:59:59Z',
          'user': {
            'id': 'user_123',
            'name': 'Test User',
            'email': 'test@example.com',
            'phone': '+1234567890',
            'role': 'operator',
            'zoneId': 'zone_123',
            'divisionId': 'div_456',
            'stationId': 'station_789',
            'isEmailVerified': true,
            'createdAt': '2025-01-01T00:00:00Z',
            'updatedAt': '2025-01-01T00:00:00Z',
          },
        },
      };

      final response = AuthResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, equals('Login successful'));
      expect(response.data, isNotNull);
      expect(response.data!.token, equals('test_token_123'));
      expect(response.data!.refreshToken, equals('refresh_token_123'));
      expect(response.data!.expiresAt, equals('2025-12-31T23:59:59Z'));
      expect(response.data!.user, isNotNull);
      expect(response.data!.user!.name, equals('Test User'));
      expect(response.data!.user!.email, equals('test@example.com'));
    });

    test('ApiResponse should deserialize from JSON correctly', () {
      final json = {
        'success': true,
        'message': 'Operation successful',
        'data': {'key': 'value'},
      };

      final response = ApiResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, equals('Operation successful'));
      expect(response.data, isNotNull);
      expect(response.data!['key'], equals('value'));
    });

    test('RefreshTokenRequest should serialize to JSON correctly', () {
      final request = RefreshTokenRequest(refreshToken: 'refresh_token_123');
      final json = request.toJson();

      expect(json['refreshToken'], equals('refresh_token_123'));
    });

    test('RefreshTokenResponse should deserialize from JSON correctly', () {
      final json = {
        'success': true,
        'message': 'Token refreshed',
        'data': {'token': 'new_token_123', 'expiresAt': '2025-12-31T23:59:59Z'},
      };

      final response = RefreshTokenResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, equals('Token refreshed'));
      expect(response.data, isNotNull);
      expect(response.data!.token, equals('new_token_123'));
      expect(response.data!.expiresAt, equals('2025-12-31T23:59:59Z'));
    });
  });

  group('TokenStorage Tests', () {
    test('TokenStorage should handle null values gracefully', () async {
      // Test getting token when none is stored
      final token = await TokenStorage.getToken();
      expect(token, isNull);

      // Test getting refresh token when none is stored
      final refreshToken = await TokenStorage.getRefreshToken();
      expect(refreshToken, isNull);

      // Test getting user data when none is stored
      final userData = await TokenStorage.getUserData();
      expect(userData, isNull);

      // Test checking login status when not logged in
      final isLoggedIn = await TokenStorage.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });

    test('TokenStorage should clear auth data', () async {
      // This test ensures clearAuthData doesn't throw errors
      await TokenStorage.clearAuthData();
      expect(true, isTrue); // If no exception is thrown, test passes
    });
  });
}
