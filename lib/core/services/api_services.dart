// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';
// import '../storage/token_storage.dart';
// import '../utils/network_utils.dart';
// import '../../data/models/auth_models.dart';

// class ApiService {
//   static const String baseUrl =
//       'http://62.72.59.3:8000/api'; // Your backend base URL
//   static const Duration timeout = Duration(seconds: 30); // Adjust as needed

//   // Helper method to make GET requests
//   static Future<Map<String, dynamic>?> get(
//     String endpoint, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? queryParams,
//   }) async {
//     final uri = Uri.parse(
//       baseUrl + endpoint,
//     ).replace(queryParameters: queryParams);
//     try {
//       final response = await http
//           .get(
//             uri,
//             headers: {
//               'Content-Type': 'application/json',
//               ...?headers, // Merge custom headers (e.g., for auth tokens)
//             },
//           )
//           .timeout(timeout);

//       return _handleResponse(response);
//     } catch (e) {
//       if (kDebugMode) {
//         print('GET error for $endpoint: $e');
//       }
//       return null;
//     }
//   }

//   // Helper method to make POST requests
//   static Future<Map<String, dynamic>?> post(
//     String endpoint, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       // Test basic connectivity first (skip external internet check)
//       if (!await NetworkUtils.testBasicConnectivity()) {
//         return {
//           'success': false,
//           'message': 'Cannot reach the server. Please check your network connection.',
//           'error': 'NETWORK_ERROR',
//         };
//       }

//       final response = await http
//           .post(
//             Uri.parse(baseUrl + endpoint),
//             headers: {'Content-Type': 'application/json', ...?headers},
//             body: jsonEncode(body),
//           )
//           .timeout(timeout);

//       return _handleResponse(response);
//     } catch (e) {
//       if (kDebugMode) {
//         print('POST error for $endpoint: $e');
//       }

//       // Return structured error response instead of null
//       String errorMessage = 'Network error occurred';
//       if (e.toString().contains('Failed to fetch')) {
//         errorMessage = 'Cannot connect to server. Please check your internet connection.';
//       } else if (e.toString().contains('TimeoutException')) {
//         errorMessage = 'Request timed out. Please try again.';
//       } else {
//         errorMessage = 'Network error: ${e.toString()}';
//       }

//       return {
//         'success': false,
//         'message': errorMessage,
//         'error': 'NETWORK_ERROR',
//       };
//     }
//   }

//   // Add similar helpers for PUT, DELETE, etc., as needed
//   static Future<Map<String, dynamic>?> put(
//     String endpoint, {
//     Map<String, String>? headers,
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       final response = await http
//           .put(
//             Uri.parse(baseUrl + endpoint),
//             headers: {'Content-Type': 'application/json', ...?headers},
//             body: jsonEncode(body),
//           )
//           .timeout(timeout);

//       return _handleResponse(response);
//     } catch (e) {
//       if (kDebugMode) {
//         print('PUT error for $endpoint: $e');
//       }
//       return null;
//     }
//   }

//   static Future<Map<String, dynamic>?> delete(
//     String endpoint, {
//     Map<String, String>? headers,
//   }) async {
//     try {
//       final response = await http
//           .delete(
//             Uri.parse(baseUrl + endpoint),
//             headers: {'Content-Type': 'application/json', ...?headers},
//           )
//           .timeout(timeout);

//       return _handleResponse(response);
//     } catch (e) {
//       if (kDebugMode) {
//         print('DELETE error for $endpoint: $e');
//       }
//       return null;
//     }
//   }

//   // Common response handler
//   static Map<String, dynamic>? _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       // Success: Parse JSON if body is not empty
//       if (response.body.isNotEmpty) {
//         return jsonDecode(response.body);
//       }
//       return {'message': 'Success'}; // For empty responses
//     } else {
//       // Error: Parse error body if available
//       final errorBody = response.body.isNotEmpty
//           ? jsonDecode(response.body)
//           : null;
//       if (kDebugMode) {
//         print(
//           'API Error ${response.statusCode}: ${errorBody ?? response.reasonPhrase}',
//         );
//       }
//       return null; // Or throw an exception based on your error handling
//     }
//   }

//   // ==================== AUTHENTICATION METHODS ====================

//   /// Sign up a new user
//   static Future<AuthResponse?> signup(SignupRequest request) async {
//     try {
//       final response = await post('/auth/signup', body: request.toJson());

//       if (response != null) {
//         return AuthResponse.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Signup error: $e');
//       }
//       return null;
//     }
//   }

//   /// Login user
//   static Future<AuthResponse?> login(LoginRequest request) async {
//     try {
//       final response = await post('/auth/login', body: request.toJson());

//       if (response != null) {
//         final authResponse = AuthResponse.fromJson(response);

//         // Save tokens and user data if login successful
//         if (authResponse.success && authResponse.data != null) {
//           if (authResponse.data!.token != null) {
//             await TokenStorage.saveToken(authResponse.data!.token!);
//           }
//           if (authResponse.data!.refreshToken != null) {
//             await TokenStorage.saveRefreshToken(
//               authResponse.data!.refreshToken!,
//             );
//           }
//           if (authResponse.data!.expiresAt != null) {
//             await TokenStorage.saveTokenExpiry(authResponse.data!.expiresAt!);
//           }
//           if (authResponse.data!.user != null) {
//             await TokenStorage.saveUserData(authResponse.data!.user!.toJson());
//           }
//         }

//         return authResponse;
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Login error: $e');
//       }
//       return null;
//     }
//   }

//   /// Resend verification email
//   static Future<ApiResponse?> resendVerification(String token) async {
//     try {
//       final response = await post(
//         '/auth/resend-verification',
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response != null) {
//         return ApiResponse.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Resend verification error: $e');
//       }
//       return null;
//     }
//   }

//   /// Verify email with token
//   static Future<ApiResponse?> verifyEmail(String token) async {
//     try {
//       final response = await get(
//         '/auth/verify-email',
//         queryParams: {'token': token},
//       );

//       if (response != null) {
//         return ApiResponse.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Verify email error: $e');
//       }
//       return null;
//     }
//   }

//   /// Forgot password
//   static Future<ApiResponse?> forgotPassword(String email) async {
//     try {
//       final response = await get(
//         '/auth/forgot-password',
//         queryParams: {'email': email},
//       );

//       if (response != null) {
//         return ApiResponse.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Forgot password error: $e');
//       }
//       return null;
//     }
//   }

//   /// Refresh authentication token
//   static Future<AuthResponse?> refreshToken(String refreshToken) async {
//     try {
//       final request = RefreshTokenRequest(refreshToken: refreshToken);
//       final response = await post('/auth/refresh', body: request.toJson());

//       if (response != null) {
//         final authResponse = AuthResponse.fromJson(response);

//         // Save new tokens if refresh successful
//         if (authResponse.success && authResponse.data != null) {
//           if (authResponse.data!.token != null) {
//             await TokenStorage.saveToken(authResponse.data!.token!);
//           }
//           if (authResponse.data!.refreshToken != null) {
//             await TokenStorage.saveRefreshToken(
//               authResponse.data!.refreshToken!,
//             );
//           }
//           if (authResponse.data!.expiresAt != null) {
//             await TokenStorage.saveTokenExpiry(authResponse.data!.expiresAt!);
//           }
//         }

//         return authResponse;
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Refresh token error: $e');
//       }
//       return null;
//     }
//   }

//   /// Logout user
//   static Future<ApiResponse?> logout(String token) async {
//     try {
//       final response = await post(
//         '/auth/logout',
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response != null) {
//         // Clear all stored authentication data
//         await TokenStorage.clearAuthData();
//         return ApiResponse.fromJson(response);
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Logout error: $e');
//       }
//       return null;
//     }
//   }

//   /// Auto-refresh token if expired
//   static Future<String?> getValidToken() async {
//     try {
//       final token = await TokenStorage.getToken();
//       if (token == null) return null;

//       final isExpired = await TokenStorage.isTokenExpired();
//       if (!isExpired) return token;

//       // Token is expired, try to refresh
//       final refreshToken = await TokenStorage.getRefreshToken();
//       if (refreshToken == null) return null;

//       final authResponse = await ApiService.refreshToken(refreshToken);
//       if (authResponse?.success == true && authResponse?.data?.token != null) {
//         return authResponse!.data!.token;
//       }

//       // Refresh failed, clear auth data
//       await TokenStorage.clearAuthData();
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Get valid token error: $e');
//       }
//       return null;
//     }
//   }

//   /// Make authenticated request with auto token refresh
//   static Future<Map<String, dynamic>?> authenticatedRequest(
//     String method,
//     String endpoint, {
//     Map<String, dynamic>? body,
//     Map<String, dynamic>? queryParams,
//   }) async {
//     try {
//       final token = await getValidToken();
//       if (token == null) {
//         if (kDebugMode) {
//           print('No valid token available for authenticated request');
//         }
//         return null;
//       }

//       final headers = {'Authorization': 'Bearer $token'};

//       switch (method.toUpperCase()) {
//         case 'GET':
//           return await get(
//             endpoint,
//             headers: headers,
//             queryParams: queryParams,
//           );
//         case 'POST':
//           return await post(endpoint, headers: headers, body: body);
//         case 'PUT':
//           return await put(endpoint, headers: headers, body: body);
//         case 'DELETE':
//           return await delete(endpoint, headers: headers);
//         default:
//           if (kDebugMode) {
//             print('Unsupported HTTP method: $method');
//           }
//           return null;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Authenticated request error: $e');
//       }
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tms/core/services/storage_services.dart';
import 'package:tms/data/models/auth_models.dart';

class ApiService {
  static const String baseUrl =
      "http://localhost:5000/api"; // for Android emulator
  static final storage = StorageService();

  /// Returns AuthResponse if successful, otherwise throws an exception
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["token"] != null) {
        await storage.write("token", data["token"]);
      }
      return data;
    }
    return jsonDecode(response.body); // For error messages
  }



  static Future<Map<String, dynamic>?> signup(SignupRequest request) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await storage.read("token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/auth/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    }
    return null;
  }

 static Future<Map<String, dynamic>?> getProduct(String uuid) async {
    final token = await storage.read("token");
    final response = await http.get(
      Uri.parse("$baseUrl/products/$uuid"),
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null; // Product not found
    } else {
      debugPrint('Error fetching product: ${response.body}');
      return null;
    }
  }

  /// Add product details after first scan
  static Future<bool> addProductDetails(String uuid, Map<String, dynamic> details) async {
    final token = await storage.read("token");
    final response = await http.post(
      Uri.parse("$baseUrl/products/$uuid/details"),
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(details),
    );
    return response.statusCode == 200;
  }


  static Future<void> logout() async {
    await storage.delete("token");
  } 
}
