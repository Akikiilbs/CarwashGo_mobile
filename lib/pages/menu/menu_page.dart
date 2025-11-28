import 'package:flutter/material.dart';
import '../navigation/bottom_nav.dart';

// FILE YANG BENAR
import 'profile_tab.dart';
import 'orders_tab.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Menu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Profil"),
            Tab(text: "Pesanan Ku"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          const ProfileTab(), // boleh const
          OrdersTab(),        // tidak boleh const
        ],
      ),

      bottomNavigationBar: BottomNav(currentIndex: 2),
    );
  }
}
