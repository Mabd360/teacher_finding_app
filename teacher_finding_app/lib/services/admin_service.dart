import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class AdminService {
  /// Get admin dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/dashboard'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load dashboard');
  }

  /// Get all teachers
  static Future<List<dynamic>> getTeachers(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/teachers'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['teachers'] as List<dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load teachers');
  }

  /// Get all students
  static Future<List<dynamic>> getStudents(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/students'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['students'] as List<dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load students');
  }

  /// Get payments with optional status filter
  static Future<List<dynamic>> getPayments(
    String token, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/payments').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': ?status,
      },
    );

    final response = await http.get(
      uri,
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['payments'] as List<dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load payments');
  }

  /// Confirm payment as paid
  static Future<Map<String, dynamic>> confirmPayment(
    String token,
    String paymentId, {
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/admin/payments/$paymentId/confirm',
      ),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({'notes': notes}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to confirm payment');
  }

  /// Get admin notifications
  static Future<List<dynamic>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/notifications'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['notifications'] as List<dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load notifications');
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(
    String token,
    String notificationId,
  ) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/admin/notifications/$notificationId/read',
      ),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        errorData['error'] ?? 'Failed to mark notification as read',
      );
    }
  }

  /// Get all unverified users
  static Future<List<dynamic>> getUnverifiedUsers(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/unverified'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['users'] as List<dynamic>;
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load unverified users');
  }

  /// Verify a user
  static Future<void> verifyUser(String token, String userId, {bool isVerified = true}) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/users/$userId/verify'),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({'is_verified': isVerified}),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Failed to update user verification');
    }
  }

  /// Reject/Disapprove a user (deletes the user from queue/database so they can re-register)
  static Future<void> rejectUser(String token, String userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/api/admin/users/$userId'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Failed to reject user');
    }
  }
}
