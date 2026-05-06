import 'package:flutter/material.dart';
import '../models/kanban_model.dart';
import '../services/database_helper.dart';

class KanbanProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<KanbanColumn> _columns = [];

  List<KanbanColumn> get columns => _columns;

  Future<void> loadColumns() async {
    _columns = await _db.getKanbanColumns();
    if (_columns.isEmpty) {
      await _initializeDefaultColumns();
    }
    notifyListeners();
  }

  Future<void> _initializeDefaultColumns() async {
    final defaultColumns = [
      KanbanColumn(
        id: 'all',
        title: 'Все карты',
        color: Colors.blue,
        cards: [],
      ),
      KanbanColumn(
        id: 'income',
        title: 'Доходы',
        color: Colors.green,
        cards: [],
      ),
      KanbanColumn(
        id: 'expense',
        title: 'Расходы',
        color: Colors.red,
        cards: [],
      ),
    ];

    for (final column in defaultColumns) {
      await _db.insertKanbanColumn(column);
    }

    _columns = defaultColumns;
  }

  Future<void> addColumn(String title, Color color) async {
    final column = KanbanColumn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      color: color,
      cards: [],
    );
    await _db.insertKanbanColumn(column);
    _columns.add(column);
    notifyListeners();
  }

  Future<void> updateColumnTitle(String columnId, String newTitle) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.title = newTitle;
    // Note: Database update for column title not implemented in this simple version
    notifyListeners();
  }

  Future<void> addCardToColumn(String columnId, KanbanCard card) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.cards.add(card);
    await _db.insertKanbanCard(card, columnId);
    notifyListeners();
  }

  Future<void> moveCard(String cardId, String fromColumnId, String toColumnId) async {
    final fromColumn = _columns.firstWhere((c) => c.id == fromColumnId);
    final card = fromColumn.cards.firstWhere((c) => c.id == cardId);
    fromColumn.cards.remove(card);
    final toColumn = _columns.firstWhere((c) => c.id == toColumnId);
    toColumn.cards.add(card);
    // Update database
    await _db.updateKanbanCard(card);
    notifyListeners();
  }

  Future<void> updateCard(KanbanCard card) async {
    await _db.updateKanbanCard(card);
    notifyListeners();
  }

  Future<void> deleteCard(String cardId) async {
    for (final column in _columns) {
      column.cards.removeWhere((c) => c.id == cardId);
    }
    await _db.deleteKanbanCard(cardId);
    notifyListeners();
  }
}