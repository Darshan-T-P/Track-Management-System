// Authentication Request Models
class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String role;
  // final String employeeCode;
  final String zoneId;
  final String? divisionId;
  final String? stationId;
  final Map<String, dynamic> deviceInfo;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.role,
    // required this.employeeCode,
    required this.zoneId,
    this.divisionId,
    this.stationId,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "phone": phone,
        "role": role,
        // "employeeCode": employeeCode,
        "zoneId": zoneId,
        "divisionId": divisionId,
        "stationId": stationId,
        "deviceInfo": deviceInfo,
      };
}


class LoginRequest {
  final String email;
  final String password;
  final Map<String, dynamic> deviceInfo;

  LoginRequest({
    required this.email,
    required this.password,
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'deviceInfo': deviceInfo};
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

// Authentication Response Models
class AuthResponse {
  final bool success;
  final String? message;
  final AuthData? data;
  final String? error;

  AuthResponse({required this.success, this.message, this.data, this.error});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

class AuthData {
  final String? token;
  final String? refreshToken;
  final String? expiresAt;
  final UserData? user;

  AuthData({this.token, this.refreshToken, this.expiresAt, this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      refreshToken: json['refreshToken'],
      expiresAt: json['expiresAt'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }
}

class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? zoneId;
  final String? divisionId;
  final String? stationId;
  final bool? isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.zoneId,
    this.divisionId,
    this.stationId,
    this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      zoneId: json['zoneId'],
      divisionId: json['divisionId'],
      stationId: json['stationId'],
      isEmailVerified: json['isEmailVerified'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'zoneId': zoneId,
      'divisionId': divisionId,
      'stationId': stationId,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;

  ApiResponse({required this.success, this.message, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      error: json['error'],
    );
  }
}

// Additional Response Models
class RefreshTokenResponse {
  final bool success;
  final String? message;
  final RefreshTokenData? data;

  RefreshTokenResponse({required this.success, this.message, this.data});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? RefreshTokenData.fromJson(json['data'])
          : null,
    );
  }
}

class RefreshTokenData {
  final String? token;
  final String? expiresAt;

  RefreshTokenData({this.token, this.expiresAt});

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(token: json['token'], expiresAt: json['expiresAt']);
  }
}

// Device Info Helper
class DeviceInfoHelper {
  static Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0', // You can get this from package_info_plus
    };
  }
}


