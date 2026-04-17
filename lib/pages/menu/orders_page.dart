import 'package:flutter/material.dart';
import '../navigation/bottom_nav.dart';
import 'orders_tab.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Pesanan Ku",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const OrdersTab(),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
