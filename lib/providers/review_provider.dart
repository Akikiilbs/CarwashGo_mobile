import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/review_model.dart';
import '../core/network/dio_client.dart';

class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = DioClient().dio;

  // Hitung rata-rata rating untuk DASHBOARD MITRA
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _reviews.length;
  }

  int get totalReview => _reviews.length;

  Future<void> submitReview(int orderId, int rating, String comment) async {
    try {
      await _dio.post('/reviews', data: {
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      });
      // Optionally reload the stats if needed, but usually customer won't see their own review list.
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadPartnerReviews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/partner/reviews');
      final data = response.data;
      if (data != null && data['data'] != null) {
        final List list = data['data'];
        _reviews = list.map((e) => ReviewModel(
          orderId: (e['order_id'] ?? '').toString(),
          username: (e['username'] ?? 'Anonim').toString(),
          rating: (e['rating'] as num?)?.toInt() ?? 0,
          comment: (e['comment'] ?? '').toString(),
          createdAt: e['date'] != null 
            ? DateTime.tryParse(e['date'].toString()) ?? DateTime.now() 
            : DateTime.now(),
        )).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
