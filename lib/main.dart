import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';


import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/review_provider.dart';
import 'providers/mitra_provider.dart';
import 'providers/station_provider.dart';
import 'providers/partner_services_provider.dart';


import 'routes/app_routes.dart';


import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔥 FlutterError: ${details.exception}');
    debugPrint('📌 Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔥 Unhandled error: $error');
    debugPrint('📌 Stack: $stack');
    return true;
  };

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('🔥 Zone error: $error');
    debugPrint('📌 Stack: $stack');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => MitraProvider()),
        ChangeNotifierProvider(create: (_) => PartnerServicesProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider()),
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
      title: "CarWashGo",
      debugShowCheckedModeBanner: false,

      theme: _loadThemeSafely(),

      
      initialRoute: '/splash',

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
