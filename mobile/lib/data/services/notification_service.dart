import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioClient().dio;

  Future<List<UserNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data as List)
          .map((json) => UserNotification.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to fetch notifications');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to mark notification as read');
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
