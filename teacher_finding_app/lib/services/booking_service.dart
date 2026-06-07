import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../utils/api_constants.dart';

class BookingService {
  /// Create a booking from an accepted request
  static Future<Booking> createBooking({
    required String token,
    required String requestId,
    required String subject,
    required String scheduledDate,
    double durationHours = 1.0,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createBookingEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({
        'request_id': requestId,
        'subject': subject,
        'scheduled_date': scheduledDate,
        'duration_hours': durationHours,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Booking.fromJson(data['booking'] as Map<String, dynamic>);
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to create booking');
  }

  /// Get student's bookings
  static Future<List<Booking>> getStudentBookings({required String token}) async {
    final response = await http.get(
      Uri.parse(ApiConstants.studentBookingsEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['bookings'] as List<dynamic>;
      return list.map((item) => Booking.fromJson(item as Map<String, dynamic>)).toList();
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load bookings');
  }

  /// Get teacher's bookings/sessions
  static Future<List<Booking>> getTeacherBookings({required String token}) async {
    final response = await http.get(
      Uri.parse(ApiConstants.teacherBookingsEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['bookings'] as List<dynamic>;
      return list.map((item) => Booking.fromJson(item as Map<String, dynamic>)).toList();
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load sessions');
  }

  /// Mark session as completed (teacher only)
  static Future<void> completeBooking({
    required String token,
    required String bookingId,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConstants.completeBookingEndpoint(bookingId)),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Failed to complete session');
    }
  }

  /// Cancel session
  static Future<void> cancelBooking({
    required String token,
    required String bookingId,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConstants.cancelBookingEndpoint(bookingId)),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Failed to cancel session');
    }
  }

  /// Pay for booking (student only)
  static Future<void> payBooking({
    required String token,
    required String bookingId,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/bookings/$bookingId/pay'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? 'Failed to pay for booking');
    }
  }
}
