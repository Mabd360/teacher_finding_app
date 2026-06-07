/// Teacher API Service
/// Handles all HTTP requests related to teacher profiles
/// Requires JWT token from authentication for protected endpoints
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/teacher_profile_model.dart';
import '../utils/api_constants.dart';

class TeacherApiService {
  /// Create a new teacher profile
  /// Requires: JWT token, teacher role
  ///
  /// Returns: TeacherProfile object on success
  /// Throws: Exception with error message on failure
  static Future<TeacherProfile> createProfile({
    required String token,
    required List<String> subjects,
    required double feePerHour,
    required Map<String, dynamic>? availability,
    required String? bio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createProfileEndpoint),
        headers: ApiConstants.getAuthHeaders(token),
        body: jsonEncode({
          'subjects': subjects,
          'fee_per_hour': feePerHour,
          'availability': availability,
          'bio': bio,
        }),
      );

      // 201 Created - Profile created successfully
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return TeacherProfile.fromJson(jsonResponse['profile']);
      }
      // 403 Forbidden - User is not a teacher
      else if (response.statusCode == 403) {
        throw Exception('Only teachers can create a profile');
      }
      // 409 Conflict - Profile already exists
      else if (response.statusCode == 409) {
        throw Exception('Teacher profile already exists');
      }
      // 400 Bad Request - Invalid input
      else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['error'] ?? 'Invalid input');
      }
      // 401 Unauthorized - Token invalid or expired
      else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again');
      } else {
        throw Exception('Failed to create profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update existing teacher profile
  /// Requires: JWT token, teacher role
  /// Only fields provided will be updated
  ///
  /// Returns: Updated TeacherProfile object on success
  /// Throws: Exception with error message on failure
  static Future<TeacherProfile> updateProfile({
    required String token,
    List<String>? subjects,
    double? feePerHour,
    Map<String, dynamic>? availability,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (subjects != null) body['subjects'] = subjects;
      if (feePerHour != null) body['fee_per_hour'] = feePerHour;
      if (availability != null) body['availability'] = availability;
      if (bio != null) body['bio'] = bio;

      final response = await http.put(
        Uri.parse(ApiConstants.updateProfileEndpoint),
        headers: ApiConstants.getAuthHeaders(token),
        body: jsonEncode(body),
      );

      // 200 OK - Profile updated successfully
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TeacherProfile.fromJson(jsonResponse['profile']);
      }
      // 403 Forbidden - User is not a teacher
      else if (response.statusCode == 403) {
        throw Exception('Only teachers can update a profile');
      }
      // 404 Not Found - Profile does not exist
      else if (response.statusCode == 404) {
        throw Exception('Teacher profile not found. Create one first');
      }
      // 400 Bad Request - Invalid input
      else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['error'] ?? 'Invalid input');
      }
      // 401 Unauthorized - Token invalid or expired
      else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get logged-in teacher's own profile
  /// Requires: JWT token
  ///
  /// Returns: TeacherProfile with user details (name, email)
  /// Throws: Exception with error message on failure
  static Future<TeacherProfile> getMyProfile({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getMyProfileEndpoint),
        headers: ApiConstants.getAuthHeaders(token),
      );

      // 200 OK - Profile retrieved successfully
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TeacherProfile.fromJson(jsonResponse['profile']);
      }
      // 404 Not Found - Profile does not exist
      else if (response.statusCode == 404) {
        throw Exception('Teacher profile not found');
      }
      // 401 Unauthorized - Token invalid or expired
      else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get any teacher's profile by user ID (Public route - no auth required)
  ///
  /// @param userId - The teacher's user UUID
  /// Returns: TeacherProfile with public information (name, subjects, fee, bio)
  /// Throws: Exception with error message on failure
  static Future<TeacherProfile> getTeacherProfile({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getTeacherProfileEndpoint(userId)),
        headers: ApiConstants.jsonHeaders,
      );

      // 200 OK - Profile retrieved successfully
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return TeacherProfile.fromJson(jsonResponse['profile']);
      }
      // 404 Not Found - Profile does not exist
      else if (response.statusCode == 404) {
        throw Exception('Teacher profile not found');
      } else {
        throw Exception(
          'Failed to fetch teacher profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
