import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:finance_app/core/state/providers/theme_provider.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../shared/widgets/stat_summary_widget.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int _previewTransactionCount = 4;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    // Загружаем данные dashboard и синхронизируем месяц в transactionProvider
    await dashboardProvider.loadCurrentMonth();
    transactionProvider.setMonth(dashboardProvider.selectedMonth);
    await transactionProvider.loadTransactions();
  }

  /// Refresh: запрашиваем новые данные с бэкенда
  Future<void> _onRefresh() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    await dashboardProvider.loadCurrentMonth();
    transactionProvider.setMonth(dashboardProvider.selectedMonth);
    // syncBeforeLoad = true — сначала синхронизирует с backend, потом загружает
    await transactionProvider.loadTransactions(syncBeforeLoad: true);
  }

  /// Переключить на предыдущий месяц
  Future<void> _previousMonth() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    await dashboardProvider.previousMonth();
    transactionProvider.setMonth(dashboardProvider.selectedMonth);
  }

  /// Переключить на следующий месяц
  Future<void> _nextMonth() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    await dashboardProvider.nextMonth();
    transactionProvider.setMonth(dashboardProvider.selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final isDark = themeProvider.isDark;
    final summary = dashboardProvider.summary;
    final currentBalance = summary?.balance ?? transactionProvider.currentBalance;
    final monthlyIncome = summary?.income ?? transactionProvider.totalIncome;
    final monthlyExpense = summary?.expense ?? transactionProvider.totalExpense;

    // Транзакции фильтруются по выбранному месяцу (selectedMonth синхронизирован)
    final transactions = transactionProvider.currentMonthTransactions;
    final previewTransactions = transactions.take(_previewTransactionCount).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Главная',
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
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Доходы',
                            sum: monthlyIncome.toString(),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.green,
                            sumColor: colors.text,
                            shadowColor: colors.shadow.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Расходы',
                            sum: monthlyExpense.toString(),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.red,
                            sumColor: colors.text,
                            shadowColor: colors.shadow.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Баланс',
                            sum: currentBalance.toString(),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.blue,
                            sumColor: colors.text,
                            shadowColor: colors.shadow.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatSummaryWidget(
                            title: 'Транзакции',
                            sum: transactions.length.toString(),
                            colorBackG: colors.backgroundLight,
                            titleColor: AppColors.orange,
                            sumColor: colors.text,
                            shadowColor: colors.shadow.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // ── Переключатель месяца ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: 24,
                            color: colors.text,
                          ),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          DateFormat('MMMM yyyy', 'ru_RU')
                              .format(dashboardProvider.selectedMonth),
                          style: AppFonts.mulish.s18w700(color: colors.text),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: colors.text,
                          ),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Заголовок "Последние транзакции" ─────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Последние транзакции',
                          style: AppFonts.mulish.s20w700(color: colors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Список транзакций за выбранный месяц ─────────────
                    if (transactionProvider.isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: CircularProgressIndicator(
                            color: AppColors.blue,
                          ),
                        ),
                      )
                    else if (transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 110,
                            horizontal: 50,
                          ),
                          child: Text(
                            'Нет транзакций за этот период',
                            style: AppFonts.mulish.s16w400(
                              color: colors.text.withOpacity(0.60),
                            ),
                            textAlign: TextAlign.center,
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
                            );
                          },
                        ),
                        if (transactions.length > previewTransactions.length) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.blue.withOpacity(0.5),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor:
                                colors.backgroundLight.withOpacity(0.15),
                              ),
                              onPressed: () {
                                // TODO: Navigate to full transactions list
                              },
                              child: Text(
                                'Смотреть все',
                                style: AppFonts.mulish.s16w700(
                                  color: AppColors.blue,
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
}