import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/simple_api_response.dart';

class OrderApi {
  final Dio _dio = DioClient().dio;

  /// (LEGACY) masih dummy (UI lama kamu masih pakai ini)
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
    // ⚠️ Catatan: backend sudah disarankan pakai createOrderV2 (partner_id, vehicle_type_id, items)
    // Ini sengaja dibiarkan agar project tidak langsung rusak saat kamu copy-paste patch backend.
    return SimpleApiResponse(
      status: 'error',
      message:
          'Endpoint order sudah berubah. Gunakan createOrderV2() (partner_id, vehicle_type_id, items).',
    );
  }

  /// ✅ V2 (match backend OrderController@store yang baru)
  Future<SimpleApiResponse> createOrderV2({
    required int partnerId,
    required int vehicleTypeId,

    String? vehicleBrand,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,

    required String address,
    double? latitude,
    double? longitude,

    required String scheduledDate, // 'YYYY-MM-DD'
    required String scheduledTime, // 'HH:mm'

    String? notes,
    double discount = 0,
    String? paymentMethod, // cash|ewallet|bank_transfer|null

    required List<Map<String, dynamic>> items,
    // contoh items: [{'partner_service_id': 55, 'quantity': 1}]
  }) async {
    try {
      final res = await _dio.post(
        '/orders',
        data: {
          'partner_id': partnerId,
          'vehicle_type_id': vehicleTypeId,

          'vehicle_brand': vehicleBrand,
          'vehicle_model': vehicleModel,
          'plate_number': plateNumber,
          'vehicle_color': vehicleColor,

          'address': address,
          'latitude': latitude,
          'longitude': longitude,

          'scheduled_date': scheduledDate,
          'scheduled_time': scheduledTime,

          'notes': notes,
          'discount': discount,
          'payment_method': paymentMethod,

          'items': items,
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
