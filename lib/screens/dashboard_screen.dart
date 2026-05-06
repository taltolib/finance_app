import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  void _addTransaction() {
    // Show bottom sheet for adding transaction
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currentBalance = provider.currentBalance;
    final monthlyIncome = provider.getMonthlyIncome(_selectedMonth);
    final monthlyExpense = provider.getMonthlyExpense(_selectedMonth);
    final transactions = provider.getTransactionsForMonth(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HUMO Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текущий баланс',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat('#,##0.00', 'ru_RU').format(currentBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'HUMOCARD *7591',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Monthly Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Доходы',
                    monthlyIncome,
                    AppTheme.incomeColor,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Расходы',
                    monthlyExpense,
                    AppTheme.expenseColor,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'ru_RU').format(_selectedMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Transactions
            const Text(
              'Последние транзакции',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionTile(
                  transaction: transaction,
                  onDelete: () => provider.deleteTransaction(transaction.id),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat('#,##0.00', 'ru_RU').format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  State<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Добавить транзакцию',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Вставьте текст из Telegram...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addTransaction,
            child: const Text('Добавить'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _addTransaction() {
    final rawText = _controller.text.trim();
    if (rawText.isEmpty) return;

    final transaction = Transaction.parse(rawText);
    if (transaction != null) {
      context.read<TransactionProvider>().addTransaction(transaction);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Транзакция добавлена!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось распознать транзакцию')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}