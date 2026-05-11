import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class TourActionService {
  final Dio _dio = DioClient().dio;

  Future<bool> toggleLike(String tourId) async {
    try {
      final response = await _dio.post('/tours/$tourId/like');
      return response.data['liked'];
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleBookmark(String tourId) async {
    try {
      final response = await _dio.post('/tours/$tourId/bookmark');
      return response.data['bookmarked'];
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, bool>> getTourStatus(String tourId) async {
    try {
      final response = await _dio.get('/tours/$tourId/status');
      return {
        'liked': response.data['liked'],
        'bookmarked': response.data['bookmarked'],
      };
    } catch (e) {
      return {'liked': false, 'bookmarked': false};
    }
  }
}
