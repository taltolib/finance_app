import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/provider/transaction_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction.dart';
import '../analytics/analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildBalanceCard(context),
          _buildMonthPicker(context),
          _buildStatsRow(context),
          _buildTransactionList(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          const Text('HUMO Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          tooltip: 'Аналитика',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final lastBalance = provider.transactions.isNotEmpty
              ? provider.transactions.first.balance
              : 0.0;
          return Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текущий баланс',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAmount(lastBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.transactions.isNotEmpty
                        ? provider.transactions.first.cardNumber
                        : 'HUMOCARD',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final now = DateTime.now();
          final isCurrentMonth =
              provider.selectedMonth.year == now.year &&
                  provider.selectedMonth.month == now.month;

          return Container(
            color: const Color(0xFF1A1A2E),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: provider.previousMonth,
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardTheme.color,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy', 'ru').format(provider.selectedMonth),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: isCurrentMonth ? null : provider.nextMonth,
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardTheme.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final colors = Theme.of(context).extension<AppColors>()!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                  label: 'Доходы',
                  amount: provider.totalIncome,
                  color: colors.income,
                  bgColor: colors.incomeLight,
                  icon: Icons.arrow_downward_rounded,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Расходы',
                  amount: provider.totalExpense,
                  color: colors.expense,
                  bgColor: colors.expenseLight,
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final txs = provider.currentMonthTransactions;
        if (txs.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Нет транзакций за этот месяц',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите «Добавить» и вставьте\nсообщение от @HUMOcardbot',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                // Заголовок секции
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Text(
                      'Транзакции (${txs.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                final tx = txs[i - 1];
                return _TransactionTile(tx: tx);
              },
              childCount: txs.length + 1,
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    final f = NumberFormat('#,##0.00', 'ru_RU');
    return '${f.format(amount)} UZS';
  }
}

// ─── Карточка статистики ────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,##0', 'ru_RU');
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      '${f.format(amount)} UZS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Элемент списка транзакций ────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? colors.income : colors.expense;
    final bgColor = isIncome ? colors.incomeLight : colors.expenseLight;
    final sign = isIncome ? '+' : '-';
    final f = NumberFormat('#,##0.00', 'ru_RU');
    final timeF = DateFormat('HH:mm');
    final dateF = DateFormat('dd.MM');

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) {
        context.read<TransactionProvider>().deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Транзакция удалена'), duration: Duration(seconds: 2)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.place,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${tx.cardNumber}  ·  ${timeF.format(tx.dateTime)} ${dateF.format(tx.dateTime)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${f.format(tx.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Баланс: ${f.format(tx.balance)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}