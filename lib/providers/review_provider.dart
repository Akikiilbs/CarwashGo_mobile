import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final List<ReviewModel> _reviews = [];

  List<ReviewModel> get reviews => _reviews;

  // ✅ Tambah ulasan dari USER
  void addReview(ReviewModel review) {
    _reviews.add(review);
    notifyListeners();
  }

  // ✅ Hitung rata-rata rating untuk DASHBOARD MITRA
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _reviews.length;
  }

  int get totalReview => _reviews.length;
}
