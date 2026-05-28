import 'package:flutter/material.dart';

class AppColors {
  static const cyan = Color(0xFF06B6D4);
  static const cyanDark = Color(0xFF0891B2);
  static const cyanDarker = Color(0xFF0E7490);
  static const ink = Color(0xFF0F172A);
  static const ink800 = Color(0xFF1E293B);
  static const ink600 = Color(0xFF475569);
  static const ink400 = Color(0xFF94A3B8);
  static const ink200 = Color(0xFFE2E8F0);
  static const ink100 = Color(0xFFF1F5F9);
  static const ink50 = Color(0xFFF8FAFC);
  static const red = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
  static const emerald = Color(0xFF10B981);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.cyan,
    primary: AppColors.cyan,
    secondary: AppColors.cyanDarker,
    surface: Colors.white,
    onSurface: AppColors.ink,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.ink50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.ink100),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.ink50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.ink200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.ink200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cyan, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyanDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.cyanDark,
      unselectedItemColor: AppColors.ink400,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      elevation: 8,
    ),
  );
}

extension PriceFmt on int {
  String get won {
    if (this >= 100000000) {
      final eok = (this / 100000000).floor();
      final man = ((this % 100000000) / 10000).floor();
      return man > 0 ? '${eok}억 ${_comma(man)}만원' : '${eok}억원';
    }
    return '${_comma((this / 10000).floor())}만원';
  }

  String _comma(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}
