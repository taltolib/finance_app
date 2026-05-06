import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../colors/theme_custom.dart';

class LightTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.backgroundWhite,

    colorScheme: const ColorScheme.light(
      surface: AppColors.backgroundAcceptsWhite,
      onSurface: AppColors.textBlack,
      error: AppColors.heartRed,
    ),

    dividerColor: AppColors.dividerWhite,

    extensions: const [
      AppThemeColors(
        backgroundWhiteOrDark: AppColors.backgroundWhite,
        backgroundAcceptsWhiteOrDark: AppColors.backgroundAcceptsWhite,
        whiteForLight: AppColors.whiteForLight,
        dividerWhite: AppColors.dividerWhite,
        textGrey: AppColors.textGrey,
        textBlack: AppColors.textBlack,
        borderBlack: AppColors.borderGrey,
        text: AppColors.textBlack,
        shadow: AppColors.borderGrey,
      ),
    ],
  );
}