class WalletSummary {
  final int availableBalance; // saldo yang bisa ditarik (unsettled)
  final int totalNetEarned; // total pendapatan bersih
  final int totalGross; // total sebelum fee
  final int totalPlatformFee;
  final int totalWithdrawn; // total payout/withdraw sukses

  WalletSummary({
    required this.availableBalance,
    required this.totalNetEarned,
    required this.totalGross,
    required this.totalPlatformFee,
    required this.totalWithdrawn,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return WalletSummary(
      availableBalance: toInt(json['available_balance']),
      totalNetEarned: toInt(json['total_net_earned']),
      totalGross: toInt(json['total_gross']),
      totalPlatformFee: toInt(json['total_platform_fee']),
      totalWithdrawn: toInt(json['total_withdrawn']),
    );
  }
}

class WalletTransaction {
  final String id;
  final String type; // earning|payout|withdrawal
  final String title;
  final String subtitle;
  final int amount; // + masuk, - keluar (payout)
  final DateTime createdAt;
  final String status; // unsettled|settled|pending|success|failed|simulated
  final String? transferProof;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    required this.status,
    this.transferProof,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime toDt(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return WalletTransaction(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      amount: toInt(json['amount']),
      createdAt: toDt(json['created_at']),
      status: (json['status'] ?? '').toString(),
      transferProof: json['transfer_proof']?.toString(),
    );
  }
}
