import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_request_model.dart';
import '../models/user_model.dart';
import '../services/token_storage_service.dart';
import '../utils/api_constants.dart';


class AuthService {
  /// Register a new user
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: ApiConstants.jsonHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 409) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'User already exists');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid registration data');
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Login user
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: ApiConstants.jsonHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid email or password');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid login data');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Remove saved token and cached user data
  static Future<void> logout() async {
    await TokenStorageService.clearAuthData();
  }

  /// Get the saved JWT token
  static Future<String?> getToken() async {
    return TokenStorageService.getToken();
  }

  /// Get the current user's saved role
  static Future<String?> getCurrentUserRole() async {
    final user = await TokenStorageService.getUser();
    return user?.role;
  }

  /// Get current user details and verification status
  static Future<User> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/me'),
        headers: {
          ...ApiConstants.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['user']);
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  /// Submit verification details for user
  static Future<User> completeVerification({
    required String token,
    required String phone,
    required String cnicFront,
    required String cnicBack,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/complete-verification'),
        headers: {
          ...ApiConstants.jsonHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'phone': phone,
          'cnic_front': cnicFront,
          'cnic_back': cnicBack,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['user']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to complete verification');
      }
    } catch (e) {
      throw Exception('Complete verification error: $e');
    }
  }
}
