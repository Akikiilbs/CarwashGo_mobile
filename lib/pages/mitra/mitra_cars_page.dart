import 'package:flutter/material.dart';
import '../navigation/bottom_nav_mitra.dart';

class MitraCarsPage extends StatelessWidget {
  const MitraCarsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mobil yang Dicuci",
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
          _carItem("Toyota Avanza", "09:00 - 10:00"),
          _carItem("Honda Brio", "10:00 - 11:00"),
          _carItem("Daihatsu Xenia", "11:00 - 12:00"),
          _carItem("Fortuner VRZ", "13:00 - 14:00"),
          _carItem("Honda Jazz", "14:00 - 15:00"),
        ],
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 0),
    );
  }
}

class _carItem extends StatelessWidget {
  final String name;
  final String time;

  const _carItem(this.name, this.time);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(time, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
