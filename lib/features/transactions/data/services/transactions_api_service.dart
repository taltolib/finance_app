/// Transactions API Service
/// Сервис для работы с транзакциями

import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';

class TransactionsApiService {
  final ApiService _apiService = ApiService();

  /// Получить все транзакции
  Future<List<Transaction>> getTransactions({
    int? month,
    int? year,
    String? type, // 'income' или 'expense'
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (month != null) queryParams['month'] = month.toString();
      if (year != null) queryParams['year'] = year.toString();
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await _apiService.get(
        ApiEndpoints.transactions,
        queryParams: queryParams.isEmpty ? null : queryParams,
        needsAuth: true,
      );

      final data = response['data'] as List? ?? [];
      return data
          .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Получить последние транзакции
  Future<List<Transaction>> getLatestTransactions({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.transactionsLatest,
        queryParams: {'limit': limit.toString()},
        needsAuth: true,
      );

      final data = response['data'] as List? ?? [];
      return data
          .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Получить одну транзакцию
  Future<Transaction> getTransaction(String id) async {
    try {
      final endpoint = ApiEndpoints.transactionDetail.replaceAll('{id}', id);
      final response = await _apiService.get(
        endpoint,
        needsAuth: true,
      );

      return Transaction.fromMap(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Привязать транзакцию к колонке доски
  Future<Transaction> assignToColumn({
    required String transactionId,
    required String columnId,
  }) async {
    try {
      final endpoint = ApiEndpoints.transactionCategoryColumn
          .replaceAll('{id}', transactionId);
      final response = await _apiService.patch(
        endpoint,
        body: {
          'column_id': columnId,
        },
        needsAuth: true,
      );

      return Transaction.fromMap(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
