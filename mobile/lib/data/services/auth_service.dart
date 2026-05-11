import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String role = 'TRAVELER',
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Đăng ký thất bại';
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      }
      throw errorMessage;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        // Small delay to ensure storage is synchronized before next requests
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Đăng nhập thất bại';
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      }
      throw errorMessage;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e, 'Gửi yêu cầu thất bại');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _dio.post('/auth/verify-otp', data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw _handleError(e, 'Mã OTP không hợp lệ');
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e, 'Đặt lại mật khẩu thất bại');
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

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
