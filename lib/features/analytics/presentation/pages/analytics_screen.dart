import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
 import 'package:finance_app/features/transactions/data/models/transaction.dart';
import '../../../../core/theme/colors/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Аналитика')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final txs = provider.currentMonthTransactions;
          final expenseMap = provider.expenseByPlace;
          final totalExpense = provider.totalExpense;
          final colors = Theme.of(context).extension<AppThemeColors>()!;
          final f = NumberFormat('#,##0.00', 'ru_RU');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Заголовок месяца
              Text(
                DateFormat('MMMM yyyy', 'ru').format(provider.selectedMonth),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Сводка
              Row(
                children: [
                  _SummaryCard(
                    label: 'Доходы',
                    value: '${f.format(provider.totalIncome)} UZS',
                    color: colors.text,
                    bgColor: colors.text,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Расходы',
                    value: '${f.format(provider.totalExpense)} UZS',
                    color: colors.text,
                    bgColor: colors.text,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Расходы по местам
              if (expenseMap.isNotEmpty) ...[
                const Text(
                  'Расходы по категориям',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...expenseMap.entries.map((entry) {
                  final percent = totalExpense > 0
                      ? (entry.value / totalExpense * 100)
                      : 0.0;
                  return _ExpenseBar(
                    place: entry.key,
                    amount: entry.value,
                    percent: percent.toDouble(),
                    color: colors.textGrey,
                    bgColor: colors.textGrey,
                    f: f,
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Все транзакции
              const Text(
                'Все транзакции',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (txs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Нет данных за этот месяц',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...txs.map((tx) => _AnalyticsTile(tx: tx, f: f)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBar extends StatelessWidget {
  final String place;
  final double amount;
  final double percent;
  final Color color;
  final Color bgColor;
  final NumberFormat f;

  const _ExpenseBar({
    required this.place,
    required this.amount,
    required this.percent,
    required this.color,
    required this.bgColor,
    required this.f,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  place,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${f.format(amount)} UZS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: bgColor,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTile extends StatelessWidget {
  final Transaction tx;
  final NumberFormat f;

  const _AnalyticsTile({required this.tx, required this.f});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final colors = Theme.of(context).extension<AppColors>()!;
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.location,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                Text(
                  DateFormat('HH:mm  dd.MM.yyyy').format(tx.dateTime),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Text(
            '$sign${f.format(tx.amount)} UZS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
// Ответственность: Отображение аналитики доходов и расходов с графиками и списком транзакций.