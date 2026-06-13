import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_shell.dart';

class JournalTrendAnalyzerApp extends StatelessWidget {
  const JournalTrendAnalyzerApp({super.key});

  static const _primary = Color(0xFF1E40AF);
  static const _secondary = Color(0xFF3B82F6);
  static const _accent = Color(0xFFF59E0B);
  static const _background = Color(0xFFF8FAFC);
  static const _text = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      tertiary: _accent,
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
    );

    final baseTextTheme = GoogleFonts.firaSansTextTheme().apply(
      bodyColor: const Color(0xFF0F172A),
      displayColor: _text,
    );

    return MaterialApp(
      title: 'Journal Trend Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _background,
        textTheme: baseTextTheme,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: _text,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.firaSans(
            textStyle: baseTextTheme.titleLarge,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: GoogleFonts.firaSans(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEFF6FF),
          selectedColor: _primary,
          labelStyle: GoogleFonts.firaSans(fontSize: 13, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        tabBarTheme: TabBarThemeData(
          labelStyle: GoogleFonts.firaSans(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.firaSans(fontWeight: FontWeight.w400, fontSize: 14),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: const Color(0xFFE2E8F0),
        ),
      ),
      home: const HomeShell(),
    );
  }
}
