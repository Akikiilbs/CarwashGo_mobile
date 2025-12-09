import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/simple_api_response.dart';

class OrderApi {
  final Dio _dio = DioClient().dio;

  /// POST /orders
  /// Sesuaikan field2 di data: {} dengan Laravel OrderController@store
  Future<SimpleApiResponse> createOrder({
    required String carType,
    required String serviceType,
    required String mainAddress,
    required String detailAddress,
    required String plateNumber,
    required String dateLabel,
    required String timeSlot,
    required double distanceKm,
    required int totalPrice,
  }) async {
    try {
      final res = await _dio.post(
        '/orders',
        data: {
          // 👉 SESUAIKAN DENGAN BACKEND
          // kalau di Laravel namanya lain (vehicle_type_id, schedule_date, dll), ganti di sini
          'car_type': carType,
          'service_type': serviceType,
          'address': mainAddress,
          'detail_address': detailAddress,
          'plate_number': plateNumber,
          'schedule_date_label': dateLabel,
          'schedule_time_label': timeSlot,
          'distance_km': distanceKm,
          'total_price': totalPrice,
        },
      );

      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }

      return SimpleApiResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return SimpleApiResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }
}
