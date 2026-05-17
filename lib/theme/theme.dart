import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final colorScheme =
    ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 27, 55, 94),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color.fromARGB(255, 27, 39, 94),
      onPrimary: Colors.white,
      secondary: const Color(0xFF26A69A),
      onSecondary: Colors.white,
      surface: const Color(0xFFF5F7FA),
      onSurface: const Color(0xFF1C1C1C),
    );

final theme = ThemeData(
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,

  textTheme: GoogleFonts.interTextTheme().copyWith(
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      color: colorScheme.onSurface.withAlpha(204),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      color: colorScheme.onSurface.withAlpha(153),
    ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
