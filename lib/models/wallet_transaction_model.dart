class WalletTransaction {
  final String id;
  final String type; // earning | payout | withdrawal | refund | platform_fee
  final String direction; // credit | debit
  final int amount;
  final int balanceAfter;
  final DateTime createdAt;
  final Map<String, dynamic> meta;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
    required this.meta,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime toDt(dynamic v) {
      final s = (v ?? '').toString();
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    return WalletTransaction(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      direction: (json['direction'] ?? '').toString(),
      amount: toInt(json['amount']),
      balanceAfter: toInt(json['balance_after']),
      createdAt: toDt(json['created_at']),
      meta: (json['meta'] is Map)
          ? Map<String, dynamic>.from(json['meta'])
          : <String, dynamic>{},
    );
  }

  String get title {
    switch (type) {
      case 'earning':
        return 'Pendapatan Order';
      case 'payout':
        return 'Pencairan Otomatis';
      case 'withdrawal':
        return 'Tarik Saldo';
      case 'refund':
        return 'Refund Pencairan';
      case 'platform_fee':
        return 'Fee Platform';
      default:
        return type.isEmpty ? 'Transaksi' : type;
    }
  }
}
