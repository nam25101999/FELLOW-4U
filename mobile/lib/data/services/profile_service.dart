import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/network/dio_client.dart';
import '../models/profile_models.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/profile/me');
      return response.data;
    } catch (e) {
      throw 'Không thể tải hồ sơ: $e';
    }
  }

  Future<String> uploadImage(XFile image) async {
    try {
      FormData formData;
      if (kIsWeb) {
        // Xử lý cho môi trường Web
        final bytes = await image.readAsBytes();
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(bytes, filename: image.name),
        });
      } else {
        // Xử lý cho môi trường Mobile
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(image.path, filename: image.name),
        });
      }

      final response = await _dio.post('/upload', data: formData);
      return response.data['url'];
    } catch (e) {
      throw 'Không thể tải ảnh lên: $e';
    }
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    try {
      await _dio.put('/profile/me', data: userData);
    } catch (e) {
      throw 'Không thể cập nhật hồ sơ: $e';
    }
  }

  Future<List<dynamic>> getCards() async {
    try {
      final response = await _dio.get('/profile/cards');
      return response.data;
    } catch (e) {
      throw 'Không thể lấy danh sách thẻ: $e';
    }
  }

  Future<void> addCard(Map<String, dynamic> cardData) async {
    try {
      await _dio.post('/profile/cards', data: cardData);
    } catch (e) {
      throw 'Không thể thêm thẻ: $e';
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _dio.delete('/profile/cards/$cardId');
    } catch (e) {
      throw 'Không thể xóa thẻ: $e';
    }
  }

  Future<void> submitFeedback(String content) async {
    try {
      await _dio.post('/profile/feedback', data: {'content': content});
    } catch (e) {
      throw 'Không thể gửi phản hồi: $e';
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post('/profile/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw e.response?.data['message'] ?? 'Lỗi không xác định';
      }
      throw 'Không thể đổi mật khẩu: $e';
    }
  }

  Future<List<UserPhoto>> getPhotos() async {
    try {
      final response = await _dio.get('/profile/photos');
      return (response.data as List).map((e) => UserPhoto.fromJson(e)).toList();
    } catch (e) {
      throw 'Không thể tải ảnh: $e';
    }
  }

  Future<List<UserJourney>> getJourneys() async {
    try {
      final response = await _dio.get('/profile/journeys');
      return (response.data as List).map((e) => UserJourney.fromJson(e)).toList();
    } catch (e) {
      throw 'Không thể tải hành trình: $e';
    }
  }

  Future<void> addPhoto(String imageUrl) async {
    try {
      await _dio.post('/profile/photos', data: {'imageUrl': imageUrl});
    } catch (e) {
      throw 'Không thể thêm ảnh: $e';
    }
  }

  Future<void> addJourney(Map<String, dynamic> journeyData) async {
    try {
      await _dio.post('/profile/journeys', data: journeyData);
    } catch (e) {
      throw 'Không thể thêm hành trình: $e';
    }
  }
}
