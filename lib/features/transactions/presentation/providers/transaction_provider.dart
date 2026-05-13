import 'package:flutter/material.dart';
import 'package:finance_app/shared/database/database_helper.dart' show DatabaseHelper;
import '../../data/models/transaction.dart';
import '../../data/services/transactions_api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsApiService _apiService = TransactionsApiService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  DateTime _selectedMonth = DateTime.now();

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;

  List<Transaction> get currentMonthTransactions => _transactions.where((tx) {
        return tx.dateTime.year == _selectedMonth.year && tx.dateTime.month == _selectedMonth.month;
      }).toList();

  double get currentBalance => _transactions.isEmpty ? 0 : _transactions.first.balanceAfter;

  double get totalIncome => currentMonthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => currentMonthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get expenseByPlace {
    final map = <String, double>{};
    for (final tx in currentMonthTransactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.location] = (map[tx.location] ?? 0) + tx.amount;
      }
    }
    return Map.fromEntries(map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  Future<void> loadTransactions({bool syncBeforeLoad = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (syncBeforeLoad) {
        await syncTransactions(notify: false);
      }

      _transactions = await _apiService.getTransactions(limit: 500);
      _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      try {
        _transactions = await DatabaseHelper.instance.getAllTransactions();
        _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      } catch (_) {
        _error = 'Ошибка загрузки транзакций: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncTransactions({bool notify = true}) async {
    if (notify) {
      _isSyncing = true;
      _error = null;
      notifyListeners();
    }

    try {
      var offsetId = null as int?;
      var hasMore = true;
      while (hasMore) {
        final result = await _apiService.syncTransactions(limit: 500, offsetId: offsetId);
        hasMore = result.hasMore;
        offsetId = result.nextOffsetId;
        if (offsetId == null) break;
      }
    } catch (e) {
      _error = 'Ошибка синхронизации транзакций: $e';
    } finally {
      if (notify) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshFromBackend() async {
    await syncTransactions();
    await loadTransactions();
  }

  Future<void> addTransaction(Transaction tx) async {
    final isDuplicate = _transactions.any((t) => t.id == tx.id);
    if (isDuplicate) return;

    await DatabaseHelper.instance.insertTransaction(tx);
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
  }

  Future<String> addFromText(String rawText) async {
    final tx = Transaction.parse(rawText);
    if (tx == null) return 'Не удалось распознать сообщение. Убедитесь, что вставили текст полностью.';
    await addTransaction(tx);
    return 'ok';
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

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
