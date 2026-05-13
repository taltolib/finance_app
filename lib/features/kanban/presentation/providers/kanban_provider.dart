import 'package:flutter/material.dart';
import 'package:finance_app/core/database/database_helper.dart';
import 'package:finance_app/features/kanban/data/models/kanban_model.dart';
import 'package:finance_app/features/kanban/data/services/boards_api_service.dart';

class KanbanProvider with ChangeNotifier {
  final BoardsApiService _apiService = BoardsApiService();

  List<KanbanColumn> _columns = [];
  Map<String, dynamic>? _currentBoard;
  List<Map<String, dynamic>> _archivedBoards = [];

  bool _isLoadingColumns = false;
  bool _isLoadingArchivedBoards = false;
  bool _isLoadingCurrentBoard = false;
  bool _isLoading = false;
  String? _error;
  bool _isEmpty = false;

  List<KanbanColumn> get columns => _columns;
  Map<String, dynamic>? get currentBoard => _currentBoard;
  List<Map<String, dynamic>> get archivedBoards => _archivedBoards;
  bool get isLoadingColumns => _isLoadingColumns;
  bool get isLoadingArchivedBoards => _isLoadingArchivedBoards;
  bool get isLoadingCurrentBoard => _isLoadingCurrentBoard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _isEmpty;

  String get boardId => _currentBoard?['id']?.toString() ?? _monthId(DateTime.now());

  String get uncategorizedColumnId {
    final system = _columns.where((c) => c.id.endsWith(':uncategorized') || c.id == 'uncategorized' || c.id == 'unsorted');
    return system.isNotEmpty ? system.first.id : '$boardId:uncategorized';
  }

  Future<void> initializeBoards() => loadCurrentBoard();

  Future<void> loadCurrentBoard() async {
    try {
      _isLoadingCurrentBoard = true;
      _error = null;
      notifyListeners();

      final board = await _apiService.getCurrentBoard();
      _currentBoard = board;
      _columns = _columnsFromBoard(board);

      if (_columns.isEmpty) {
        await _initializeDefaultColumns();
      }

      _isEmpty = _columns.isEmpty;
    } catch (e) {
      _error = 'Ошибка загрузки доски: $e';
      await loadColumns();
    } finally {
      _isLoadingCurrentBoard = false;
      notifyListeners();
    }
  }

  Future<void> loadArchivedBoards() async {
    try {
      _isLoadingArchivedBoards = true;
      _error = null;
      notifyListeners();
      _archivedBoards = await _apiService.getArchivedBoards();
      _isEmpty = _archivedBoards.isEmpty;
    } catch (e) {
      _error = 'Ошибка загрузки архивированных досок: $e';
      _archivedBoards = [];
    } finally {
      _isLoadingArchivedBoards = false;
      notifyListeners();
    }
  }

  Future<void> loadColumns() async {
    _isLoadingColumns = true;
    notifyListeners();
    try {
      _columns = await DatabaseHelper.instance.getKanbanColumns();
      if (_columns.isEmpty) await _initializeDefaultColumns();
    } finally {
      _isLoadingColumns = false;
      notifyListeners();
    }
  }

  Future<void> _initializeDefaultColumns() async {
    final column = KanbanColumn(
      id: 'uncategorized',
      title: 'Неразобранные',
      color: Colors.blue,
      cards: [],
    );
    await DatabaseHelper.instance.insertKanbanColumn(column);
    _columns = [column];
  }

  Future<void> addColumn(String title, Color color) async {
    final tempColumn = KanbanColumn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      color: color,
      cards: [],
    );

    _columns.add(tempColumn);
    notifyListeners();

    try {
      final created = await _apiService.createColumn(boardId: boardId, title: title);
      final index = _columns.indexWhere((c) => c.id == tempColumn.id);
      if (index != -1) {
        _columns[index] = KanbanColumn(
          id: created['id']?.toString() ?? tempColumn.id,
          title: created['title']?.toString() ?? title,
          color: color,
          cards: [],
        );
      }
    } catch (_) {
      await DatabaseHelper.instance.insertKanbanColumn(tempColumn);
    }

    notifyListeners();
  }

  Future<void> renameColumn(String columnId, String newTitle) async {
    final index = _columns.indexWhere((c) => c.id == columnId);
    if (index == -1) return;

    _columns[index].title = newTitle;
    notifyListeners();

    try {
      await _apiService.updateColumn(boardId: boardId, columnId: columnId, title: newTitle);
    } catch (e) {
      _error = 'Колонка переименована локально, но backend вернул ошибку: $e';
      notifyListeners();
    }
  }

  Future<void> deleteColumn(String columnId) async {
    final index = _columns.indexWhere((c) => c.id == columnId);
    if (index == -1) return;

    final deletedColumn = _columns[index];
    final uncategorized = uncategorizedColumnId;
    final unsortedIndex = _columns.indexWhere((c) => c.id == uncategorized);

    if (unsortedIndex != -1 && deletedColumn.cards.isNotEmpty) {
      for (final card in deletedColumn.cards) {
        _columns[unsortedIndex].cards.add(card);
      }
    }

    _columns.removeAt(index);
    notifyListeners();

    try {
      await _apiService.deleteColumn(boardId: boardId, columnId: columnId);
    } catch (e) {
      _error = 'Колонка удалена локально, но backend вернул ошибку: $e';
      notifyListeners();
    }
  }

  Future<void> updateColumnTitle(String columnId, String newTitle) => renameColumn(columnId, newTitle);

  Future<void> addCardToColumn(String columnId, KanbanCard card) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    if (column.cards.any((c) => c.transactionId == card.transactionId && card.transactionId != null)) return;
    column.cards.add(card);
    await DatabaseHelper.instance.insertKanbanCard(card, columnId);
    notifyListeners();
  }

  Future<void> moveCard(String cardId, String fromColumnId, String toColumnId) async {
    final fromColumn = _columns.firstWhere((c) => c.id == fromColumnId);
    final card = fromColumn.cards.firstWhere((c) => c.id == cardId);
    final toColumn = _columns.firstWhere((c) => c.id == toColumnId);

    fromColumn.cards.remove(card);
    toColumn.cards.add(card);
    notifyListeners();

    try {
      final transactionId = card.transactionId ?? card.id.replaceFirst('tx_', '');
      await _apiService.moveCard(
        boardId: boardId,
        transactionId: transactionId,
        fromColumnId: fromColumnId,
        toColumnId: toColumnId,
        newIndex: toColumn.cards.length - 1,
      );
    } catch (_) {
      await DatabaseHelper.instance.updateKanbanCard(card, toColumnId);
    }
  }

  Future<void> updateCard(KanbanCard card, String columnId) async {
    await DatabaseHelper.instance.updateKanbanCard(card, columnId);
    final column = _columns.firstWhere((c) => c.id == columnId);
    final idx = column.cards.indexWhere((c) => c.id == card.id);
    if (idx != -1) column.cards[idx] = card;
    notifyListeners();
  }

  Future<void> deleteCard(String cardId) async {
    for (final column in _columns) {
      column.cards.removeWhere((c) => c.id == cardId);
    }
    await DatabaseHelper.instance.deleteKanbanCard(cardId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _columns = [];
    _currentBoard = null;
    _archivedBoards = [];
    _isLoadingColumns = false;
    _isLoadingArchivedBoards = false;
    _isLoadingCurrentBoard = false;
    _isLoading = false;
    _error = null;
    _isEmpty = false;
    notifyListeners();
  }

  List<KanbanColumn> _columnsFromBoard(Map<String, dynamic> board) {
    final rawColumns = board['columns'] as List? ?? const [];
    return rawColumns.whereType<Map<String, dynamic>>().map((json) {
      final cards = (json['cards'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((card) => KanbanCard(
                id: card['id']?.toString() ?? 'tx_${card['transaction_id']}',
                transactionId: card['transaction_id']?.toString(),
                cardColor: const Color(0xFF1C1C1E),
                note: (card['place'] ?? card['merchant'])?.toString(),
                status: json['title']?.toString() ?? '',
                createdAt: DateTime.tryParse('${card['datetime'] ?? card['date'] ?? ''}') ?? DateTime.now(),
              ))
          .toList();

      return KanbanColumn(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Колонка',
        color: Colors.blue,
        cards: cards,
      );
    }).toList();
  }

  static String _monthId(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';
}
