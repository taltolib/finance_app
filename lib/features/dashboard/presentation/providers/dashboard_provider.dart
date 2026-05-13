import 'package:flutter/material.dart';
import '../../data/models/dashboard_summary_model.dart';
import '../../data/services/dashboard_api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardApiService _apiService = DashboardApiService();

  bool _isLoading = false;
  DashboardSummaryModel? _summary;
  String? _error;
  DateTime _selectedMonth = DateTime.now();

  bool get isLoading => _isLoading;
  DashboardSummaryModel? get summary => _summary;
  String? get error => _error;
  DateTime get selectedMonth => _selectedMonth;

  Future<void> loadCurrentMonth() async {
    await _loadMonth(_selectedMonth);
  }

  Future<void> _loadMonth(DateTime month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _apiService.getDashboardSummary(
        month: month.month,
        year: month.year,
      );
      _selectedMonth = month;
    } catch (e) {
      _error = 'Ошибка загрузки данных панели: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> previousMonth() async {
    final previous = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    await _loadMonth(previous);
  }

  Future<void> nextMonth() async {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    final now = DateTime.now();
    if (next.isAfter(now)) return;
    await _loadMonth(next);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _summary = null;
    _error = null;
    _selectedMonth = DateTime.now();
    notifyListeners();
  }
}
