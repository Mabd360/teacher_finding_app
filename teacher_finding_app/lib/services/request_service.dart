import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class RequestItem {
  final String id;
  final String? teacherId;
  final String? studentId;
  final String? teacherName;
  final String? studentName;
  final String? teacherEmail;
  final String? teacherPhone;
  final String? studentEmail;
  final String? studentPhone;
  final List<String>? subjects;
  final String? message;
  final String status;
  final String? createdAt;

  RequestItem({
    required this.id,
    this.teacherId,
    this.studentId,
    this.teacherName,
    this.studentName,
    this.teacherEmail,
    this.teacherPhone,
    this.studentEmail,
    this.studentPhone,
    this.subjects,
    this.message,
    required this.status,
    this.createdAt,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      id: json['id'],
      teacherId: json['teacher_id'],
      studentId: json['student_id'],
      teacherName: json['teacher_name'],
      studentName: json['student_name'],
      teacherEmail: json['teacher_email'],
      teacherPhone: json['teacher_phone'],
      studentEmail: json['student_email'],
      studentPhone: json['student_phone'],
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : null,
      message: json['message'],
      status: json['status'] ?? '',
      createdAt: json['created_at'],
    );
  }
}

class RequestService {
  static Future<RequestItem> sendRequest({
    required String token,
    required String teacherId,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.requestEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({'teacher_id': teacherId, 'message': message}),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return RequestItem.fromJson(
        jsonResponse['request'] as Map<String, dynamic>,
      );
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorResponse['error'] ?? 'Failed to send request');
  }

  static Future<List<RequestItem>> getStudentRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.studentRequestsEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final requestList = jsonResponse['requests'] as List<dynamic>;
      return requestList
          .map((item) => RequestItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(
      errorResponse['error'] ?? 'Failed to load student requests',
    );
  }

  static Future<List<RequestItem>> getTeacherRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse(ApiConstants.teacherRequestsEndpoint),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final requestList = jsonResponse['requests'] as List<dynamic>;
      return requestList
          .map((item) => RequestItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(
      errorResponse['error'] ?? 'Failed to load teacher requests',
    );
  }

  static Future<RequestItem> updateRequestStatus({
    required String token,
    required String requestId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse(ApiConstants.updateRequestEndpoint(requestId)),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return RequestItem.fromJson(
        jsonResponse['request'] as Map<String, dynamic>,
      );
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(
      errorResponse['error'] ?? 'Failed to update request status',
    );
  }
}
