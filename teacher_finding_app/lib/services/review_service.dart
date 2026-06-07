import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/api_constants.dart';

class ReviewService {
  /// Submit a review for a completed session
  static Future<Review> submitReview({
    required String token,
    required String sessionId,
    required int rating,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.submitReviewEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({
        'session_id': sessionId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Review.fromJson(data['review'] as Map<String, dynamic>);
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to submit review');
  }

  /// Get all reviews for a teacher (public)
  static Future<Map<String, dynamic>> getTeacherReviews({
    required String teacherId,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.teacherReviewsEndpoint(teacherId)),
      headers: ApiConstants.jsonHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final reviews = (data['reviews'] as List<dynamic>)
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
      return {
        'reviews': reviews,
        'average_rating': data['average_rating'] ?? 0.0,
        'total_reviews': data['total_reviews'] ?? 0,
      };
    }

    final errorData = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorData['error'] ?? 'Failed to load reviews');
  }
}
