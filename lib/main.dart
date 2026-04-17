import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================= PROVIDERS =================
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/review_provider.dart';
import 'providers/mitra_provider.dart';
import 'providers/station_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/partner_services_provider.dart';

// ================= SERVICES =================
import 'services/deep_link_service.dart';

// ================= ROUTES =================
import 'routes/app_routes.dart';

// ================= THEME =================
import 'core/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
  
  if (message.notification != null) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('saved_notifications');
      List<dynamic> savedList = savedStr != null ? jsonDecode(savedStr) : [];
      
      final route = message.data['route'];
      String role = 'customer';
      if (route != null && (route.toString().startsWith('/mitra-') || route.toString().contains('mitra'))) {
        role = 'mitra';
      }

      savedList.insert(0, {
        'title': message.notification!.title ?? 'Notifikasi Baru',
        'message': message.notification!.body ?? '',
        'time': DateTime.now().toString(),
        'isNew': true,
        'route': route,
        'role': role,
      });
      
      await prefs.setString('saved_notifications', jsonEncode(savedList));
    } catch (_) { }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi DeepLink untuk pembayaran
  DeepLinkService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => MitraProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PartnerServicesProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // <== ADDED here
      title: "CarWashGo",
      debugShowCheckedModeBanner: false,

      theme: _loadThemeSafely(),

      // mulai dari AppGatePage
      initialRoute: '/',

      routes: AppRoutes.routes,
    );
  }

  ThemeData _loadThemeSafely() {
    try {
      return AppTheme.lightTheme;
    } catch (e) {
      return ThemeData(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      );
    }
  }
}
