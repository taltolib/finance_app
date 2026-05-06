import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1A1A2E);
  static const _accentGreen = Color(0xFF1D9E75);
  static const _accentRed = Color(0xFFD85A30);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),
    extensions: [
      AppColors(
        income: _accentGreen,
        expense: _accentRed,
        incomeLight: const Color(0xFFE1F5EE),
        expenseLight: const Color(0xFFFAECE7),
      ),
    ],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF1E1E30),
    ),
    extensions: [
      AppColors(
        income: _accentGreen,
        expense: _accentRed,
        incomeLight: const Color(0xFF0F3D2E),
        expenseLight: const Color(0xFF3D1A0A),
      ),
    ],
  );
}

 class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color incomeLight;
  final Color expenseLight;

  AppColors({
    required this.income,
    required this.expense,
    required this.incomeLight,
    required this.expenseLight,
  });

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? incomeLight,
    Color? expenseLight,
  }) =>
      AppColors(
        income: income ?? this.income,
        expense: expense ?? this.expense,
        incomeLight: incomeLight ?? this.incomeLight,
        expenseLight: expenseLight ?? this.expenseLight,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      incomeLight: Color.lerp(incomeLight, other.incomeLight, t)!,
      expenseLight: Color.lerp(expenseLight, other.expenseLight, t)!,
    );
  }
}