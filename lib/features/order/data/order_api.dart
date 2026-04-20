import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/simple_api_response.dart';
import '../../payment/models/payment_model.dart';

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
    return SimpleApiResponse(
      status: 'error',
      message:
          'Endpoint order sudah berubah. Gunakan createOrderV2() (partner_id, vehicle_type_id, items).',
    );
  }

  /// ✅ V2 (match backend OrderController@store)
  Future<SimpleApiResponse> createOrderV2({
    required int partnerId,
    required int vehicleTypeId,
    String? vehicleBrand,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,
    required String address,
    String? detailAddress,
    double? latitude,
    double? longitude,
    required String scheduledDate, // 'YYYY-MM-DD'
    required String scheduledTime, // 'HH:mm'
    String? notes,
    double discount = 0,
    String? paymentMethod, // cash|ewallet|bank_transfer|null
    required List<Map<String, dynamic>> items,
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
          'detail_address': detailAddress,
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
          status: 'error', message: 'Terjadi kesalahan jaringan');
    } catch (_) {
      return SimpleApiResponse(
          status: 'error', message: 'Terjadi kesalahan tak terduga');
    }
  }

  // =========================================================
  // ✅ LIST ORDER (CUSTOMER) — GET /orders/customer
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchCustomerOrders(
      {String? status}) async {
    final res = await _dio.get(
      '/orders/customer',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final body = res.data;
    final data =
        (body is Map && body['data'] is List) ? body['data'] as List : const [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // =========================================================
  // ✅ LIST ORDER (PARTNER) — GET /orders/partner
  // =========================================================
  Future<List<Map<String, dynamic>>> fetchPartnerOrders(
      {String? status}) async {
    final res = await _dio.get(
      '/orders/partner',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final body = res.data;
    final data =
        (body is Map && body['data'] is List) ? body['data'] as List : const [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // =========================================================
  // ✅ PARTNER: ACCEPT / REJECT / UPDATE STATUS
  // =========================================================
  Future<SimpleApiResponse> partnerAccept(int orderId) async {
    try {
      final res = await _dio.post('/orders/$orderId/accept');
      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }
      return SimpleApiResponse(
          status: 'error', message: 'Gagal menerima order');
    }
  }

  Future<SimpleApiResponse> partnerReject(int orderId) async {
    try {
      final res = await _dio.post('/orders/$orderId/reject');
      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }
      return SimpleApiResponse(status: 'error', message: 'Gagal menolak order');
    }
  }

  Future<SimpleApiResponse> partnerUpdateStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final res = await _dio.post(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }
      return SimpleApiResponse(status: 'error', message: 'Gagal update status');
    }
  }

  // =========================================================
  // ✅ PAYMENT (MIDTRANS SNAP)
  // POST /orders/{id}/payments
  // =========================================================
  Future<SimpleApiResponse> createMidtransSnapPayment({
    required int orderId,
  }) async {
    try {
      final res = await _dio.post(
        '/orders/$orderId/payments',
        data: {'payment_method': 'midtrans_snap'},
      );
      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }
      return SimpleApiResponse(
          status: 'error', message: 'Gagal membuat pembayaran');
    } catch (_) {
      return SimpleApiResponse(
          status: 'error', message: 'Terjadi kesalahan tak terduga');
    }
  }

  // =========================================================
  // ✅ PAYMENT LIST BY ORDER
  // GET /orders/{id}/payments
  // =========================================================
  Future<List<PaymentModel>> fetchPaymentsByOrder(int orderId) async {
    final res = await _dio.get('/orders/$orderId/payments');
    final body = res.data;

    final data =
        (body is Map && body['data'] is List) ? body['data'] as List : const [];
    return data
        .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // =========================================================
  // ✅ PAYMENT DETAIL
  // GET /payments/{paymentId}
  // =========================================================
  Future<PaymentModel?> fetchPaymentDetail(int paymentId) async {
    final res = await _dio.get('/payments/$paymentId');
    final body = res.data;

    // umumnya: {status,message,data:{...payment...}}
    final data = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'])
        : null;
    if (data == null) return null;

    return PaymentModel.fromJson(data);
  }

  // =========================================================
  // ✅ UPLOAD PAYMENT PROOF
  // POST /orders/{id}/upload-payment-proof
  // =========================================================
  Future<SimpleApiResponse> uploadPaymentProof({
    required int orderId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'payment_proof': await MultipartFile.fromFile(filePath),
      });

      final res = await _dio.post(
        '/orders/$orderId/upload-payment-proof',
        data: formData,
      );

      return SimpleApiResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return SimpleApiResponse.fromJson(e.response!.data);
      }
      return SimpleApiResponse(
          status: 'error', message: 'Gagal mengunggah bukti pembayaran');
    } catch (e) {
      return SimpleApiResponse(
          status: 'error', message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }
}
