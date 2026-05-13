import 'package:finance_app/core/api/api_endpoints.dart';
import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';

class TransactionsSyncResult {
  final bool success;
  final int synced;
  final int createdNew;
  final int updated;
  final bool hasMore;
  final int? nextOffsetId;

  const TransactionsSyncResult({
    required this.success,
    required this.synced,
    required this.createdNew,
    required this.updated,
    required this.hasMore,
    this.nextOffsetId,
  });

  factory TransactionsSyncResult.fromJson(Map<String, dynamic> json) {
    return TransactionsSyncResult(
      success: json['success'] == true,
      synced: (json['synced'] as num?)?.toInt() ?? 0,
      createdNew: (json['new'] as num?)?.toInt() ?? 0,
      updated: (json['updated'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] == true,
      nextOffsetId: (json['next_offset_id'] as num?)?.toInt(),
    );
  }
}

class TransactionsApiService {
  final ApiService _apiService = ApiService();

  Future<TransactionsSyncResult> syncTransactions({
    int limit = 500,
    int? offsetId,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.transactionsSync,
      queryParams: {
        'limit': limit,
        if (offsetId != null) 'offset_id': offsetId,
      },
      needsAuth: true,
    );
    return TransactionsSyncResult.fromJson(response);
  }

  Future<List<Transaction>> getTransactions({
    int limit = 50,
    int? offsetId,
    bool useDb = true,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.transactions,
      queryParams: {
        'limit': limit,
        'use_db': useDb,
        if (offsetId != null) 'offset_id': offsetId,
      },
      needsAuth: true,
    );

    final list = response['transactions'] as List? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Transaction.fromMap)
        .toList();
  }
}
