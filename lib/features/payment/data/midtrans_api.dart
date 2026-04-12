import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class MidtransCheckoutResult {
  final String orderId;
  final String redirectUrl;

  const MidtransCheckoutResult({
    required this.orderId,
    required this.redirectUrl,
  });
}

class MidtransApi {
  final Dio _dio = DioClient().dio;

  String _extractErrorMessage(DioException error) {
    final response = error.response;
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return error.message ?? 'Terjadi kesalahan saat menghubungi server';
  }

  Future<MidtransCheckoutResult> createCheckout({
    Map<String, dynamic>? bookingData,
    int? orderId,
  }) async {
    try {
      // Kita kirim bookingData ATAU order_id ke backend Laravel
      final response = await _dio.post(
        '/payments/midtrans/checkout',
        data: orderId != null ? {'order_id': orderId} : bookingData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      final redirectUrl = data['redirect_url']?.toString() ?? '';
      final returnedOrderId = data['order_id']?.toString() ?? '';

      if (redirectUrl.isEmpty) {
        throw Exception('Respons Midtrans: URL pembayaran kosong');
      }

      return MidtransCheckoutResult(
        orderId: returnedOrderId,
        redirectUrl: redirectUrl,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<String> getTransactionStatus(String orderId) async {
    try {
      final response = await _dio.get('/payments/midtrans/status/$orderId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;

      return (data['transaction_status']?.toString() ?? '').toLowerCase();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}
