import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tms/core/services/storage_services.dart';
import 'package:tms/data/models/auth_models.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String fastApiUrl = 'http://10.73.160.214:8000'; // FastAPI URL
  static const Duration timeout = Duration(seconds: 30);
  static const String baseUrl = "http://10.73.160.214:4000/api";
 // for Android emulator
  static final storage = StorageService();

  static Future<Map<String, dynamic>?> getProductByUuid(String uuid) async {
  try {
    final response = await http.get(
      Uri.parse('$fastApiUrl/products/$uuid'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint('Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('Error fetching product: $e');
    return null;
  }
}

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

  static Future<Map<String, dynamic>> initProduct() async {
  final response = await http.post(
    Uri.parse('$fastApiUrl/products/init'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to initialize product');
  }
}

static Future<Uint8List?> getQrImage(String uuid) async {
  final response = await http.get(
    Uri.parse('$fastApiUrl/products/$uuid/qr'),
  );

  if (response.statusCode == 200) {
    return response.bodyBytes; // return image as bytes
  } else {
    debugPrint('Failed to fetch QR: ${response.statusCode}');
    return null;
  }
}


 static Future<Map<String, dynamic>> addProductDetails(
    String uuid, Map<String, dynamic> details) async {
  final response = await http.post(
    Uri.parse('$fastApiUrl/products/$uuid/details'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(details),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    debugPrint("Add product details failed: ${response.statusCode} - ${response.body}");
    return {
      "success": false,
      "message": "Failed to add product details",
      "error": json.decode(response.body),
    };
  }
}


  static Future<Map<String, dynamic>> addInspection(
    String uuid, Map<String, dynamic> inspection) async {
  final response = await http.post(
    Uri.parse('$fastApiUrl/products/$uuid/inspections'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(inspection),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 400 || response.statusCode == 404) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to add inspection');
  }
}


static Future<Map<String, dynamic>?> getWarrantyStatus(String uuid) async {
  final response = await http.get(
    Uri.parse('$fastApiUrl/products/$uuid/warranty-status'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint('Error checking warranty: ${response.statusCode}');
    return null;
  }
}


  /// ---------------- ADD REVIEW ----------------
  static Future<Map<String, dynamic>> addReview(
    String uuid, Map<String, dynamic> review) async {
  final response = await http.post(
    Uri.parse('$fastApiUrl/products/$uuid/reviews'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(review),
  );

  debugPrint("Response status: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to add review: ${response.body}");
  }
}


  static Future<void> logout() async {
    await storage.delete("token");
  } 

  static Future<List<dynamic>> getVendors({int page = 1, int limit = 10}) async {
    final uri = Uri.parse("$baseUrl/vendors?page=$page&limit=$limit");
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['vendors'];
    } else {
      throw Exception('Failed to fetch vendors');
    }
  }

  static Future<dynamic> getVendorById(String id) async {
    final res = await http.get(Uri.parse("$baseUrl/vendors/$id"));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Vendor not found');
    }
  }

  static Future<dynamic> createVendor(Map<String, dynamic> vendor) async {
    final res = await http.post(
      Uri.parse("$baseUrl/vendors"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(vendor),
    );
    if (res.statusCode == 201) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to create vendor');
    }
  }

  static Future<dynamic> updateVendor(String id, Map<String, dynamic> vendor) async {
    final res = await http.put(
      Uri.parse("$baseUrl/vendors/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(vendor),
    );
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to update vendor');
    }
  }

  static Future<void> deleteVendor(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/vendors/$id"));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete vendor');
    }
  }

  static Future<dynamic> changeVendorStatus(String id, String status) async {
    final res = await http.post(
      Uri.parse("$baseUrl/vendors/$id/status"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": status}),
    );
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to change status');
    }
  }

  static Future<dynamic> verifyVendor(String id) async {
    final res = await http.post(Uri.parse("$baseUrl/vendors/$id/verify"));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to verify vendor');
    }
  }
}