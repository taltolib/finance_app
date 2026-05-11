import 'package:flutter/material.dart';

/// Виджет карточки категории (например, «Еда»).
/// Показывает иконку с меню, название, количество и сумму, кнопку «+ Добавить карточку».
///
/// Параметры:
/// - [title] — название категории
/// - [quantity] — количество элементов
/// - [overSum] — общая сумма
/// - [colorBorder] — цвет рамки
/// - [colorBackG] — цвет фона
/// - [icon] — иконка категории
/// - [colorIcon] — цвет иконки
/// - [onTap] — действие при нажатии на карточку
/// - [titleAddCard] — текст кнопки добавить
/// - [colorTitleAddCard] — цвет текста кнопки добавить
class CategoryCardWidget extends StatelessWidget {
  final String title;
  final int quantity;
  final String overSum;
  final Color colorBorder;
  final Color colorBackG;
  final IconData icon;
  final Color colorIcon;
  final VoidCallback? onTap;
  final String titleAddCard;
  final Color colorTitleAddCard;

  const CategoryCardWidget({
    super.key,
    required this.title,
    required this.quantity,
    required this.overSum,
    required this.colorBorder,
    required this.colorBackG,
    required this.icon,
    required this.colorIcon,
    this.onTap,
    this.titleAddCard = '+ Добавить карточку',
    required this.colorTitleAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBackG,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: colorIcon, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Количество: $quantity',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Итог группы: $overSum',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: Text(
              titleAddCard,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorTitleAddCard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}