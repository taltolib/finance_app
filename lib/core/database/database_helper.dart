import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

import '../../data/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'humo_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            place TEXT NOT NULL,
            cardNumber TEXT NOT NULL,
            dateTime TEXT NOT NULL,
            balance REAL NOT NULL,
            rawText TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(Transaction tx) async {
    final db = await database;
    return db.insert(
      'transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // дубликаты игнорируем
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'dateTime DESC',
    );
    return maps.map(Transaction.fromMap).toList();
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    final db = await database;
    final from = DateTime(year, month, 1).toIso8601String();
    final to = DateTime(year, month + 1, 1).toIso8601String();
    final maps = await db.query(
      'transactions',
      where: "dateTime >= ? AND dateTime < ?",
      whereArgs: [from, to],
      orderBy: 'dateTime DESC',
    );
    return maps.map(Transaction.fromMap).toList();
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('transactions');
  }

  // Статистика за месяц
  Future<Map<String, double>> getMonthlyStats(int year, int month) async {
    final txs = await getTransactionsByMonth(year, month);
    double income = 0, expense = 0;
    for (final tx in txs) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        expense += tx.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }
}