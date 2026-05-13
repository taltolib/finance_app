import 'package:finance_app/core/api/api_endpoints.dart';
import 'package:finance_app/core/api/api_service.dart';
import '../models/dashboard_summary_model.dart';

class DashboardApiService {
  final ApiService _apiService = ApiService();

  Future<DashboardSummaryModel> getDashboardSummary({
    required int month,
    required int year,
  }) async {
    final monthParam = '$year-${month.toString().padLeft(2, '0')}';
    final response = await _apiService.get(
      ApiEndpoints.dashboard,
      queryParams: {'month': monthParam},
      needsAuth: true,
    );

    return DashboardSummaryModel.fromJson(response);
  }
}
