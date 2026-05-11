import 'package:flutter/material.dart';

/// Виджет кнопки «+ Добавить колонку» для Kanban-доски.
/// Отображается в конце списка колонок.
///
/// Параметры:
/// - [title] — текст кнопки
/// - [titleColor] — цвет текста
/// - [colorBorder] — цвет рамки
/// - [colorBackG] — цвет фона
/// - [onTap] — колбэк при нажатии
class AddColumnButtonWidget extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color colorBorder;
  final Color colorBackG;
  final VoidCallback onTap;

  const AddColumnButtonWidget({
    super.key,
    this.title = '+ Добавить колонку',
    required this.titleColor,
    required this.colorBorder,
    required this.colorBackG,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: colorBackG,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: titleColor, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
