/// API Constants
/// Centralized configuration for API endpoints and URLs
library;

class ApiConstants {
  // Base URL - Change to your backend server address
  static const String baseUrl = 'http://localhost:5000';

  // ZEGOCLOUD Configuration
  static const int zegoAppId = 2009635202;
  static const String zegoAppSign = '173bc3746e38c8503f6bf5817972c5e9463ac439082c9f65ec4de64c5e03f253';

  // Authentication Endpoints
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String loginEndpoint = '$baseUrl/api/auth/login';

  // Teacher Profile Endpoints
  static const String createProfileEndpoint = '$baseUrl/api/teacher/profile';
  static const String updateProfileEndpoint = '$baseUrl/api/teacher/profile';
  static const String getMyProfileEndpoint = '$baseUrl/api/teacher/profile';

  // Search & Browse
  static const String searchEndpoint = '$baseUrl/api/search';
  static const String browseTeachersEndpoint = '$baseUrl/api/teachers';

  // Requests
  static const String requestEndpoint = '$baseUrl/api/requests';
  static const String studentRequestsEndpoint = '$baseUrl/api/requests/student';
  static const String teacherRequestsEndpoint = '$baseUrl/api/requests/teacher';

  static String updateRequestEndpoint(String id) => '$baseUrl/api/requests/$id';

  // Bookings
  static const String createBookingEndpoint = '$baseUrl/api/bookings';
  static const String studentBookingsEndpoint = '$baseUrl/api/bookings/student';
  static const String teacherBookingsEndpoint = '$baseUrl/api/bookings/teacher';

  static String completeBookingEndpoint(String id) => '$baseUrl/api/bookings/$id/complete';
  static String cancelBookingEndpoint(String id) => '$baseUrl/api/bookings/$id/cancel';

  // Reviews
  static const String submitReviewEndpoint = '$baseUrl/api/reviews';
  static String teacherReviewsEndpoint(String teacherId) => '$baseUrl/api/reviews/teacher/$teacherId';

  /// Get public teacher profile by ID
  static String getTeacherProfileEndpoint(String userId) =>
      '$baseUrl/api/teacher/profile/$userId';

  // Headers for API requests
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  /// Generate authorization header with JWT token
  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
