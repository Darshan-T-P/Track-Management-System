import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tms/core/services/storage_services.dart';
import 'package:tms/data/models/auth_models.dart';
import 'package:flutter/foundation.dart';
import '../utils/network_utils.dart';

class ApiService {
  static const String fastApiUrl = 'http://127.0.0.1:8000'; // FastAPI URL
  static const Duration timeout = Duration(seconds: 30);
  static const String baseUrl =
      "http://localhost:5000/api"; // for Android emulator
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
 static Future<Map<String, dynamic>> addProductDetails(
      String uuid, Map<String, dynamic> details) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$uuid/details'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(details),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      // Return API error detail
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add product details');
    }
  }

  /// ---------------- ADD REVIEW ----------------
  static Future<Map<String, dynamic>> addReview(
      String uuid, Map<String, dynamic> review) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$uuid/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(review),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add review');
    }
  }

  static Future<void> logout() async {
    await storage.delete("token");
  } 
}