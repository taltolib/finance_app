import 'package:flutter/material.dart';
import 'package:finance_app/shared/database/database_helper.dart' show DatabaseHelper;
import '../../data/models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  // Массив транзакции
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Текущий выбранный месяц для фильтрации
  DateTime _selectedMonth = DateTime.now();

  /// Даю транзакция для внешного чтение и только
  List<Transaction> get transactions => _transactions;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;


  // ─── Фильтрованные транзакции текущего месяца ──────────────────────────
  List<Transaction> get currentMonthTransactions => _transactions.where((tx) {
    return tx.dateTime.year == _selectedMonth.year &&
        tx.dateTime.month == _selectedMonth.month;
  }).toList();

  // Общий баланс (из последней транзакции)
  double get currentBalance => _transactions.isEmpty ? 0 : _transactions.first.balanceAfter;

  // ─── Статистика ────────────────────────────────────────────────────────
  double get totalIncome => currentMonthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => currentMonthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  // Расходы по местам (для круговой диаграммы)
  Map<String, double> get expenseByPlace {
    final Map<String, double> map = {};
    for (final tx in currentMonthTransactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.location] = (map[tx.location] ?? 0) + tx.amount;
      }
    }
    // Сортируем по убыванию
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  // ─── Загрузка из БД ────────────────────────────────────────────────────
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.getAllTransactions();
    } catch (e) {
      _error = 'Ошибка загрузки: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Добавление транзакции ──────────────────────────────────────────────
  Future<void> addTransaction(Transaction tx) async {
    final isDuplicate = _transactions.any((t) => t.id == tx.id);
    if (isDuplicate) return;

    await DatabaseHelper.instance.insertTransaction(tx);
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  // ─── Добавление из текста (парсинг) ────────────────────────────────────
  Future<String> addFromText(String rawText) async {
    final tx = Transaction.parse(rawText);
    if (tx == null) {
      return 'Не удалось распознать сообщение. Убедитесь, что вставили текст полностью.';
    }

    await addTransaction(tx);
    return 'ok';
  }

  // ─── Удаление ──────────────────────────────────────────────────────────
  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ─── Управление месяцами ───────────────────────────────────────────────
  void setMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }
}
