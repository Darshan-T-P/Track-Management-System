import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NetworkUtils {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (kDebugMode) {
          print('No network connectivity');
        }
        return false;
      }

      // Try multiple connectivity tests
      final tests = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        'http://httpbin.org/get',
      ];

      for (final url in tests) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            if (kDebugMode) {
              print('Internet connectivity confirmed via $url');
            }
            return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to reach $url: $e');
          }
          continue;
        }
      }

      if (kDebugMode) {
        print('All internet connectivity tests failed');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Internet connectivity check failed: $e');
      }
      return false;
    }
  }

  /// Check if the API server is reachable
  static Future<bool> isApiServerReachable() async {
    try {
      final response = await http
          .get(Uri.parse('http://62.72.59.3:8000/api/health'))
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('API server health check: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      // Server is reachable if we get any response (even 401 means server is up)
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      if (kDebugMode) {
        print('API server health check failed: $e');
      }
      return false;
    }
  }

  /// Test the specific API endpoint
  static Future<Map<String, dynamic>?> testApiEndpoint(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('http://62.72.59.3:8000/api$endpoint'))
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('API endpoint test ($endpoint): ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      return {
        'statusCode': response.statusCode,
        'body': response.body,
        'success': response.statusCode == 200,
        'requiresAuth': response.statusCode == 401,
      };
    } catch (e) {
      if (kDebugMode) {
        print('API endpoint test failed ($endpoint): $e');
      }
      return {
        'statusCode': 0,
        'body': e.toString(),
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test signup endpoint specifically
  static Future<Map<String, dynamic>?> testSignupEndpoint() async {
    try {
      final testData = {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'Password123!',
        'confirmPassword': 'Password123!',
        'phone': '1234567890',
        'role': 'operator',
        'zoneId': 'zone_123',
        'divisionId': 'div_456',
        'stationId': 'station_789',
        'deviceInfo': {
          'platform': 'flutter',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      final response = await http
          .post(
            Uri.parse('http://62.72.59.3:8000/api/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(testData),
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Signup endpoint test: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      return {
        'statusCode': response.statusCode,
        'body': response.body,
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'requiresAuth': response.statusCode == 401,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Signup endpoint test failed: $e');
      }
      return {
        'statusCode': 0,
        'body': e.toString(),
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get detailed network status
  static Future<Map<String, dynamic>> getNetworkStatus() async {
    final hasInternet = await hasInternetConnection();
    final isServerReachable = await isApiServerReachable();
    final connectivityResult = await Connectivity().checkConnectivity();

    return {
      'hasInternet': hasInternet,
      'isServerReachable': isServerReachable,
      'connectivityType': connectivityResult.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Test basic network connectivity without external dependencies
  static Future<bool> testBasicConnectivity() async {
    try {
      // Test local connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Test if we can make any HTTP request
      final response = await http
          .get(Uri.parse('http://62.72.59.3:8000/api/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode >= 200;
    } catch (e) {
      if (kDebugMode) {
        print('Basic connectivity test failed: $e');
      }
      return false;
    }
  }
}