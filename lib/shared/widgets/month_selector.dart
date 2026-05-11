/// Month Selector Widget
/// Переключение месяца для фильтрации данных

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final int? selectedYear;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isEnabled;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    this.selectedYear,
    required this.onPrevious,
    required this.onNext,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM yyyy', 'ru_RU').format(
      DateTime(selectedYear ?? DateTime.now().year, selectedMonth.month),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: isEnabled ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            iconSize: 24,
          ),
          Expanded(
            child: Center(
              child: Text(
                monthName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: isEnabled ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}
