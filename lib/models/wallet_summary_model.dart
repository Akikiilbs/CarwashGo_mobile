class WalletSummary {
  final int balance;
  final int totalEarned;
  final int totalWithdrawn;
  final int pendingPayout;

  const WalletSummary({
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.pendingPayout,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return WalletSummary(
      balance: toInt(json['balance']),
      totalEarned: toInt(json['total_earned']),
      totalWithdrawn: toInt(json['total_withdrawn']),
      pendingPayout: toInt(json['pending_payout']),
    );
  }
}
