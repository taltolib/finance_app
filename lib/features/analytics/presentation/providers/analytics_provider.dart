/// Analytics Provider
/// Управление состоянием аналитики

import 'package:flutter/material.dart';
import '../../data/models/analytics_summary_model.dart';
import '../../data/models/chart_point_model.dart';
import '../../data/services/analytics_api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsApiService _apiService = AnalyticsApiService();

  // State
  String _selectedPeriod = 'month'; // 'year', '3months', 'month', 'week', 'day'
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingChart = false;
  AnalyticsSummaryModel? _summary;
  List<ChartPointModel> _chartData = [];
  String? _error;

  // Getters
  String get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isLoadingChart => _isLoadingChart;
  AnalyticsSummaryModel? get summary => _summary;
  List<ChartPointModel> get chartData => _chartData;
  String? get error => _error;

  // Периоды для UI
  List<String> get periods => ['год', '3 месяца', 'месяц', 'неделя', 'день'];
  List<String> get periodValues => ['year', '3months', 'month', 'week', 'day'];

  /// Загрузить аналитику для выбранного периода
  Future<void> loadAnalytics({
    String? period,
    DateTime? date,
  }) async {
    if (period != null) {
      _selectedPeriod = period;
    }
    if (date != null) {
      _selectedDate = date;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Загрузить summary и chart data параллельно
      final month = _selectedDate.month;
      final year = _selectedDate.year;

      final results = await Future.wait([
        _apiService.getSummary(
          period: _selectedPeriod,
          month: month,
          year: year,
        ),
        _apiService.getChartData(
          period: _selectedPeriod,
          month: month,
          year: year,
        ),
      ]);

      _summary = results[0] as AnalyticsSummaryModel;
      _chartData = results[1] as List<ChartPointModel>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки аналитики: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Изменить период
  Future<void> changePeriod(String period) async {
    _selectedPeriod = period;
    await loadAnalytics();
  }

  /// Изменить месяц/год
  Future<void> changeDate(DateTime date) async {
    _selectedDate = date;
    await loadAnalytics();
  }

  /// Переместиться на предыдущий период
  Future<void> previousPeriod() async {
    switch (_selectedPeriod) {
      case 'year':
        _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
        break;
      case 'month':
      case '3months':
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
        break;
      case 'week':
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case 'day':
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
    }
    await loadAnalytics();
  }

  /// Переместиться на следующий период
  Future<void> nextPeriod() async {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'year':
        final next = DateTime(_selectedDate.year + 1, _selectedDate.month);
        if (next.isBefore(now) || next.year == now.year) {
          _selectedDate = next;
        }
        break;
      case 'month':
      case '3months':
        final next = DateTime(_selectedDate.year, _selectedDate.month + 1);
        if (next.isBefore(now) || (next.year == now.year && next.month <= now.month)) {
          _selectedDate = next;
        }
        break;
      case 'week':
        final next = _selectedDate.add(const Duration(days: 7));
        if (next.isBefore(now)) {
          _selectedDate = next;
        }
        break;
      case 'day':
        final next = _selectedDate.add(const Duration(days: 1));
        if (next.isBefore(now) || next.day == now.day) {
          _selectedDate = next;
        }
        break;
    }
    await loadAnalytics();
  }

  /// Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Сбросить состояние
  void reset() {
    _selectedPeriod = 'month';
    _selectedDate = DateTime.now();
    _isLoading = false;
    _isLoadingChart = false;
    _summary = null;
    _chartData = [];
    _error = null;
    notifyListeners();
  }
}
