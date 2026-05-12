import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/colors/app_colors.dart';

class AnalyticsLineChartPainter extends CustomPainter {
  final List<double> incomePoints;
  final List<double> expensePoints;

  AnalyticsLineChartPainter({
    required this.incomePoints,
    required this.expensePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = [
      ...incomePoints,
      ...expensePoints,
    ].fold<double>(0.0, math.max);

    final double safeMax = maxValue <= 0 ? 1.0 : maxValue;

    final incomePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final expensePaint = Paint()
      ..color = AppColors.orange
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final incomePath = _buildPath(
      values: incomePoints,
      size: size,
      maxValue: safeMax,
    );

    final expensePath = _buildPath(
      values: expensePoints,
      size: size,
      maxValue: safeMax,
    );

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);
  }

  Path _buildPath({
    required List<double> values,
    required Size size,
    required double maxValue,
  }) {
    final path = Path();

    if (values.isEmpty) return path;

    if (values.length == 1) {
      final y = size.height - (values.first / maxValue * size.height);
      path.moveTo(0, y);
      path.lineTo(size.width, y);
      return path;
    }

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant AnalyticsLineChartPainter oldDelegate) {
    return oldDelegate.incomePoints != incomePoints ||
        oldDelegate.expensePoints != expensePoints;
  }
}