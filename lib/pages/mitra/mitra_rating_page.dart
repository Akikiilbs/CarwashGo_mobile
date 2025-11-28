import 'package:flutter/material.dart';
import '../navigation/bottom_nav_mitra.dart';

class MitraRatingPage extends StatelessWidget {
  const MitraRatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rating Pelanggan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _reviewItem("Abelino", 5, "Pelayanan bagus dan cepat!"),
          _reviewItem("Tio Rimexx", 4, "Cukup baik, mobil bersih."),
          _reviewItem("Daeng Agung", 5, "Recommended banget!"),
        ],
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
    );
  }
}

class _reviewItem extends StatelessWidget {
  final String name;
  final int rating;
  final String desc;

  const _reviewItem(this.name, this.rating, this.desc);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("⭐ $rating",
                  style: const TextStyle(
                      color: Colors.orange, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc),
        ],
      ),
    );
  }
}
