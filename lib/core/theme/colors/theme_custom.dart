import 'dart:ui';

import 'package:flutter/material.dart' show ThemeExtension;

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color backgroundWhiteOrDark;
  final Color backgroundAcceptsWhiteOrDark;
  final Color whiteForLight;
  final Color dividerWhite;
  final Color textBlack;
  final Color text;
  final Color textGrey;
  final Color borderBlack;
  final Color shadow;

  const AppThemeColors( {
    required this.backgroundWhiteOrDark,
    required this.backgroundAcceptsWhiteOrDark,
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
    Color? backgroundWhiteOrDark,
    Color? backgroundAcceptsWhiteOrDark,
    Color? whiteForLight,
    Color? dividerWhite,
    Color? textGrey,
    Color? textBlack,
    Color? borderBlack,
    Color? text,
    Color? shadow,
  }) => AppThemeColors(
    backgroundWhiteOrDark: backgroundWhiteOrDark ?? this.backgroundWhiteOrDark,
    backgroundAcceptsWhiteOrDark: backgroundAcceptsWhiteOrDark ?? this.backgroundAcceptsWhiteOrDark,
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
      backgroundWhiteOrDark: Color.lerp(backgroundWhiteOrDark, other.backgroundWhiteOrDark, t)!,
      backgroundAcceptsWhiteOrDark: Color.lerp(backgroundAcceptsWhiteOrDark, other.backgroundAcceptsWhiteOrDark, t,)!,
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
