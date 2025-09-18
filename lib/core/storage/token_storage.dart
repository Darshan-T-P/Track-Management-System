import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  // Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (kDebugMode) {
        print('Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  // Get authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      if (kDebugMode) {
        print('Refresh token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving refresh token: $e');
      }
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting refresh token: $e');
      }
      return null;
    }
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = jsonEncode(userData);
      await prefs.setString(_userDataKey, userDataJson);
      if (kDebugMode) {
        print('User data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  // Save token expiry
  static Future<void> saveTokenExpiry(String expiry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenExpiryKey, expiry);
      if (kDebugMode) {
        print('Token expiry saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token expiry: $e');
      }
    }
  }

  // Get token expiry
  static Future<String?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenExpiryKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token expiry: $e');
      }
      return null;
    }
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;

      final expiryDate = DateTime.tryParse(expiry);
      if (expiryDate == null) return true;

      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking token expiry: $e');
      }
      return true;
    }
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_tokenExpiryKey);
      if (kDebugMode) {
        print('All authentication data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing auth data: $e');
      }
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final isExpired = await isTokenExpired();
      return !isExpired;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      return false;
    }
  }
}
