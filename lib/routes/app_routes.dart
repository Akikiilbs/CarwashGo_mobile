import 'package:flutter/material.dart';

import '../pages/app_gate_page.dart';

import '../pages/onboarding/splash_page.dart';
import '../pages/onboarding/onboarding_page.dart';

import '../pages/auth/role_page.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/signup_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/reset_password_page.dart';
import '../pages/auth/verify_email_page.dart';

import '../pages/auth/login_mitra_page.dart';
import '../pages/auth/signup_mitra_page.dart';
import '../pages/auth/forgot_password_mitra_page.dart';
import '../pages/auth/reset_password_mitra_page.dart';
import '../pages/auth/verify_email_mitra_page.dart';

import '../pages/home/home_page.dart';
import '../pages/notification/notification_page.dart';
import '../pages/menu/menu_page.dart';

import '../pages/mitra/home_mitra_page.dart';
import '../pages/mitra/mitra_orders_page.dart';
import '../pages/mitra/mitra_profile_page.dart';
import '../pages/mitra/mitra_income_page.dart';
import '../pages/mitra/mitra_cars_page.dart';
import '../pages/mitra/mitra_rating_page.dart';
import '../pages/mitra/mitra_services_page.dart';

import '../pages/payment/qris_page.dart';
import '../pages/menu/track_mitra_page.dart';
import '../models/order_model.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (_) => const AppGatePage(),
    '/gate': (_) => const AppGatePage(),
    '/splash': (_) => const SplashPage(),
    '/onboarding': (_) => const OnboardingPage(),
    '/role': (_) => const RolePage(),
    '/login': (_) => const LoginPage(),
    '/signup': (_) => const SignUpPage(),
    '/forgot-password': (_) => const ForgotPasswordPage(),
    '/verify-email': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return VerifyEmailPage(email: email);
    },
    '/reset-password': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordPage(email: email, otp: '');
    },
    '/login-mitra': (_) => const LoginMitraPage(),
    '/signup-mitra': (_) => const SignupMitraPage(),
    '/forgot-password-mitra': (_) => const ForgotPasswordMitraPage(),
    '/verify-email-mitra': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return VerifyEmailMitraPage(email: email);
    },
    '/reset-password-mitra': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordMitraPage(email: email);
    },
    '/home': (_) => const HomePage(),
    '/menu': (_) => const MenuPage(),
    '/notification': (_) => const NotificationPage(),
    '/mitra-home': (_) => const HomeMitraPage(),
    '/mitra-orders': (_) => const MitraOrdersPage(),
    '/mitra-profile': (_) => const MitraProfilePage(),
    '/mitra-services': (_) => const MitraServicesPage(),
    '/mitra-income': (_) => const MitraIncomePage(),
    '/mitra-cars': (_) => const MitraCarsPage(),
    '/mitra-rating': (_) => const MitraRatingPage(),
    '/qris': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return QRISPage(
        username: args["username"],
        phoneNumber: args["phoneNumber"],
        address: args["address"],
        detailAddress: args["detailAddress"],
        plateNumber: args["plateNumber"],
        carType: args["carType"],
        price: args["price"],
        servicePrice: args["servicePrice"],
        tax: args["tax"],
        discount: args["discount"],
        total: args["total"],
      );
    },
    '/track-mitra': (context) {
      final order = ModalRoute.of(context)!.settings.arguments as Order;
      return TrackMitraPage(order: order);
    },
  };
}
