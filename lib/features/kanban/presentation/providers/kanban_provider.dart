import 'package:flutter/material.dart';
import 'package:finance_app/core/database/database_helper.dart';
import 'package:finance_app/features/kanban/data/models/kanban_model.dart';
import 'package:finance_app/features/kanban/data/services/boards_api_service.dart';

class KanbanProvider with ChangeNotifier {
  final BoardsApiService _apiService = BoardsApiService();

  // Current board state
  List<KanbanColumn> _columns = [];
  Map<String, dynamic>? _currentBoard;

  // Archived boards
  List<Map<String, dynamic>> _archivedBoards = [];

  // UI states
  bool _isLoadingColumns = false;
  bool _isLoadingArchivedBoards = false;
  bool _isLoadingCurrentBoard = false;
  bool _isLoading = false;
  String? _error;
  bool _isEmpty = false;

  // Getters
  List<KanbanColumn> get columns => _columns;
  Map<String, dynamic>? get currentBoard => _currentBoard;
  List<Map<String, dynamic>> get archivedBoards => _archivedBoards;

  bool get isLoadingColumns => _isLoadingColumns;
  bool get isLoadingArchivedBoards => _isLoadingArchivedBoards;
  bool get isLoadingCurrentBoard => _isLoadingCurrentBoard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _isEmpty;

  /// Инициализировать доски
  Future<void> initializeBoards() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final response = await _apiService.getCurrentBoard();
        _currentBoard = response['data'] as Map<String, dynamic>;
      } catch (e) {
        await loadColumns();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки досок: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузить текущую месячную доску
  Future<void> loadCurrentBoard() async {
    try {
      _isLoadingCurrentBoard = true;
      _error = null;
      notifyListeners();

      await loadColumns();

      _isLoadingCurrentBoard = false;
      _isEmpty = _columns.isEmpty;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки доски: $e';
      _isLoadingCurrentBoard = false;
      notifyListeners();
    }
  }

  /// Загрузить архивированные доски
  Future<void> loadArchivedBoards() async {
    try {
      _isLoadingArchivedBoards = true;
      _error = null;
      notifyListeners();

      try {
        _archivedBoards = await _apiService.getArchivedBoards();
      } catch (e) {
        _archivedBoards = [];
      }

      _isLoadingArchivedBoards = false;
      _isEmpty = _archivedBoards.isEmpty;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки архивированных досок: $e';
      _isLoadingArchivedBoards = false;
      notifyListeners();
    }
  }

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
        id: 'unsorted',
        title: 'Неразобранные',
        color: Colors.blue,
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

  /// ✅ Переименовать колонку
  Future<void> renameColumn(String columnId, String newTitle) async {
    final index = _columns.indexWhere((c) => c.id == columnId);
    if (index == -1) return;

    _columns[index].title = newTitle;

    // Попробовать обновить через API если есть currentBoard
    if (_currentBoard != null) {
      try {
        final boardId = _currentBoard!['id']?.toString() ?? '';
        if (boardId.isNotEmpty) {
          await _apiService.updateColumn(
            boardId: boardId,
            columnId: columnId,
            title: newTitle,
          );
        }
      } catch (_) {
        // Fallback — обновление только локально
      }
    }

    notifyListeners();
  }

  /// ✅ Удалить колонку (с переносом карточек в «Неразобранные»)
  Future<void> deleteColumn(String columnId) async {
    final index = _columns.indexWhere((c) => c.id == columnId);
    if (index == -1) return;

    final deletedColumn = _columns[index];

    // Перенести карточки в «Неразобранные» если они там есть
    final unsortedIndex = _columns.indexWhere((c) => c.id == 'unsorted');
    if (unsortedIndex != -1 && deletedColumn.cards.isNotEmpty) {
      for (final card in deletedColumn.cards) {
        _columns[unsortedIndex].cards.add(card);
        await DatabaseHelper.instance.updateKanbanCard(card, 'unsorted');
      }
    } else {
      // Удалить карточки из БД
      for (final card in deletedColumn.cards) {
        await DatabaseHelper.instance.deleteKanbanCard(card.id);
      }
    }

    _columns.removeAt(index);

    // Попробовать удалить через API
    if (_currentBoard != null) {
      try {
        final boardId = _currentBoard!['id']?.toString() ?? '';
        if (boardId.isNotEmpty) {
          await _apiService.deleteColumn(
            boardId: boardId,
            columnId: columnId,
          );
        }
      } catch (_) {
        // Fallback — удаление только локально
      }
    }

    notifyListeners();
  }

  Future<void> updateColumnTitle(String columnId, String newTitle) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.title = newTitle;
    notifyListeners();
  }

  Future<void> addCardToColumn(String columnId, KanbanCard card) async {
    final column = _columns.firstWhere((c) => c.id == columnId);
    column.cards.add(card);
    await DatabaseHelper.instance.insertKanbanCard(card, columnId);
    notifyListeners();
  }

  Future<void> moveCard(
      String cardId, String fromColumnId, String toColumnId) async {
    final fromColumn = _columns.firstWhere((c) => c.id == fromColumnId);
    final card = fromColumn.cards.firstWhere((c) => c.id == cardId);

    fromColumn.cards.remove(card);
    final toColumn = _columns.firstWhere((c) => c.id == toColumnId);
    toColumn.cards.add(card);

    await DatabaseHelper.instance.updateKanbanCard(card, toColumnId);

    // Попробовать синхронизировать через API
    if (_currentBoard != null) {
      try {
        final boardId = _currentBoard!['id']?.toString() ?? '';
        if (boardId.isNotEmpty) {
          await _apiService.moveCard(
            boardId: boardId,
            cardId: cardId,
            toColumnId: toColumnId,
          );
        }
      } catch (_) {
        // Fallback — перемещение только локально
      }
    }

    notifyListeners();
  }

  Future<void> updateCard(KanbanCard card, String columnId) async {
    await DatabaseHelper.instance.updateKanbanCard(card, columnId);
    final column = _columns.firstWhere((c) => c.id == columnId);
    final idx = column.cards.indexWhere((c) => c.id == card.id);
    if (idx != -1) {
      column.cards[idx] = card;
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
}