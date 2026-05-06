import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../colors/theme_custom.dart';

class DarkTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.backgroundDark,

    colorScheme: const ColorScheme.dark(
      surface: AppColors.backgroundDark,
      onSurface: AppColors.textWhite,
      error: AppColors.heartRed,
    ),

    dividerColor: AppColors.borderGrey,

    extensions: const [
      AppThemeColors(
        background: AppColors.backgroundDark,
        whiteForLight: AppColors.textWhite,
        dividerWhite: AppColors.borderGrey,
        textGrey: AppColors.textGrey,
        textBlack: AppColors.textWhite,
        borderBlack: AppColors.borderGrey,
        text: AppColors.textWhite,
        shadow: AppColors.borderGrey,

      ),
    ],
  );
}