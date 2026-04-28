import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color secondaryColor = Color(0xFF3B82F6); // Bright Blue
  static const Color scaffoldBackgroundColor = Color(0xFFF8FAFC); // Slate 50

  static final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    
    textTheme: GoogleFonts.poppinsTextTheme(),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // Slate 100
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(
        color: Color(0xFF475569), // Slate 600
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)), // Slate 400
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
