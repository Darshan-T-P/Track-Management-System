# 🔧 Network Troubleshooting Guide

## 🚨 **Current Error: `ClientException: Failed to fetch`**

The error `POST error for /auth/signup: ClientException: Failed to fetch, uri=http://62.72.59.3:8000/api/auth/signup` indicates a network connectivity issue.

---

## 🔍 **Root Causes & Solutions**

### **1. Backend Server Issues**

**Possible Causes:**
- Backend server is down
- Server is not accessible from your network
- Wrong IP address or port
- Firewall blocking the connection

**Solutions:**
```bash
# Test if the server is reachable
ping 62.72.59.3

# Test if the port is open
telnet 62.72.59.3 8000

# Test with curl
curl -X GET http://62.72.59.3:8000/api/health
```

### **2. Network Configuration Issues**

**Possible Causes:**
- No internet connection
- Corporate firewall blocking the request
- VPN issues
- DNS resolution problems

**Solutions:**
```dart
// Add network connectivity check
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
```

### **3. API Endpoint Issues**

**Possible Causes:**
- Wrong API endpoint URL
- Server not running on the expected port
- API endpoint doesn't exist

**Solutions:**
```dart
// Verify the API endpoint
static const String baseUrl = 'http://62.72.59.3:8000/api';

// Test with a simple GET request first
final response = await http.get(Uri.parse('$baseUrl/health'));
```

---

## 🛠️ **Immediate Fixes**

### **Fix 1: Add Network Error Handling**

Update your `ApiService` to handle network errors gracefully:

```dart
// In api_services.dart, update the _handleResponse method
static Map<String, dynamic>? _handleResponse(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isNotEmpty) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          print('JSON decode error: $e');
        }
        return {'success': false, 'message': 'Invalid response format'};
      }
    }
    return {'success': true, 'message': 'Success'};
  } else {
    final errorBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;
    if (kDebugMode) {
      print('API Error ${response.statusCode}: ${errorBody ?? response.reasonPhrase}');
    }
    return {
      'success': false,
      'message': 'Server error: ${response.statusCode}',
      'error': errorBody?['message'] ?? response.reasonPhrase
    };
  }
}
```

### **Fix 2: Add Network Connectivity Check**

Create a network utility:

```dart
// lib/core/utils/network_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Test actual connectivity by making a simple request
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> isApiServerReachable() async {
    try {
      final response = await http.get(
        Uri.parse('http://62.72.59.3:8000/api/health'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### **Fix 3: Update API Service with Better Error Handling**

```dart
// In api_services.dart, update the post method
static Future<Map<String, dynamic>?> post(
  String endpoint, {
  Map<String, String>? headers,
  Map<String, dynamic>? body,
}) async {
  try {
    // Check network connectivity first
    if (!await NetworkUtils.hasInternetConnection()) {
      return {
        'success': false,
        'message': 'No internet connection',
        'error': 'NETWORK_ERROR'
      };
    }
    
    // Check if API server is reachable
    if (!await NetworkUtils.isApiServerReachable()) {
      return {
        'success': false,
        'message': 'Server is not reachable',
        'error': 'SERVER_UNREACHABLE'
      };
    }
    
    final response = await http
        .post(
          Uri.parse(baseUrl + endpoint),
          headers: {'Content-Type': 'application/json', ...?headers},
          body: jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  } catch (e) {
    if (kDebugMode) {
      print('POST error for $endpoint: $e');
    }
    
    // Return structured error response
    return {
      'success': false,
      'message': 'Network error: ${e.toString()}',
      'error': 'NETWORK_ERROR'
    };
  }
}
```

---

## 🧪 **Testing Steps**

### **Step 1: Test Network Connectivity**

```dart
// Add this to your app for testing
Future<void> testNetworkConnectivity() async {
  print('Testing network connectivity...');
  
  // Test 1: Basic internet
  final hasInternet = await NetworkUtils.hasInternetConnection();
  print('Has internet: $hasInternet');
  
  // Test 2: API server reachability
  final isServerReachable = await NetworkUtils.isApiServerReachable();
  print('API server reachable: $isServerReachable');
  
  // Test 3: Direct API call
  try {
    final response = await http.get(
      Uri.parse('http://62.72.59.3:8000/api/health'),
    );
    print('API health check: ${response.statusCode}');
  } catch (e) {
    print('API health check failed: $e');
  }
}
```

### **Step 2: Test with Different URLs**

Try these alternative approaches:

```dart
// Option 1: Use HTTPS if available
static const String baseUrl = 'https://62.72.59.3:8000/api';

// Option 2: Use localhost for testing
static const String baseUrl = 'http://localhost:8000/api';

// Option 3: Use a different port
static const String baseUrl = 'http://62.72.59.3:3000/api';
```

---

## 🚀 **Quick Fixes to Try**

### **Fix 1: Update the API Base URL**

If the server is running on a different port or protocol:

```dart
// In api_services.dart
static const String baseUrl = 'https://62.72.59.3:8000/api'; // Try HTTPS
// OR
static const String baseUrl = 'http://62.72.59.3:3000/api'; // Try different port
```

### **Fix 2: Add Retry Logic**

```dart
static Future<Map<String, dynamic>?> postWithRetry(
  String endpoint, {
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final result = await post(endpoint, headers: headers, body: body);
      if (result != null) return result;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  return null;
}
```

### **Fix 3: Use Mock Data for Development**

```dart
// For development/testing purposes
static Future<Map<String, dynamic>?> post(
  String endpoint, {
  Map<String, String>? headers,
  Map<String, dynamic>? body,
}) async {
  // Mock response for development
  if (kDebugMode) {
    return {
      'success': true,
      'message': 'Mock response for development',
      'data': {'token': 'mock_token_123'}
    };
  }
  
  // Original implementation...
}
```

---

## 📱 **Frontend Error Handling**

Update your UI to show better error messages:

```dart
// In your signup/login screens
if (response != null && response.success) {
  // Success handling
} else {
  String errorMessage = 'An error occurred';
  
  if (response?['error'] == 'NETWORK_ERROR') {
    errorMessage = 'No internet connection. Please check your network.';
  } else if (response?['error'] == 'SERVER_UNREACHABLE') {
    errorMessage = 'Server is not reachable. Please try again later.';
  } else {
    errorMessage = response?['message'] ?? 'Unknown error occurred';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 🎯 **Next Steps**

1. **Test the server connectivity** using the commands above
2. **Update the API base URL** if needed
3. **Add network error handling** to your app
4. **Test with mock data** for development
5. **Contact your backend team** to verify server status

The authentication system is working correctly - the issue is purely network connectivity to the backend server.
