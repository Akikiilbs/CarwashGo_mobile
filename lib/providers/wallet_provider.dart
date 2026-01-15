import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/network/dio_client.dart';
import '../models/wallet_models.dart';

class WalletProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;

  bool _isLoading = false;
  String? _error;

  WalletSummary? _summary;
  List<WalletTransaction> _transactions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  WalletSummary? get summary => _summary;
  List<WalletTransaction> get transactions => _transactions;

  Future<void> loadAll() async {
    await Future.wait([loadSummary(), loadTransactions()]);
  }

  Future<void> loadSummary() async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _dio.get('/partner/wallet/summary');
      final body = res.data;
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : <String, dynamic>{};
      _summary = WalletSummary.fromJson(data);
    } catch (e) {
      _setError('Gagal mengambil saldo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransactions() async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _dio.get('/partner/wallet/transactions');
      final body = res.data;
      final list = (body is Map && body['data'] is List)
          ? (body['data'] as List)
          : const [];

      _transactions = list
          .whereType<Map>()
          .map((e) => WalletTransaction.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      _setError('Gagal mengambil riwayat: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String> withdraw(int amount) async {
    try {
      final res = await _dio.post('/partner/wallet/withdraw', data: {
        'amount': amount,
      });

      final body = res.data;
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Berhasil';

      // refresh setelah withdraw
      await loadAll();
      return msg;
    } catch (e) {
      return 'Gagal tarik saldo: $e';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? v) {
    _error = v;
    notifyListeners();
  }
}
