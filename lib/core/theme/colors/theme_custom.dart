import 'dart:ui';

import 'package:flutter/material.dart' show ThemeExtension;

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color backgroundLight;
  final Color text;
  final Color border;
  final Color more;
  final Color shadow;
  final Color nickname;

  const AppThemeColors( {
    required this.background,
    required this.text,
    required this.shadow,
    required this.border,
    required this.more,
    required this.nickname, required this.backgroundLight,
  });

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? backgroundLight,
    Color? border,
    Color? more,
    Color? nickname,
    Color? text,
    Color? shadow,
  }) => AppThemeColors(
    background: background ?? this.background,
    backgroundLight: backgroundLight ?? this.backgroundLight,
    text: text ?? this.text,
    shadow: shadow ?? this.shadow,
    border: border ?? this.border,
    nickname:  nickname ?? this.nickname,
    more: more ?? this.more,
  );

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      more: Color.lerp(more, other.more, t)!,
      text: Color.lerp(text, other.text, t)!,
      nickname: Color.lerp(nickname, other.nickname, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,

    );
  }
}
