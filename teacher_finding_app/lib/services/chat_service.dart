import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class MessageItem {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? senderName;
  final DateTime createdAt;

  MessageItem({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.senderName,
    required this.createdAt,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      senderName: json['sender_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatService {
  static Future<List<MessageItem>> getMessages({
    required String token,
    required String otherUserId,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/messages/$otherUserId'),
      headers: ApiConstants.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final messagesList = jsonResponse['messages'] as List<dynamic>;
      return messagesList
          .map((item) => MessageItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorResponse['error'] ?? 'Failed to load messages');
  }

  static Future<MessageItem> sendMessage({
    required String token,
    required String receiverId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/messages'),
      headers: ApiConstants.getAuthHeaders(token),
      body: jsonEncode({
        'receiver_id': receiverId,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return MessageItem.fromJson(
        jsonResponse['message'] as Map<String, dynamic>,
      );
    }

    final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(errorResponse['error'] ?? 'Failed to send message');
  }
}
