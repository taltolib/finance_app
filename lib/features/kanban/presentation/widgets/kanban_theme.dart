import 'package:flutter/material.dart';

class KanbanUiColors {
  static const bg = Color(0xFF1D2125);
  static const bgCard = Color(0xFF22262B);
  static const bgColumn = Color(0xFF191C20);
  static const blue = Color(0xFF25B4C7);
  static const blueDark = Color(0xFF1B4E8F);
  static const red = Color(0xFFFF4B4B);
  static const redDark = Color(0xFFD93A3A);
  static const shadow = Color(0xFF2A2D36);
  static const text = Color(0xFFFFFFFF);
  static const green = Color(0xFF58CC02);

  static Color get textMuted => Colors.white.withOpacity(0.45);
  static Color get textDim => Colors.white.withOpacity(0.70);
  static Color get border => Colors.white.withOpacity(0.10);
  static Color get borderActive => blue.withOpacity(0.45);
}

TextStyle kanbanText({
  double size = 14,
  FontWeight weight = FontWeight.w500,
  Color color = KanbanUiColors.text,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Mulish',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

class KanbanBackground extends StatelessWidget {
  final Widget child;

  const KanbanBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            isDark
                ? 'assets/images/kanban_bg_dark.png'
                : 'assets/images/kanban_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const ColoredBox(color: KanbanUiColors.bg);
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.15),
          ),
        ),
        child,
      ],
    );
  }
}