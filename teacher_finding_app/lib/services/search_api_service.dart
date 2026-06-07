import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/teacher_profile_model.dart';
import '../utils/api_constants.dart';

class SearchApiService {
  /// Search teachers by subject and optional max fee.
  /// Returns a list of TeacherProfile objects.
  static Future<List<TeacherProfile>> searchTeachers({
    required String subject,
    double? maxFee,
  }) async {
    try {
      final queryParameters = <String, String>{'subject': subject};

      if (maxFee != null) {
        queryParameters['max_fee'] = maxFee.toString();
      }

      final uri = Uri.parse(
        ApiConstants.searchEndpoint,
      ).replace(queryParameters: queryParameters);
      final response = await http.get(uri, headers: ApiConstants.jsonHeaders);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final items = _extractItemList(decoded);
        if (items.isEmpty) {
          return [];
        }
        return items.map(_parseTeacherItem).toList();
      }

      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map<String, dynamic> && errorBody['error'] != null) {
          throw Exception(errorBody['error']);
        }
      } catch (_) {
        // ignore invalid JSON in error response
      }

      throw Exception(
        'Search request failed with status ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Search API error: $e');
    }
  }

  static List<dynamic> _extractItemList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['rows'] is List) {
        return decoded['rows'] as List<dynamic>;
      }
      if (decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded['results'] is List) {
        return decoded['results'] as List<dynamic>;
      }
    }

    return [];
  }

  static TeacherProfile _parseTeacherItem(dynamic item) {
    if (item is Map<String, dynamic>) {
      return TeacherProfile.fromJson(item);
    }

    if (item is List) {
      if (item.length >= 5) {
        return TeacherProfile.fromJson({
          'user_id': item[0],
          'name': item[1],
          'subjects': item[2],
          'fee_per_hour': item[3],
          'availability': item[4],
          'bio': item.length > 5 ? item[5] : null,
        });
      }
    }

    throw Exception('Unexpected search item format: ${item.runtimeType}');
  }
}
