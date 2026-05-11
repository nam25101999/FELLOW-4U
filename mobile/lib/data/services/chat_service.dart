import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/chat_model.dart';

class ChatService {
  final Dio _dio = DioClient().dio;

  Future<List<ChatConversation>> getConversations() async {
    try {
      final response = await _dio.get('/chat/conversations');
      return (response.data as List)
          .map((json) => ChatConversation.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch conversations');
    }
  }

  Future<List<ChatMessage>> getChatHistory(String otherUserId) async {
    try {
      final response = await _dio.get('/chat/history/$otherUserId');
      return (response.data as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch chat history');
    }
  }

  Future<ChatMessage> sendMessage(String receiverId, String content) async {
    try {
      final response = await _dio.post(
        '/chat/send',
        queryParameters: {'receiverId': receiverId, 'content': content},
      );
      return ChatMessage.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to send message');
    }
  }

  String _handleError(DioException e, String defaultMessage) {
    if (e.response?.data != null) {
      if (e.response?.data is Map) {
        return e.response?.data['message'] ?? defaultMessage;
      } else if (e.response?.data is String) {
        return e.response?.data!;
      }
    }
    return defaultMessage;
  }
}
