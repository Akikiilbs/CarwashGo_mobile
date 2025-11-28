import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';

// Routes
import 'routes/app_routes.dart';

// Theme
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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

      // mulai dari splash
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
