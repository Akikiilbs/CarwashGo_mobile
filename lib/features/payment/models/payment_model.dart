// lib/models/payment_model.dart

class PaymentModel {
  final int id;
  final int orderId;
  final String provider; // e.g. 'midtrans'
  final String providerRef; // e.g. 'CWGO-2-10'
  final int amount;
  final String status; // pending|paid|failed|expired
  final String? snapToken;
  final String? redirectUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.providerRef,
    required this.amount,
    required this.status,
    this.snapToken,
    this.redirectUrl,
    this.createdAt,
    this.updatedAt,
  });

  static int _asInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _asInt(json['id']),
      orderId: _asInt(json['order_id']),
      provider: (json['provider'] ?? '').toString(),
      providerRef: (json['provider_ref'] ?? '').toString(),
      amount: _asInt(json['amount']),
      status: (json['status'] ?? '').toString(),
      snapToken: json['snap_token']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}
