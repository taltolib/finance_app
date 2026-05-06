// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../core/provider/transaction_providerr.dart';
// import '../models/transaction.dart';
// import '../widgets/transaction_tile.dart';
// import '../theme/app_theme.dart';
//
// class AnalyticsScreen extends StatefulWidget {
//   const AnalyticsScreen({super.key});
//
//   @override
//   State<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }
//
// class _AnalyticsScreenState extends State<AnalyticsScreen> {
//   String _selectedPeriod = 'Месяц';
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<TransactionProvider>();
//     final transactions = provider.transactions;
//
//     // Filter transactions based on period
//     final filteredTransactions = _filterTransactions(transactions);
//     final income = filteredTransactions
//         .where((t) => t.type == TransactionType.income)
//         .fold(0.0, (sum, t) => sum + t.amount);
//     final expense = filteredTransactions
//         .where((t) => t.type == TransactionType.expense)
//         .fold(0.0, (sum, t) => sum + t.amount);
//
//     // Top expenses
//     final topExpenses = _getTopExpenses(filteredTransactions);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Аналитика'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: ['День', 'Неделя', 'Месяц', 'Год'].map((period) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   child: FilterChip(
//                     label: Text(period),
//                     selected: _selectedPeriod == period,
//                     onSelected: (selected) {
//                       if (selected) {
//                         setState(() {
//                           _selectedPeriod = period;
//                         });
//                       }
//                     },
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Mini summary
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildSummaryCard('Доходы', income, AppTheme.incomeColor),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildSummaryCard('Расходы', expense, AppTheme.expenseColor),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Bar Chart
//             const Text(
//               'График расходов и доходов',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 200,
//               child: CustomBarChart(transactions: filteredTransactions),
//             ),
//             const SizedBox(height: 20),
//
//             // Top Expenses
//             const Text(
//               'Топ расходов',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ...topExpenses.map((entry) => _buildTopExpenseItem(entry)),
//             const SizedBox(height: 20),
//
//             // All transactions
//             const Text(
//               'Все транзакции',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: filteredTransactions.length,
//               itemBuilder: (context, index) {
//                 final transaction = filteredTransactions[index];
//                 return TransactionTile(
//                   transaction: transaction,
//                   onDelete: () => provider.deleteTransaction(transaction.id),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Transaction> _filterTransactions(List<Transaction> transactions) {
//     final now = DateTime.now();
//     switch (_selectedPeriod) {
//       case 'День':
//         return transactions.where((t) =>
//             t.dateTime.year == now.year &&
//             t.dateTime.month == now.month &&
//             t.dateTime.day == now.day).toList();
//       case 'Неделя':
//         final weekStart = now.subtract(Duration(days: now.weekday - 1));
//         return transactions.where((t) => t.dateTime.isAfter(weekStart)).toList();
//       case 'Месяц':
//         return transactions.where((t) =>
//             t.dateTime.year == now.year &&
//             t.dateTime.month == now.month).toList();
//       case 'Год':
//         return transactions.where((t) => t.dateTime.year == now.year).toList();
//       default:
//         return transactions;
//     }
//   }
//
//   List<MapEntry<String, double>> _getTopExpenses(List<Transaction> transactions) {
//     final expenses = transactions.where((t) => t.type == TransactionType.expense);
//     final grouped = <String, double>{};
//     for (final t in expenses) {
//       grouped[t.location] = (grouped[t.location] ?? 0) + t.amount;
//     }
//     final sorted = grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
//     return sorted.take(5).toList();
//   }
//
//   Widget _buildSummaryCard(String title, double amount, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               NumberFormat('#,##0.00', 'ru_RU').format(amount),
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopExpenseItem(MapEntry<String, double> entry) {
//     final totalExpense = _getTopExpenses(_filterTransactions(context.read<TransactionProvider>().transactions))
//         .fold(0.0, (sum, e) => sum + e.value);
//     final percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
//
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   entry.key,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   NumberFormat('#,##0.00', 'ru_RU').format(entry.value),
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: percentage / 100,
//               backgroundColor: AppTheme.expenseColor.withOpacity(0.2),
//               valueColor: AlwaysStoppedAnimation<Color>(AppTheme.expenseColor),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${percentage.toStringAsFixed(1)}%',
//               style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CustomBarChart extends StatelessWidget {
//   final List<Transaction> transactions;
//
//   const CustomBarChart({super.key, required this.transactions});
//
//   @override
//   Widget build(BuildContext context) {
//     // Simple bar chart implementation
//     // Group by day
//     final grouped = <DateTime, Map<String, double>>{};
//     for (final t in transactions) {
//       final day = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
//       grouped[day] ??= {'income': 0, 'expense': 0};
//       if (t.type == TransactionType.income) {
//         grouped[day]!['income'] = (grouped[day]!['income'] ?? 0) + t.amount;
//       } else {
//         grouped[day]!['expense'] = (grouped[day]!['expense'] ?? 0) + t.amount;
//       }
//     }
//
//     final days = grouped.keys.toList()..sort();
//     if (days.isEmpty) return const Center(child: Text('Нет данных'));
//
//     final maxAmount = grouped.values
//         .expand((v) => [v['income'] ?? 0, v['expense'] ?? 0])
//         .reduce((a, b) => a > b ? a : b);
//
//     return CustomPaint(
//       painter: BarChartPainter(grouped, days, maxAmount),
//       child: Container(),
//     );
//   }
// }
//
// class BarChartPainter extends CustomPainter {
//   final Map<DateTime, Map<String, double>> data;
//   final List<DateTime> days;
//   final double maxAmount;
//
//   BarChartPainter(this.data, this.days, this.maxAmount);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//     final barWidth = size.width / days.length * 0.8;
//     final spaceWidth = size.width / days.length * 0.2;
//
//     for (int i = 0; i < days.length; i++) {
//       final day = days[i];
//       final income = data[day]!['income'] ?? 0;
//       final expense = data[day]!['expense'] ?? 0;
//
//       // Income bar
//       paint.color = AppTheme.incomeColor;
//       final incomeHeight = maxAmount > 0 ? (income / maxAmount) * size.height : 0;
//       canvas.drawRect(
//         Rect.fromLTWH(
//           i * (barWidth + spaceWidth),
//           size.height - incomeHeight,
//           barWidth / 2,
//           incomeHeight.toDouble(),
//         ),
//         paint,
//       );
//
//       // Expense bar
//       paint.color = AppTheme.expenseColor;
//       final expenseHeight = maxAmount > 0 ? (expense / maxAmount) * size.height : 0;
//       canvas.drawRect(
//         Rect.fromLTWH(
//           i * (barWidth + spaceWidth) + barWidth / 2,
//           size.height - expenseHeight,
//           barWidth / 2,
//           expenseHeight.toDouble(),
//         ),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }