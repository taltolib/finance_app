import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../colors/theme_custom.dart';

class LightTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    extensions: const [
      AppThemeColors(
        background: AppColors.backgroundWhite,
        backgroundLight: AppColors.backgroundAcceptsWhite,
        border: AppColors.borderWhite,
        more: AppColors.moreWhite,
        text: AppColors.textDark,
        shadow: AppColors.shadowWhite,
        nickname: AppColors.greyWhite,
      ),
    ],
  );
}