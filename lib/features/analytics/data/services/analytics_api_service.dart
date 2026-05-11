/// Сервис для работы с аналитикой
import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import '../models/analytics_summary_model.dart';
import '../models/chart_point_model.dart';

class AnalyticsApiService {
  final ApiService _apiService = ApiService();

  /// Получить summary аналитики
  Future<AnalyticsSummaryModel> getSummary({
    required String period, // 'year', '3months', 'month', 'week', 'day'
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{
        'period': period,
      };
      if (month != null) queryParams['month'] = month.toString();
      if (year != null) queryParams['year'] = year.toString();

      final response = await _apiService.get(
        ApiEndpoints.analyticsSummary,
        queryParams: queryParams,
        needsAuth: true,
      );

      return AnalyticsSummaryModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Получить данные для графика
  Future<List<ChartPointModel>> getChartData({
    required String period, // 'year', '3months', 'month', 'week', 'day'
    int? month,
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{
        'period': period,
      };
      if (month != null) queryParams['month'] = month.toString();
      if (year != null) queryParams['year'] = year.toString();

      final response = await _apiService.get(
        ApiEndpoints.analyticsChart,
        queryParams: queryParams,
        needsAuth: true,
      );

      final data = response['data'] as List? ?? [];
      return data
          .map((item) => ChartPointModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
