import 'package:flutter/material.dart';

/// Компактный виджет транзакции — небольшая карточка с заголовком,
/// суммой, датой/подзаголовком и цветом фона.
///
/// Параметры:
/// - [title] — заголовок
/// - [sum] — сумма
/// - [onTap] — действие при нажатии
/// - [subtitleData] — дата или дополнительный текст
/// - [colorBackG] — цвет фона
/// - [colorBorder] — цвет рамки
/// - [titleColor] — цвет заголовка
/// - [sumColor] — цвет суммы
/// - [subtitleDataColor] — цвет подзаголовка
class SmallTransactionTile extends StatelessWidget {
  final String title;
  final String sum;
  final VoidCallback? onTap;
  final String subtitleData;
  final Color colorBackG;
  final Color colorBorder;
  final Color titleColor;
  final Color sumColor;
  final Color subtitleDataColor;

  const SmallTransactionTile({
    super.key,
    required this.title,
    required this.sum,
    this.onTap,
    required this.subtitleData,
    required this.colorBackG,
    required this.colorBorder,
    required this.titleColor,
    required this.sumColor,
    required this.subtitleDataColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: colorBackG,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleData,
                    style: TextStyle(
                      fontSize: 10,
                      color: subtitleDataColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              sum,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sumColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}