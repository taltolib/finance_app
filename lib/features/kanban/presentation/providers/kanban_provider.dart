import 'package:finance_app/features/kanban/data/models/kanban_model.dart';
import 'package:finance_app/services/database_helper.dart';
import 'package:flutter/material.dart';

class KanbanProvider with ChangeNotifier {
  List<KanbanColumn> _columns = [];

  List<KanbanColumn> get columns => _columns;

  Future<void> loadColumns() async {
    _columns = await DatabaseHelper.instance.getKanbanColumns();
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
      await DatabaseHelper.instance.insertKanbanColumn(column);
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
    await DatabaseHelper.instance.insertKanbanColumn(column);
    _columns.add(column);
    notifyListeners();
  }

  Future<void> updateColumnTitle(String columnId, String newTitle) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.title = newTitle;
    // In a real app, you'd update this in DB too
    notifyListeners();
  }

  Future<void> addCardToColumn(String columnId, KanbanCard card) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.cards.add(card);
    await DatabaseHelper.instance.insertKanbanCard(card, columnId);
    notifyListeners();
  }

  Future<void> moveCard(String cardId, String fromColumnId, String toColumnId) async {
    final fromColumn = _columns.firstWhere((c) => c.id == fromColumnId);
    final card = fromColumn.cards.firstWhere((c) => c.id == cardId);
    
    fromColumn.cards.remove(card);
    final toColumn = _columns.firstWhere((c) => c.id == toColumnId);
    toColumn.cards.add(card);
    
    await DatabaseHelper.instance.updateKanbanCard(card);
    notifyListeners();
  }

  Future<void> updateCard(KanbanCard card, String columnId) async {
    await DatabaseHelper.instance.updateKanbanCard(card);
    // Refresh local state
    final column = _columns.firstWhere((c) => c.id == columnId);
    final index = column.cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      column.cards[index] = card;
    }
    notifyListeners();
  }

  Future<void> deleteCard(String cardId) async {
    for (final column in _columns) {
      column.cards.removeWhere((c) => c.id == cardId);
    }
    await DatabaseHelper.instance.deleteKanbanCard(cardId);
    notifyListeners();
  }
}
