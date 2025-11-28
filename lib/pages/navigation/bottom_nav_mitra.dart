import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavMitra extends StatelessWidget {
  final int currentIndex;

  const BottomNavMitra({super.key, required this.currentIndex});

  void _go(BuildContext context, String route, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
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
          _item(
            CupertinoIcons.doc_text_fill,
            CupertinoIcons.doc_text,
            1,
            '/mitra-orders',
            context,
          ),
          _item(
            CupertinoIcons.person_crop_circle_fill,
            CupertinoIcons.person,
            2,
            '/mitra-profile',
            context,
          ),
        ],
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
    bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => _go(context, route, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 17 : 10,
          vertical: 7,
        ),

        decoration: BoxDecoration(
          color: active ? Colors.blueAccent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
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
                _label(index),
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

  String _label(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Pesanan";
      case 2:
        return "Profil";
      default:
        return "";
    }
  }
}
