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

  /// Инициализировать доски - попробовать загрузить с API, fallback на SQLite
  Future<void> initializeBoards() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Попытаться загрузить с API
      try {
        final response = await _apiService.getCurrentBoard();
        _currentBoard = response['data'] as Map<String, dynamic>;
        // Парсить колонки из ответа API
        // TODO: реализовать после получения структуры API ответа
      } catch (e) {
        // Fallback на SQLite
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

      // Попытаться загрузить с API
      try {
        _archivedBoards = await _apiService.getArchivedBoards();
      } catch (e) {
        // Fallback на пустой список для теста
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

    await DatabaseHelper.instance.updateKanbanCard(card, toColumnId);
    notifyListeners();
  }

  Future<void> updateCard(KanbanCard card, String columnId) async {
    await DatabaseHelper.instance.updateKanbanCard(card, columnId);
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

  /// Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Сбросить состояние
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
