import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy = Color(0xFF0B1F3A);
  static const indigo = Color(0xFF1E3A8A);
  static const amber = Color(0xFFFFB703);
  static const ok = Color(0xFF16A34A);
  static const warn = Color(0xFFF59E0B);
  static const bad = Color(0xFFDC2626);
  static const muted = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: brightness,
    ).copyWith(secondary: AppColors.amber);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final light = brightness == Brightness.light;

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor:
          light ? const Color(0xFFF4F6FB) : const Color(0xFF0E1420),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

/// Card colour that works in light and dark mode.
Color cardColor(BuildContext context) => Theme.of(context).colorScheme.surface;

Color borderColor(BuildContext context) =>
    Theme.of(context).colorScheme.outlineVariant.withAlpha(110);
