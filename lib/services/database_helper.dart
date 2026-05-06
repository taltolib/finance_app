import 'dart:ui';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart' as tx;
import 'package:finance_app/features/kanban/data/models/kanban_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static DatabaseHelper get instance => _instance;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'humo_tracker.db');
    return await openDatabase(
      path,
      version: 2, // Increased version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS kanban_columns (
          id TEXT PRIMARY KEY,
          title TEXT,
          color INTEGER,
          cards TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS kanban_cards (
          id TEXT PRIMARY KEY,
          transactionId TEXT,
          cardColor INTEGER,
          note TEXT,
          status TEXT,
          createdAt TEXT,
          columnId TEXT,
          FOREIGN KEY (columnId) REFERENCES kanban_columns (id)
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type INTEGER,
        amount REAL,
        location TEXT,
        cardNumber TEXT,
        dateTime TEXT,
        balanceAfter REAL,
        rawText TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE kanban_columns (
        id TEXT PRIMARY KEY,
        title TEXT,
        color INTEGER,
        cards TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE kanban_cards (
        id TEXT PRIMARY KEY,
        transactionId TEXT,
        cardColor INTEGER,
        note TEXT,
        status TEXT,
        createdAt TEXT,
        columnId TEXT,
        FOREIGN KEY (columnId) REFERENCES kanban_columns (id)
      )
    ''');
  }


  Future<void> insertTransaction(tx.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<tx.Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'dateTime DESC');
    return maps.map((map) => tx.Transaction.fromMap(map)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Kanban Columns
  Future<void> insertKanbanColumn(KanbanColumn column) async {
    final db = await database;
    await db.insert('kanban_columns', {
      'id': column.id,
      'title': column.title,
      'color': column.color.value,
      'cards': '', // Will handle cards separately
    });
  }

  Future<List<KanbanColumn>> getKanbanColumns() async {
    final db = await database;
    final maps = await db.query('kanban_columns');
    final columns = <KanbanColumn>[];
    for (final map in maps) {
      final column = KanbanColumn(
        id: map['id'] as String,
        title: map['title'] as String,
      color: Color(map['color'] as int),
        cards: [],
      );
      final cards = await getKanbanCardsForColumn(column.id);
      column.cards.addAll(cards);
      columns.add(column);
    }
    return columns;
  }

  // Kanban Cards
  Future<void> insertKanbanCard(KanbanCard card, String columnId) async {
    final db = await database;
    await db.insert('kanban_cards', {
      ...card.toMap(),
      'columnId': columnId,
    });
  }

  Future<List<KanbanCard>> getKanbanCardsForColumn(String columnId) async {
    final db = await database;
    final maps = await db.query('kanban_cards', where: 'columnId = ?', whereArgs: [columnId]);
    return maps.map((map) => KanbanCard.fromMap(map)).toList();
  }

  Future<void> updateKanbanCard(KanbanCard card) async {
    final db = await database;
    await db.update('kanban_cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<void> deleteKanbanCard(String id) async {
    final db = await database;
    await db.delete('kanban_cards', where: 'id = ?', whereArgs: [id]);
  }
}