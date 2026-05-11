import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = DioClient().dio;

  Future<List<Booking>> getBookingsByStatus(String status) async {
    try {
      final response = await _dio.get('/bookings/status/$status');
      return (response.data as List).map((i) => Booking.fromJson(i)).toList();
    } on DioException catch (e) {
      throw 'Không thể tải danh sách chuyến đi';
    }
  }

  Future<List<Booking>> getAllBookings() async {
    try {
      final response = await _dio.get('/bookings');
      return (response.data as List).map((i) => Booking.fromJson(i)).toList();
    } on DioException catch (e) {
      throw 'Không thể tải danh sách chuyến đi';
    }
  }
}
