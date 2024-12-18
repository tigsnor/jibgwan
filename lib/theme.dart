import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color mediumBlue = Color(0xFF2980B9);
  static const Color deepGreen = Color(0xFF1ABC9C);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: mediumBlue,
      scaffoldBackgroundColor: white,
      textTheme: GoogleFonts.notoSansKrTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansKr(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.notoSansKr(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.notoSansKr(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: mediumBlue,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: GoogleFonts.notoSansKr(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: deepGreen,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: deepGreen,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: deepGreen),
    );
  }
}
