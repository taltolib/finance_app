import 'package:flutter/material.dart';

/// Виджет кнопки-фильтра (например, «Доходы», «Расходы»).
/// Отображается с рамкой, фоном и кастомным цветом текста.
///
/// Параметры:
/// - [title] — текст кнопки
/// - [onTap] — колбэк при нажатии
/// - [colorBorder] — цвет рамки
/// - [colorBackG] — цвет фона
/// - [titleColor] — цвет текста
class ActionButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color colorBorder;
  final Color colorBackG;
  final Color titleColor;

  const ActionButtonWidget({
    super.key,
    required this.title,
    required this.onTap,
    required this.colorBorder,
    required this.colorBackG,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colorBackG,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorBorder, width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ),
    );
  }
}