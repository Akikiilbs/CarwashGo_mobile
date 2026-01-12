import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/order/data/order_api.dart';
import '../../providers/notification_provider.dart';

class BottomNavMitra extends StatefulWidget {
  final int currentIndex;

  const BottomNavMitra({super.key, required this.currentIndex});

  @override
  State<BottomNavMitra> createState() => _BottomNavMitraState();
}

class _BottomNavMitraState extends State<BottomNavMitra> {
  final OrderApi _orderApi = OrderApi();

  @override
  void initState() {
    super.initState();

    // ✅ Mulai polling badge pending (jalan sekali saja di provider)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().startPartnerOrderPolling(
            _orderApi,
            status: 'pending', // sesuai backend kamu
            interval: const Duration(seconds: 30),
          );
    });
  }

  void _go(BuildContext context, String route, int index) {
    if (index == widget.currentIndex) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item(
            CupertinoIcons.house_fill,
            CupertinoIcons.house,
            0,
            '/mitra-home',
            context,
          ),

          // ✅ PESANAN + BADGE
          _ordersItem(context),

          _item(
            CupertinoIcons.person_fill,
            CupertinoIcons.person,
            2,
            '/mitra-profile',
            context,
          ),
        ],
      ),
    );
  }

  Widget _ordersItem(BuildContext context) {
    final bool active = 1 == widget.currentIndex;

    return GestureDetector(
      onTap: () => _go(context, '/mitra-orders', 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 17 : 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0x1A1E88E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Consumer<NotificationProvider>(
              builder: (context, prov, _) {
                final count = prov.pendingOrderCount;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      active
                          ? CupertinoIcons.doc_text_fill
                          : CupertinoIcons.doc_text,
                      size: active ? 28 : 26,
                      color: active ? Colors.blueAccent : Colors.grey,
                    ),
                    if (count > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: _Badge(count: count),
                      ),
                  ],
                );
              },
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Text(
                'Pesanan',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData activeIcon,
    IconData inactiveIcon,
    int index,
    String route,
    BuildContext context,
  ) {
    final bool active = index == widget.currentIndex;

    return GestureDetector(
      onTap: () => _go(context, route, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 17 : 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0x1A1E88E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              active ? activeIcon : inactiveIcon,
              size: active ? 28 : 26,
              color: active ? Colors.blueAccent : Colors.grey,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                index == 0 ? 'Dashboard' : 'Profil',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
