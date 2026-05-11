/// Boards API Service
/// Сервис для работы с досками расходов

import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';

class BoardsApiService {
  final ApiService _apiService = ApiService();

  /// Получить все доски
  Future<Map<String, dynamic>> getBoards() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.boards,
        needsAuth: true,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Получить текущую доску месяца
  Future<Map<String, dynamic>> getCurrentBoard() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.boardsCurrent,
        needsAuth: true,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Получить архивированные доски
  Future<List<Map<String, dynamic>>> getArchivedBoards() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.boardsArchived,
        needsAuth: true,
      );

      final data = response['data'] as List? ?? [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      rethrow;
    }
  }

  /// Получить одну доску
  Future<Map<String, dynamic>> getBoard(String id) async {
    try {
      final endpoint = ApiEndpoints.boardDetail.replaceAll('{id}', id);
      final response = await _apiService.get(
        endpoint,
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Создать новую доску
  Future<Map<String, dynamic>> createBoard({
    required String title,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.boards,
        body: {
          'title': title,
          'month': month,
          'year': year,
        },
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Обновить доску
  Future<Map<String, dynamic>> updateBoard({
    required String id,
    String? title,
    bool? isArchived,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (isArchived != null) body['is_archived'] = isArchived;

      final endpoint = ApiEndpoints.boardDetail.replaceAll('{id}', id);
      final response = await _apiService.patch(
        endpoint,
        body: body,
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Удалить доску
  Future<void> deleteBoard(String id) async {
    try {
      final endpoint = ApiEndpoints.boardDetail.replaceAll('{id}', id);
      await _apiService.delete(
        endpoint,
        needsAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Архивировать истекшие доски
  Future<Map<String, dynamic>> archiveExpiredBoards() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.boardsArchiveExpired,
        body: {},
        needsAuth: true,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // --- Column operations ---

  /// Создать колонку
  Future<Map<String, dynamic>> createColumn({
    required String boardId,
    required String title,
    required int color,
  }) async {
    try {
      final endpoint = ApiEndpoints.boardColumns.replaceAll('{boardId}', boardId);
      final response = await _apiService.post(
        endpoint,
        body: {
          'title': title,
          'color': color,
        },
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Обновить колонку
  Future<Map<String, dynamic>> updateColumn({
    required String boardId,
    required String columnId,
    String? title,
    int? color,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (color != null) body['color'] = color;

      final endpoint = ApiEndpoints.boardColumnDetail
          .replaceAll('{boardId}', boardId)
          .replaceAll('{columnId}', columnId);

      final response = await _apiService.patch(
        endpoint,
        body: body,
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Удалить колонку
  Future<void> deleteColumn({
    required String boardId,
    required String columnId,
  }) async {
    try {
      final endpoint = ApiEndpoints.boardColumnDetail
          .replaceAll('{boardId}', boardId)
          .replaceAll('{columnId}', columnId);

      await _apiService.delete(
        endpoint,
        needsAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // --- Card operations ---

  /// Создать карточку
  Future<Map<String, dynamic>> createCard({
    required String boardId,
    required String columnId,
    required String transactionId,
    String? note,
  }) async {
    try {
      final endpoint = ApiEndpoints.boardCards
          .replaceAll('{boardId}', boardId)
          .replaceAll('{columnId}', columnId);

      final response = await _apiService.post(
        endpoint,
        body: {
          'transaction_id': transactionId,
          'note': note,
        },
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Переместить карточку в другую колонку
  Future<Map<String, dynamic>> moveCard({
    required String boardId,
    required String cardId,
    required String toColumnId,
  }) async {
    try {
      final endpoint = ApiEndpoints.boardCardMove
          .replaceAll('{boardId}', boardId)
          .replaceAll('{cardId}', cardId);

      final response = await _apiService.patch(
        endpoint,
        body: {
          'to_column_id': toColumnId,
        },
        needsAuth: true,
      );

      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Удалить карточку
  Future<void> deleteCard({
    required String boardId,
    required String cardId,
  }) async {
    try {
      final endpoint = ApiEndpoints.boardCardDetail
          .replaceAll('{boardId}', boardId)
          .replaceAll('{cardId}', cardId);

      await _apiService.delete(
        endpoint,
        needsAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
