import 'package:finance_app/core/api/api_endpoints.dart';
import 'package:finance_app/core/api/api_service.dart';

class BoardsApiService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getCurrentBoard({String? month}) async {
    final response = await _apiService.get(
      ApiEndpoints.kanbanCurrent,
      queryParams: month == null ? null : {'month': month},
      needsAuth: true,
    );
    return (response['board'] as Map<String, dynamic>?) ?? response;
  }

  Future<List<Map<String, dynamic>>> getArchivedBoards() async {
    final response = await _apiService.get(
      ApiEndpoints.kanbanArchived,
      needsAuth: true,
    );
    final boards = response['boards'] as List? ?? const [];
    return boards.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> createColumn({
    required String boardId,
    required String title,
    int? color,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.kanbanColumns,
      body: {
        'board_id': boardId,
        'title': title,
      },
      needsAuth: true,
    );
    return (response['column'] as Map<String, dynamic>?) ?? response;
  }

  Future<Map<String, dynamic>> updateColumn({
    required String boardId,
    required String columnId,
    String? title,
    int? color,
  }) async {
    final endpoint = ApiEndpoints.kanbanColumnDetail.replaceAll('{column_id}', columnId);
    final response = await _apiService.patch(
      endpoint,
      body: {
        if (title != null) 'title': title,
      },
      needsAuth: true,
    );
    return (response['column'] as Map<String, dynamic>?) ?? response;
  }

  Future<void> deleteColumn({
    required String boardId,
    required String columnId,
  }) async {
    final endpoint = ApiEndpoints.kanbanColumnDetail.replaceAll('{column_id}', columnId);
    await _apiService.delete(endpoint, needsAuth: true);
  }

  Future<Map<String, dynamic>> moveCard({
    required String boardId,
    required String transactionId,
    required String fromColumnId,
    required String toColumnId,
    int newIndex = 0,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.kanbanMoveCard,
      body: {
        'board_id': boardId,
        'transaction_id': transactionId,
        'from_column_id': fromColumnId,
        'to_column_id': toColumnId,
        'new_index': newIndex,
      },
      needsAuth: true,
    );
    return (response['card'] as Map<String, dynamic>?) ?? response;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiService.get(ApiEndpoints.kanbanCategories);
    final categories = response['categories'] as List? ?? const [];
    return categories.whereType<Map<String, dynamic>>().toList();
  }
}
