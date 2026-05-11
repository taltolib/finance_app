import 'package:flutter/material.dart';

/// Виджет плитки архивированной доски/записи.
/// Отображает иконку слева и заголовок.
///
/// Параметры:
/// - [title] — заголовок
/// - [onTap] — колбэк при нажатии
/// - [child] — произвольный дочерний виджет (например, иконка или чип)
/// - [colorBorder] — цвет рамки
/// - [colorBackG] — цвет фона
/// - [titleColor] — цвет текста заголовка
class ArchiveTileWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? child;
  final Color colorBorder;
  final Color colorBackG;
  final Color titleColor;

  const ArchiveTileWidget({
    super.key,
    required this.title,
    this.onTap,
    this.child,
    required this.colorBorder,
    required this.colorBackG,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorBackG,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorBorder, width: 1),
        ),
        child: Row(
          children: [
            if (child != null) ...[
              child!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
