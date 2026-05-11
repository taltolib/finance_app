import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../colors/theme_custom.dart';

class DarkTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    extensions: const [
      AppThemeColors(
        background: AppColors.backgroundDark,
        border: AppColors.borderDark,
        more: AppColors.moreDark,
        nickname: AppColors.greyDark,
        text: AppColors.textWhite,
        shadow: AppColors.shadowDark,

      ),
    ],
  );
}