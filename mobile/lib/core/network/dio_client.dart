import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../network/navigation_service.dart';
import '../../presentation/screens/sign_in_screen.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  static const String baseUrl = kIsWeb 
      ? "http://127.0.0.1:8080/api" 
      : "http://10.0.2.2:8080/api";
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        debugPrint("Dio Error: ${e.type} - ${e.message} - Path: ${e.requestOptions.path}");
        
        if (e.response?.statusCode == 401) {
          // 401 = token expired or invalid → clear and redirect
          if (!e.requestOptions.path.contains('/auth/login')) {
            String? currentToken = await _storage.read(key: 'jwt_token');
            String? requestToken = e.requestOptions.headers['Authorization']?.toString().replaceFirst('Bearer ', '');
            
            if (currentToken != null && currentToken == requestToken) {
              debugPrint("Token expired (401). Clearing and redirecting...");
              await _storage.delete(key: 'jwt_token');
              NavigationService.navigateToReplacement(const SignInScreen());
            } else {
              debugPrint("Stale request failed, current token is different. Skipping redirect.");
            }
          }
        } else if (e.response?.statusCode == 403) {
          // 403 = authenticated but no permission → let caller handle it, do NOT clear token
          debugPrint("403 Forbidden on ${e.requestOptions.path} - Permission denied, token kept.");
        }

        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          debugPrint("Lỗi kết nối: Timeout");
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
