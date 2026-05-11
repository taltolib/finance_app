/// HUMO API Service
/// Сервис для работы с проверкой подключения HUMO bot

import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import '../models/humo_status_model.dart';

class HumoApiService {
  final ApiService _apiService = ApiService();

  /// Проверить статус подключения HUMO bot
  Future<HumoCheckResponse> checkBotStatus() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.checkBot,
        needsAuth: true,
      );

      return HumoCheckResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
