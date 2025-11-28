import 'package:flutter/material.dart';

class RouteTransition extends PageRouteBuilder {
  final Widget page;
  final int direction; // 1 = kanan ke kiri, -1 = kiri ke kanan

  RouteTransition({required this.page, this.direction = 1})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            // Atur arah animasi berdasarkan parameter
            final begin = Offset(direction.toDouble(), 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
