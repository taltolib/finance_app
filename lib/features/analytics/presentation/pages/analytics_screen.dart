import 'dart:math' as math;

import 'package:finance_app/core/state/providers/theme_provider.dart';
import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:finance_app/shared/widgets/stat_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

 import '../../../dashboard/presentation/widgets/transaction_tile.dart';
import '../widgets/analytics_line_chart_painter.dart';

enum AnalyticsPeriod {
  year,
  threeMonths,
  month,
  week,
  day,
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const int _previewTransactionCount = 3;

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final isDark = themeProvider.isDark;

    final allTransactions = provider.transactions;
    final selectedTransactions = _filterTransactionsByPeriod(
      transactions: allTransactions,
      selectedMonth: provider.selectedMonth,
      period: _selectedPeriod,
    );

    final totalIncome = _calculateTotal(
      selectedTransactions,
      TransactionType.income,
    );

    final totalExpense = _calculateTotal(
      selectedTransactions,
      TransactionType.expense,
    );

    final currentBalance = totalIncome - totalExpense;

    final chartData = _buildChartData(
      transactions: selectedTransactions,
      period: _selectedPeriod,
      selectedMonth: provider.selectedMonth,
    );

    final previewTransactions =
    selectedTransactions.take(_previewTransactionCount).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Аналитика',
          style: AppFonts.mulish.s24w700(color: colors.text),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark
                  ? 'assets/images/kanban_bg_dark.png'
                  : 'assets/images/kanban_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.loadTransactions(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    _AnalyticsPeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    _AnalyticsChartCard(
                      incomePoints: chartData.incomePoints,
                      expensePoints: chartData.expensePoints,
                      colors: colors,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Доходы',
                            sum: _formatMoney(totalIncome),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.green,
                            sumColor: colors.text,
                            shadowColor: colors.shadow,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Расходы',
                            sum: _formatMoney(totalExpense),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.red,
                            sumColor: colors.text,
                            shadowColor: colors.shadow,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Итог',
                            sum: _formatMoney(currentBalance),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.blue,
                            sumColor: colors.text,
                            shadowColor: colors.shadow,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Транзакции',
                            sum: selectedTransactions.length.toString(),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.orange,
                            sumColor: colors.text,
                            shadowColor: colors.shadow,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Транзакции',
                      style: AppFonts.mulish.s20w700(color: colors.text),
                    ),

                    const SizedBox(height: 10),

                    if (selectedTransactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 80,
                            horizontal: 50,
                          ),
                          child: Text(
                            'Нет транзакций за этот период',
                            textAlign: TextAlign.center,
                            style: AppFonts.mulish.s16w400(
                              color: colors.text.withOpacity(0.60),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: previewTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = previewTransactions[index];

                          return TransactionTile(
                            transaction: transaction,
                            onDelete: () =>
                                provider.deleteTransaction(transaction.id),
                          );
                        },
                      ),

                      if (selectedTransactions.length >
                          previewTransactions.length) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colors.text.withOpacity(0.45),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                              colors.backgroundLight.withOpacity(0.15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AnalyticsTransactionsScreen(
                                    title: 'Все транзакции',
                                    periodLabel: _getPeriodTitle(
                                      _selectedPeriod,
                                      provider.selectedMonth,
                                    ),
                                    transactions: selectedTransactions,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Смотреть все',
                              style: AppFonts.mulish.s16w700(
                                color: colors.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Transaction> _filterTransactionsByPeriod({
    required List<Transaction> transactions,
    required DateTime selectedMonth,
    required AnalyticsPeriod period,
  }) {
    final now = DateTime.now();

    late DateTime start;
    late DateTime end;

    switch (period) {
      case AnalyticsPeriod.year:
        start = DateTime(selectedMonth.year, 1, 1);
        end = DateTime(selectedMonth.year + 1, 1, 1);
        break;

      case AnalyticsPeriod.threeMonths:
        start = DateTime(selectedMonth.year, selectedMonth.month - 2, 1);
        end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
        break;

      case AnalyticsPeriod.month:
        start = DateTime(selectedMonth.year, selectedMonth.month, 1);
        end = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
        break;

      case AnalyticsPeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(Duration(days: today.weekday - 1));
        end = start.add(const Duration(days: 7));
        break;

      case AnalyticsPeriod.day:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        break;
    }

    final filtered = transactions.where((transaction) {
      final date = transaction.dateTime;
      return !date.isBefore(start) && date.isBefore(end);
    }).toList();

    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return filtered;
  }

  double _calculateTotal(
      List<Transaction> transactions,
      TransactionType type,
      ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold<double>(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  _ChartData _buildChartData({
    required List<Transaction> transactions,
    required AnalyticsPeriod period,
    required DateTime selectedMonth,
  }) {
    final pointCount = _getPointCount(period);
    final income = List<double>.filled(pointCount, 0);
    final expense = List<double>.filled(pointCount, 0);

    for (final transaction in transactions) {
      final index = _getTransactionPointIndex(
        transaction.dateTime,
        period,
        selectedMonth,
        pointCount,
      );

      if (index < 0 || index >= pointCount) continue;

      if (transaction.type == TransactionType.income) {
        income[index] += transaction.amount;
      } else {
        expense[index] += transaction.amount;
      }
    }

    return _ChartData(
      incomePoints: income,
      expensePoints: expense,
    );
  }

  int _getPointCount(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.year:
        return 12;
      case AnalyticsPeriod.threeMonths:
        return 3;
      case AnalyticsPeriod.month:
        return 4;
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.day:
        return 6;
    }
  }

  int _getTransactionPointIndex(
      DateTime date,
      AnalyticsPeriod period,
      DateTime selectedMonth,
      int pointCount,
      ) {
    switch (period) {
      case AnalyticsPeriod.year:
        return date.month - 1;

      case AnalyticsPeriod.threeMonths:
        final start = DateTime(selectedMonth.year, selectedMonth.month - 2, 1);
        return (date.year - start.year) * 12 + date.month - start.month;

      case AnalyticsPeriod.month:
        final day = date.day;
        if (day <= 7) return 0;
        if (day <= 14) return 1;
        if (day <= 21) return 2;
        return 3;

      case AnalyticsPeriod.week:
        return date.weekday - 1;

      case AnalyticsPeriod.day:
        final hour = date.hour;
        if (hour < 4) return 0;
        if (hour < 8) return 1;
        if (hour < 12) return 2;
        if (hour < 16) return 3;
        if (hour < 20) return 4;
        return 5;
    }
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0.00', 'ru_RU');
    return '${formatter.format(value)} UZS';
  }

  String _getPeriodTitle(
      AnalyticsPeriod period,
      DateTime selectedMonth,
      ) {
    switch (period) {
      case AnalyticsPeriod.year:
        return '${selectedMonth.year} год';
      case AnalyticsPeriod.threeMonths:
        return 'Последние 3 месяца';
      case AnalyticsPeriod.month:
        return DateFormat('MMMM yyyy', 'ru_RU').format(selectedMonth);
      case AnalyticsPeriod.week:
        return 'Текущая неделя';
      case AnalyticsPeriod.day:
        return 'Сегодня';
    }
  }
}

class _AnalyticsPeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _AnalyticsPeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodButton(
          title: 'год',
          isSelected: selectedPeriod == AnalyticsPeriod.year,
          onTap: () => onChanged(AnalyticsPeriod.year),
        ),
        const SizedBox(width: 8),
        _PeriodButton(
          title: '3 месяца',
          isSelected: selectedPeriod == AnalyticsPeriod.threeMonths,
          onTap: () => onChanged(AnalyticsPeriod.threeMonths),
        ),
        const SizedBox(width: 8),
        _PeriodButton(
          title: 'месяц',
          isSelected: selectedPeriod == AnalyticsPeriod.month,
          onTap: () => onChanged(AnalyticsPeriod.month),
        ),
        const SizedBox(width: 8),
        _PeriodButton(
          title: 'неделя',
          isSelected: selectedPeriod == AnalyticsPeriod.week,
          onTap: () => onChanged(AnalyticsPeriod.week),
        ),
        const SizedBox(width: 8),
        _PeriodButton(
          title: 'день',
          isSelected: selectedPeriod == AnalyticsPeriod.day,
          onTap: () => onChanged(AnalyticsPeriod.day),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.blue.withOpacity(0.85)
                  : colors.text.withOpacity(0.45),
              width: 1.3,
            ),
          ),
          child: FittedBox(
            child: Text(
              title,
              style: AppFonts.mulish.s12w700(
                color: isSelected
                    ? AppColors.blue.withOpacity(0.85)
                    : colors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsChartCard extends StatelessWidget {
  final List<double> incomePoints;
  final List<double> expensePoints;
  final AppThemeColors colors;

  const _AnalyticsChartCard({
    required this.incomePoints,
    required this.expensePoints,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.text.withOpacity(0.45),
          width: 1.2,
        ),
      ),
      child: CustomPaint(
        painter: AnalyticsLineChartPainter(
          incomePoints: incomePoints,
          expensePoints: expensePoints,
        ),
      ),
    );
  }
}


class _ChartData {
  final List<double> incomePoints;
  final List<double> expensePoints;

  const _ChartData({
    required this.incomePoints,
    required this.expensePoints,
  });
}

class AnalyticsTransactionsScreen extends StatelessWidget {
  final String title;
  final String periodLabel;
  final List<Transaction> transactions;

  const AnalyticsTransactionsScreen({
    super.key,
    required this.title,
    required this.periodLabel,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final provider = context.read<TransactionProvider>();

    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        title: Text(
          title,
          style: AppFonts.mulish.s24w700(color: colors.text),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark
                  ? 'assets/images/kanban_bg_dark.png'
                  : 'assets/images/kanban_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      periodLabel,
                      style: AppFonts.mulish.s18w700(color: colors.text),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 110,
                          horizontal: 50,
                        ),
                        child: Text(
                          'Нет транзакций за этот период',
                          textAlign: TextAlign.center,
                          style: AppFonts.mulish.s16w400(
                            color: colors.text.withOpacity(0.60),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];

                        return TransactionTile(
                          transaction: transaction,
                          onDelete: () =>
                              provider.deleteTransaction(transaction.id),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}