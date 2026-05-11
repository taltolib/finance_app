/// Period Selector Widget
/// Выбор периода для аналитики

import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final List<String> periods;
  final List<String> periodLabels;
  final ValueChanged<String> onChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.periods,
    required this.periodLabels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          periods.length,
          (index) {
            final period = periods[index];
            final label = periodLabels[index];
            final isSelected = selectedPeriod == period;

            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == periods.length - 1 ? 0 : 0,
              ),
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onChanged(period),
                backgroundColor: theme.cardColor,
                selectedColor: theme.primaryColor.withOpacity(0.2),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.dividerColor.withOpacity(0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          },
        ),
      ),
    );
  }
}
