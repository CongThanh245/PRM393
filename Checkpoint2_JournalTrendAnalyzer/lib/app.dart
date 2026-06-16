import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_shell.dart';

class JournalTrendAnalyzerApp extends StatelessWidget {
  const JournalTrendAnalyzerApp({super.key});

  static const _primary = Color(0xFF1D4ED8);
  static const _primaryDark = Color(0xFF1E3A8A);
  static const _accent = Color(0xFFD97706);
  static const _background = Color(0xFFEEF2FF);
  static const _border = Color(0xFFDDE3F5);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      secondary: const Color(0xFF3B82F6),
      tertiary: _accent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: _textPrimary,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: _textPrimary,
      displayColor: _primaryDark,
    );

    return MaterialApp(
      title: 'Journal Trend Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _background,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: _primaryDark,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x14000000),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _primaryDark,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border),
          ),
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          hintStyle: TextStyle(
            color: _textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEEF2FF),
          selectedColor: _primary,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 62,
          indicatorColor: _primary.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? _primary : _textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? _primary : const Color(0xFF94A3B8),
              size: 22,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: _primary.withValues(alpha: 0.1),
          selectedIconTheme:
              const IconThemeData(color: _primary, size: 22),
          unselectedIconTheme:
              const IconThemeData(color: Color(0xFF94A3B8), size: 22),
          selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
            color: _primary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
            color: _textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          labelColor: _primary,
          unselectedLabelColor: _textSecondary,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _border,
        ),
        dividerTheme: const DividerThemeData(
          color: _border,
          space: 1,
          thickness: 1,
        ),
      ),
      home: const HomeShell(),
    );
  }
}
