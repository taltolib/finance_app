import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';
import '../../generated/fonts/app_fonts.dart';

/// Виджет-карточка для отображения одной статистики (доход, расход, итог, транзакции).
/// Параметры:
/// - [title] — заголовок карточки
/// - [sum] — сумма/значение
/// - [colorBorder] — цвет рамки
/// - [colorBackG] — цвет фона
/// - [titleColor] — цвет заголовка
/// - [sumColor] — цвет суммы
class StatSummaryWidget extends StatelessWidget {
  final String title;
  final String sum;
  final Color? colorBorder;
  final Color colorBackG;
  final Color titleColor;
  final Color sumColor;
  final Color? shadowColor;

  const StatSummaryWidget({
    super.key,
    required this.title,
    required this.sum,
    this.colorBorder ,
    required this.colorBackG,
    required this.titleColor,
    required this.sumColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: colorBackG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBorder ?? Colors.transparent, width: 1.5),
        boxShadow:  [
          BoxShadow(color: shadowColor ?? AppColors.shadowDark, blurRadius: 3, spreadRadius: 1 )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppFonts.mulish.s18w700(color: titleColor),
          ),
          const SizedBox(height: 13),
          Text(
            sum,
            style: AppFonts.mulish.s16w700(color: sumColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}