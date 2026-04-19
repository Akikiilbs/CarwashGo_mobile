import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../../models/wallet_models.dart';
import '../navigation/bottom_nav_mitra.dart';

class MitraIncomePage extends StatefulWidget {
  const MitraIncomePage({super.key});

  @override
  State<MitraIncomePage> createState() => _MitraIncomePageState();
}

class _MitraIncomePageState extends State<MitraIncomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<WalletProvider>().loadAll();
    });
  }

  Future<void> _refresh() async {
    await context.read<WalletProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WalletProvider>();
    final summary = prov.summary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text('Pendapatan'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _headerCard(summary: summary, loading: prov.isLoading),
            const SizedBox(height: 14),
            _actionRow(
              onWithdraw: () => _showWithdrawSheet(context),
              onHistory: () => _scrollToHistory(context),
            ),
            if (prov.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  prov.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _historyList(context, prov.transactions),
            const SizedBox(height: 6),
            const Text(
              'Tarik saldo otomatis: saat order selesai dan pembayaran valid, sistem akan membuat pendapatan mitra dan (opsional) menjalankan payout instan via IRIS.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavMitra(currentIndex: 0),
    );
  }

  void _scrollToHistory(BuildContext context) {
    // sederhana: cukup scroll ke bawah (user bisa swipe). Untuk demo tidak butuh controller.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scroll ke bawah untuk melihat riwayat.')),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final prov = context.read<WalletProvider>();
    final ctrlAmount = TextEditingController();
    final ctrlBankName = TextEditingController();
    final ctrlAccount = TextEditingController();
    final ctrlAccountName = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tarik Saldo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Saldo tersedia: ${_rupiah(prov.summary?.availableBalance ?? 0)}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrlAmount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrlBankName,
                decoration: const InputDecoration(
                  labelText: 'Nama Bank (misal: BCA, Mandiri)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrlAccount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrlAccountName,
                decoration: const InputDecoration(
                  labelText: 'Atas Nama Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = int.tryParse(ctrlAmount.text.replaceAll('.', '')) ?? 0;
                    if (amount < 100000) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Minimal penarikan adalah Rp 100.000')), 
                      );
                      return;
                    }
                    if (ctrlBankName.text.isEmpty || ctrlAccount.text.isEmpty || ctrlAccountName.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Harap lengkapi detail bank')), 
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    final msg = await prov.withdraw(amount, ctrlBankName.text, ctrlAccount.text, ctrlAccountName.text);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tarik Sekarang',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

Widget _headerCard({WalletSummary? summary, required bool loading}) {
  final available = summary?.availableBalance ?? 0;
  final totalNet = summary?.totalNetEarned ?? 0;
  final fee = summary?.totalPlatformFee ?? 0;
  final withdrawn = summary?.totalWithdrawn ?? 0;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.12),
          blurRadius: 14,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Saldo Mitra',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _rupiah(available),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total pendapatan bersih: ${_rupiah(totalNet)}',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _miniStat('Fee Platform (15%)', _rupiah(fee)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniStat('Total Payout', _rupiah(withdrawn)),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _miniStat(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _actionRow({required VoidCallback onWithdraw, required VoidCallback onHistory}) {
  return Row(
    children: [
      Expanded(
        child: _actionBtn(
          icon: Icons.payments,
          label: 'Tarik Saldo',
          onTap: onWithdraw,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _actionBtn(
          icon: Icons.receipt_long,
          label: 'Riwayat',
          onTap: onHistory,
        ),
      ),
    ],
  );
}

Widget _actionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

Widget _historyList(BuildContext context, List<WalletTransaction> items) {
  if (items.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  return Column(
    children: items.take(25).map((tx) {
      final isOut = tx.amount < 0;
      final color = isOut ? Colors.redAccent : Colors.green;
      final amountText = isOut ? '-${_rupiah(tx.amount.abs())}' : _rupiah(tx.amount);
      final subtitle = tx.subtitle.isNotEmpty ? tx.subtitle : tx.status;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isOut ? Icons.north_east : Icons.south_west, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amountText, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(_fmtTime(tx.createdAt), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                if (tx.transferProof != null && tx.transferProof!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () => _showProofDialog(context, tx.transferProof!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined, size: 14, color: Colors.blueAccent),
                            SizedBox(width: 4),
                            Text(
                              'Lihat Bukti',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      );
    }).toList(),
  );
}

void _showProofDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Bukti Transfer', style: TextStyle(fontSize: 16)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Gagal memuat gambar bukti.'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

String _rupiah(int value) {
  final s = value.toString();
  final rev = s.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < rev.length; i += 3) {
    chunks.add(rev.skip(i).take(3).toList().reversed.join());
  }
  return 'Rp ${chunks.reversed.join('.')}' ;
}

String _fmtTime(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}
