import 'package:finance_app/core/api/api_endpoints.dart';
import 'package:finance_app/core/api/api_service.dart';
import '../models/analytics_summary_model.dart';
import '../models/chart_point_model.dart';

class AnalyticsResponseModel {
  final AnalyticsSummaryModel summary;
  final List<ChartPointModel> chart;

  const AnalyticsResponseModel({
    required this.summary,
    required this.chart,
  });

  factory AnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    final chart = json['chart'] as List? ?? const [];
    return AnalyticsResponseModel(
      summary: AnalyticsSummaryModel.fromJson(json),
      chart: chart
          .whereType<Map<String, dynamic>>()
          .map(ChartPointModel.fromJson)
          .toList(),
    );
  }
}

class AnalyticsApiService {
  final ApiService _apiService = ApiService();

  Future<AnalyticsResponseModel> getAnalytics({
    required String period,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.analytics,
      queryParams: {'period': period},
      needsAuth: true,
    );
    return AnalyticsResponseModel.fromJson(response);
  }

  Future<AnalyticsSummaryModel> getSummary({
    required String period,
    int? month,
    int? year,
  }) async {
    final result = await getAnalytics(period: period);
    return result.summary;
  }

  Future<List<ChartPointModel>> getChartData({
    required String period,
    int? month,
    int? year,
  }) async {
    final result = await getAnalytics(period: period);
    return result.chart;
  }
}
