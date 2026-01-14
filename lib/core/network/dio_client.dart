import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://643fb99f7bbf.ngrok-free.app/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'okhttp',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _storage.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            debugPrint('❌ [DIO] Token read error: $e');
          }

          debugPrint('➡️ [DIO] ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Query: ${options.queryParameters}');
          debugPrint('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              '✅ [DIO] ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('Response: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint(
              '❌ [DIO] ERROR ${e.requestOptions.method} ${e.requestOptions.uri}');
          debugPrint('Type: ${e.type}');
          debugPrint('Message: ${e.message}');
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Response: ${e.response?.data}');
          debugPrint('Stack: ${e.stackTrace}');
          return handler.next(e);
        },
      ),
    );
  }
}
