import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/explore_model.dart';

class ExploreService {
  final Dio _dio = DioClient().dio;

  Future<ExploreResponse> getExploreData() async {
    try {
      final response = await _dio.get('/explore');
      return ExploreResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Không thể tải dữ liệu khám phá';
    }
  }

  Future<ExploreResponse> searchData(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      return ExploreResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi khi tìm kiếm';
    }
  }

  Future<List<User>> getAllGuides() async {
    try {
      final response = await _dio.get('/explore/guides');
      return (response.data as List).map((e) => User.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi khi tải danh sách hướng dẫn viên';
    }
  }

  Future<List<Tour>> getLikedTours() async {
    try {
      final response = await _dio.get('/tours/liked');
      return (response.data as List).map((e) => Tour.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi khi tải danh sách yêu thích';
    }
  }

  Future<List<Tour>> getBookmarkedTours() async {
    try {
      final response = await _dio.get('/tours/bookmarked');
      return (response.data as List).map((e) => Tour.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi khi tải danh sách đã lưu';
    }
  }
}
