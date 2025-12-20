class ReviewModel {
  final String orderId;
  final String username;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.orderId,
    required this.username,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
