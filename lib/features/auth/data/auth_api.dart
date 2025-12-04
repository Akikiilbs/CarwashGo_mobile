import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../../../core/network/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  /// POST /auth/login
  /// body: { email, password }
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.isSuccess && authResponse.token != null) {
        await _storage.write(key: 'auth_token', value: authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      // Handle error dari API (422/401/dll)
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      // Fallback error generic
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// POST /auth/register
  /// body: { name, email, phone, password, password_confirmation }
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.isSuccess && authResponse.token != null) {
        await _storage.write(key: 'auth_token', value: authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// GET /auth/me
  Future<User?> me() async {
    try {
      final response = await _dio.get('/auth/me');

      // Respon me() kamu: success + data user langsung (tanpa wrapper user/token)
      final data = response.data;

      // Kalau BaseApiController::success mengembalikan:
      // { status, message, data: { ...user } }
      final userJson = data['data'];
      if (userJson == null) return null;

      return User.fromJson(userJson);
    } on DioException {
      return null;
    }
  }

  /// POST /auth/logout
  Future<bool> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // walau gagal di server, kita tetap hapus token lokal
    }

    await _storage.delete(key: 'auth_token');
    return true;
  }

  /// POST /auth/verify-otp
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // kalau sukses dan ada token → simpan
      if (authResponse.isSuccess && authResponse.token != null) {
        await _storage.write(key: 'auth_token', value: authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// POST /auth/resend-otp
  Future<AuthResponse> resendOtp({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/resend-otp',
        data: {'email': email},
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }
  
}
