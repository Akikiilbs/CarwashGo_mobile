import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  void _go(BuildContext context, String route, int index) {
    if (index == currentIndex) return;
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
          _item(CupertinoIcons.house_fill, CupertinoIcons.house, 0, '/home', context),
          _item(CupertinoIcons.bell_fill, CupertinoIcons.bell, 1, '/notification', context),
          _item(CupertinoIcons.person_crop_circle_fill, CupertinoIcons.person, 2, '/menu', context),
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
                _label(index),
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Notif";
      case 2:
        return "Menu";
      default:
        return "";
    }
  }
}
