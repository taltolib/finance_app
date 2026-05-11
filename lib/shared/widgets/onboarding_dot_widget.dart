import 'package:flutter/material.dart';

/// Виджет точек индикатора онбординга/пагинации.
/// Одна точка — активная (залитая), остальные — пустые (обводка).
///
/// Параметры:
/// - [colorBorder] — цвет рамки неактивной точки
/// - [colorBackG] — цвет фона активной точки
/// - [onTap] — колбэк при нажатии
class OnboardingDotWidget extends StatelessWidget {
  final bool isActive;
  final Color colorBorder;
  final Color colorBackG;
  final VoidCallback? onTap;

  const OnboardingDotWidget({
    super.key,
    required this.isActive,
    required this.colorBorder,
    required this.colorBackG,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 22 : 10,
        height: 10,
        decoration: BoxDecoration(
          color: isActive ? colorBackG : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isActive ? colorBackG : colorBorder,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Строка из нескольких точек онбординга.
///
/// Параметры:
/// - [count] — количество точек
/// - [currentIndex] — активный индекс
/// - [colorBorder] — цвет рамки неактивной точки
/// - [colorBackG] — цвет фона активной точки
/// - [onTap] — колбэк при нажатии на точку
class OnboardingDotsRow extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color colorBorder;
  final Color colorBackG;
  final ValueChanged<int>? onTap;

  const OnboardingDotsRow({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.colorBorder,
    required this.colorBackG,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
          child: OnboardingDotWidget(
            isActive: index == currentIndex,
            colorBorder: colorBorder,
            colorBackG: colorBackG,
            onTap: onTap != null ? () => onTap!(index) : null,
          ),
        );
      }),
    );
  }
}
