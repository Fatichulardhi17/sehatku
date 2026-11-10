import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppText {
  const AppText._();

  static TextStyle get display34 => GoogleFonts.lato(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.18,
      );

  static TextStyle get title26 => GoogleFonts.lato(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.18,
      );

  static TextStyle get title18 => GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.22,
      );

  static TextStyle get title16 => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.2,
      );

  static TextStyle get body15 => GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.25,
      );

  static TextStyle get body14 => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.25,
      );

  static TextStyle get body13 => GoogleFonts.lato(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.25,
      );

  static TextStyle get body12 => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.2,
      );

  static TextStyle get body11 => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.2,
      );

  static TextStyle get label11 => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 0.4,
        height: 1.2,
      );

  static TextStyle get nav11 => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.2,
      );

  static TextStyle get value44 => GoogleFonts.lato(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.08,
      );

  static TextStyle get value34 => GoogleFonts.lato(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.1,
      );

  static TextStyle get value22 => GoogleFonts.lato(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.15,
      );

  static TextStyle get value20 => GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.15,
      );

  static TextStyle get value18 => GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        height: 1.2,
      );

  static TextStyle get button15 => GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get button12 => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      );
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.cream,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      splashFactory: InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: GoogleFonts.latoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.primaryDark,
        displayColor: AppColors.primaryDark,
      ),
      dividerColor: AppColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.muted, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.muted, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
        hintStyle: AppText.body14,
      ),
    );
  }
}
