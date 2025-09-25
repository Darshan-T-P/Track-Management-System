import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:tms/core/services/storage_services.dart';
import 'package:tms/data/models/auth_models.dart';

class ApiService {

  static const String fastApiUrl = 'http://10.1.76.49:8000';
  static const String baseUrl = "http://10.1.76.49:5000/api";

  static const Duration timeout = Duration(seconds: 30);

  static final storage = StorageService();

  /// ---------------- AUTH ----------------

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
    return jsonDecode(response.body);
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

  static Future<void> logout() async {
    await storage.delete("token");
  }

  /// ---------------- PRODUCTS ----------------

  static Future<List<dynamic>> getProducts({int page = 1, int limit = 10}) async {
    final token = await storage.read("token");
    final res = await http.get(
      Uri.parse("$baseUrl/products?page=$page&limit=$limit"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['products'];
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> product) async {
  final token = await storage.read("token");
  
  if (product.isEmpty) {
    throw Exception("Product data cannot be empty");
  }

  final res = await http.post(
    Uri.parse("$baseUrl/products/create"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: json.encode(product),
  );

  if (res.statusCode == 201 || res.statusCode == 200) {
    return json.decode(res.body);
  } else {
    debugPrint("Failed to create product: ${res.body}");
    throw Exception('Failed to create product');
  }
}

  /// ---------------- FASTAPI QR + DETAILS ----------------

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

  static Future<Uint8List?> getQrImage(String uuid) async {
    try {
      final response = await http.get(
        Uri.parse('$fastApiUrl/products/$uuid/qr'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Failed to fetch QR: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching QR: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> addReview(
      String uuid, Map<String, dynamic> review) async {
    final token = await storage.read("token");
    final response = await http.post(
      Uri.parse("$baseUrl/products/$uuid/reviews"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(review),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add review: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> addInspection(
      String uuid, Map<String, dynamic> inspection) async {
    final token = await storage.read("token");
    final response = await http.post(
      Uri.parse("$baseUrl/products/$uuid/inspections"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(inspection),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add inspection: ${response.body}');
    }
  }


  static Future<Map<String, dynamic>> initProduct() async {
  final response = await http.post(
    Uri.parse('$baseUrl/products/create'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to initialize product: ${response.body}');
  }
}


 

  static Future<String?> getQrUrl(String uuid) async {
  final response = await http.get(
    Uri.parse('$baseUrl/products/$uuid'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['qrCodeUrl']; // assuming the backend returns the product JSON
  } else {
    debugPrint('Failed to fetch QR URL: ${response.statusCode}');
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

  // static Future<Map<String, dynamic>> addInspection(
  //   String uuid, Map<String, dynamic> inspection) async {
  //   final response = await http.post(
  //     Uri.parse('$fastApiUrl/products/$uuid/inspections'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(inspection),
  //   );

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else if (response.statusCode == 400 || response.statusCode == 404) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to add inspection');
  //   }
  // }

  // static Future<Map<String, dynamic>?> getWarrantyStatus(String uuid) async {
  //   final response = await http.get(
  //     Uri.parse('$fastApiUrl/products/$uuid/warranty-status'),
  //   );

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     debugPrint('Error checking warranty: ${response.statusCode}');
  //     return null;
  //   }
  // }

  // static Future<Map<String, dynamic>> addReview(
  //   String uuid, Map<String, dynamic> review) async {
  //   final response = await http.post(
  //     Uri.parse('$fastApiUrl/products/$uuid/reviews'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode(review),
  //   );

  //   debugPrint("Response status: ${response.statusCode}");
  //   debugPrint("Response body: ${response.body}");

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception("Failed to add review: ${response.body}");
  //   }
  // }

  /// ---------------- VENDORS ----------------

  static Future<List<dynamic>> getVendors({int page = 1, int limit = 10}) async {
  final uri = Uri.parse("$baseUrl/vendors?page=$page&limit=$limit");
  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    if (data is List) {
      return data;
    } else if (data is Map && data.containsKey('vendors')) {
      return data['vendors'] as List;
    } else {
      throw Exception("Unexpected vendors response: $data");
    }
  } else {
    throw Exception('Failed to fetch vendors: ${res.body}');
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

  //  ---------------- MANUFACTURERS ----------------

  static Future<List<dynamic>> getManufacturers() async {
  final res = await http.get(Uri.parse("$baseUrl/manufacturers"));
  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    if (data is List) {
      return data;
    } else if (data is Map && data.containsKey('manufacturers')) {
      return data['manufacturers'] as List;
    } else {
      throw Exception("Unexpected manufacturers response: $data");
    }
  } else {
    throw Exception('Failed to fetch manufacturers: ${res.body}');
  }
}


  static Future<dynamic> createManufacturer(Map<String, dynamic> manufacturer) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manufacturers"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(manufacturer),
    );
    if (res.statusCode == 201) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to create manufacturer');
    }
  }

  /// ---------------- BATCHES ----------------

  static Future<List<dynamic>> getBatches() async {
  final res = await http.get(Uri.parse("$baseUrl/batches"));

  if (res.statusCode == 200) {
    final data = json.decode(res.body);

    if (data is List) {
      return data;
    } else if (data is Map && data.containsKey('batches')) {
      return data['batches'] as List;
    } else {
      throw Exception("Unexpected batches response: $data");
    }
  } else {
    throw Exception('Failed to fetch batches: ${res.body}');
  }
}


  static Future<dynamic> createBatch(Map<String, dynamic> batch) async {
    final res = await http.post(
      Uri.parse("$baseUrl/batches"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(batch),
    );
    if (res.statusCode == 201) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to create batch');
    }
  }
}
