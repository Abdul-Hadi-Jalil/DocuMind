import 'package:flutter/material.dart';

class AppTheme {
  // Frog-themed color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color background = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: darkGreen,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: darkGreen,
      colorScheme: const ColorScheme.dark(
        primary: darkGreen,
        secondary: lightGreen,
        surface: black,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGreen,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
