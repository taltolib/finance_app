import 'dart:ui';

import 'package:flutter/material.dart' show ThemeExtension;

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color whiteForLight;
  final Color dividerWhite;
  final Color textBlack;
  final Color text;
  final Color textGrey;
  final Color borderBlack;
  final Color shadow;

  const AppThemeColors( {
    required this.background,
    required this.whiteForLight,
    required this.text,
    required this.dividerWhite,
    required this.shadow,
    required this.textGrey,
    required this.textBlack,
    required this.borderBlack,
  });

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? whiteForLight,
    Color? dividerWhite,
    Color? textGrey,
    Color? textBlack,
    Color? borderBlack,
    Color? text,
    Color? shadow,
  }) => AppThemeColors(
    background: background ?? this.background,
    whiteForLight: whiteForLight ?? this.whiteForLight,
    dividerWhite: dividerWhite ?? this.dividerWhite,
    borderBlack: borderBlack ?? this.borderBlack,
    textGrey: textGrey ?? this.textGrey,
    textBlack: textBlack ?? this.textBlack,
    text: text ?? this.text,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      whiteForLight: Color.lerp(whiteForLight, other.whiteForLight, t)!,
      dividerWhite: Color.lerp(dividerWhite, other.dividerWhite, t)!,
      textGrey: Color.lerp(textGrey, other.textGrey, t)!,
      textBlack: Color.lerp(textBlack, other.textBlack, t)!,
      borderBlack: Color.lerp(borderBlack, other.borderBlack, t)!,
      text: Color.lerp(text, other.text, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,

    );
  }
}
