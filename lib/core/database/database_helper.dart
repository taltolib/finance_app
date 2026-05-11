import 'dart:ui';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../../../features/transactions/data/models/transaction.dart';
import '../../../features/kanban/data/models/kanban_model.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('CREATE TABLE IF NOT EXISTS kanban_columns (id TEXT PRIMARY KEY, title TEXT, color INTEGER)');
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
      },
    );
  }

  Future<void> _createTables(Database db) async {
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
    await db.execute('CREATE TABLE kanban_columns (id TEXT PRIMARY KEY, title TEXT, color INTEGER)');
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

  // --- Transactions ---
  Future<int> insertTransaction(Transaction tx) async {
    final db = await database;
    return db.insert('transactions', tx.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'dateTime DESC');
    return maps.map(Transaction.fromMap).toList();
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Kanban ---
  Future<void> insertKanbanColumn(KanbanColumn column) async {
    final db = await database;
    await db.insert('kanban_columns', {
      'id': column.id,
      'title': column.title,
      'color': column.color.toARGB32(),
    });
  }

  Future<List<KanbanColumn>> getKanbanColumns() async {
    final db = await database;
    final colMaps = await db.query('kanban_columns');
    List<KanbanColumn> columns = [];
    for (var m in colMaps) {
      final colId = m['id'] as String;
      final cardMaps = await db.query('kanban_cards', where: 'columnId = ?', whereArgs: [colId]);
      columns.add(KanbanColumn(
        id: colId,
        title: m['title'] as String,
        color: Color(m['color'] as int),
        cards: cardMaps.map((cm) => KanbanCard.fromMap(cm)).toList(),
      ));
    }
    return columns;
  }

  Future<void> insertKanbanCard(KanbanCard card, String columnId) async {
    final db = await database;
    var map = card.toMap();
    map['columnId'] = columnId;
    await db.insert('kanban_cards', map);
  }

  Future<void> updateKanbanCard(KanbanCard card, String columnId) async {
    final db = await database;
    var map = card.toMap();
    map['columnId'] = columnId;
    await db.update('kanban_cards', map, where: 'id = ?', whereArgs: [card.id]);
  }

  Future<void> deleteKanbanCard(String id) async {
    final db = await database;
    await db.delete('kanban_cards', where: 'id = ?', whereArgs: [id]);
  }
}
