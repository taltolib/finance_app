import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await _db.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await loadTransactions();
  }

  double get currentBalance {
    if (_transactions.isEmpty) return 0;
    return _transactions.first.balanceAfter;
  }

  double getMonthlyIncome(DateTime month) {
    return _transactions
        .where((t) => t.type == TransactionType.income &&  t.dateTime.year == month.year &&  t.dateTime.month == month.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpense(DateTime month) {
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.dateTime.year == month.year &&
            t.dateTime.month == month.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<Transaction> getTransactionsForMonth(DateTime month) {
    return _transactions
        .where((t) =>
            t.dateTime.year == month.year &&
            t.dateTime.month == month.month)
        .toList();
  }
}