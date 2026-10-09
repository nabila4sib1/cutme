import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// APP THEME
// ============================================================
//
// Satu sumber warna & tipografi buat seluruh app, terinspirasi
// dari barbershop klasik: ink (hitam kebiruan), gold (aksen
// kuningan), dan burgundy (merah pool-table, buat status/alert).
// Serif Fraunces buat judul (karakter, premium), sans Inter buat
// isi (bersih, gampang dibaca).

class AppColors {
  AppColors._();

  static const ink = Color(0xFF15151A);
  static const inkSoft = Color(0xFF2A2A32);
  static const gold = Color(0xFFC6952C);
  static const goldSoft = Color(0xFFEFE1BE);
  static const burgundy = Color(0xFF7A2E2E);
  static const background = Color(0xFFF5F3EE);
  static const surface = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF6B6B72);
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base) {
    final display = GoogleFonts.fraunces(
      color: AppColors.ink,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );

    final body = GoogleFonts.inter(color: AppColors.ink);

    return base
        .copyWith(
          displayLarge: display.copyWith(fontSize: 40),
          displayMedium: display.copyWith(fontSize: 32),
          headlineLarge: display.copyWith(fontSize: 26),
          headlineMedium: display.copyWith(fontSize: 22),
          headlineSmall: display.copyWith(fontSize: 19),
          titleLarge: body.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: body.copyWith(fontSize: 15),
          bodyMedium: body.copyWith(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
          labelLarge: body.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
        primary: AppColors.gold,
        secondary: AppColors.ink,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme(base.textTheme),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.fraunces(
          color: AppColors.background,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.ink.withValues(alpha: 0.06),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.ink.withValues(alpha: 0.12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.ink.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.gold,
            width: 1.6,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.goldSoft,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        side: BorderSide.none,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.goldSoft,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.gold,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.ink.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }
}