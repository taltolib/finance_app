/// Humo Connection Provider
/// Управление состоянием подключения HUMO bot

import 'package:flutter/material.dart';
import '../data/models/humo_status_model.dart';
import '../data/services/humo_api_service.dart';

class HumoConnectionProvider extends ChangeNotifier {
  final HumoApiService _apiService = HumoApiService();

  // State
  bool _isLoading = false;
  bool _isChecking = false;
  HumoCheckResponse? _checkResponse;
  String? _error;
  bool _isConnected = false;
  DateTime? _lastCheckTime;

  // Getters
  bool get isLoading => _isLoading;
  bool get isChecking => _isChecking;
  HumoCheckResponse? get checkResponse => _checkResponse;
  String? get error => _error;
  bool get isConnected => _isConnected;
  DateTime? get lastCheckTime => _lastCheckTime;

  // Информация о статусе
  String? get statusText => _checkResponse?.humo?.getStatusText();
  String? get statusReason => _checkResponse?.humo?.reason;
  bool get isBotFound => _checkResponse?.hasBot ?? false;
  bool get hasMessages => _checkResponse?.hasMessages ?? false;
  bool get isCardConnected => _checkResponse?.humo?.isCardConnected ?? false;
  bool get canReadTransactions => _checkResponse?.humo?.canReadTransactions ?? false;

  /// Проверить статус подключения HUMO
  Future<bool> checkBotStatus() async {
    try {
      _isChecking = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.checkBotStatus();
      _checkResponse = response;
      _lastCheckTime = DateTime.now();

      // Проверить, успешно ли подключен HUMO
      _isConnected = response.isHumoConnected;

      _isChecking = false;
      notifyListeners();

      return _isConnected;
    } catch (e) {
      _error = 'Ошибка при проверке HUMO: $e';
      _isConnected = false;
      _isChecking = false;
      notifyListeners();
      return false;
    }
  }

  /// Получить сообщение об ошибке для пользователя
  String getErrorMessage() {
    if (!isBotFound) {
      return 'Бот @HUMOcardbot не найден в вашем Telegram';
    }

    if (!hasMessages) {
      return 'Нет сообщений от @HUMOcardbot. Откройте бот и отправьте /start';
    }

    if (!isCardConnected) {
      return 'Карта HUMO не подключена. Откройте @HUMOcardbot и подключите карту';
    }

    if (!canReadTransactions) {
      return 'Нет доступа к чтению транзакций. Проверьте настройки в @HUMOcardbot';
    }

    return statusReason ?? 'Неизвестная ошибка подключения';
  }

  /// Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Сбросить состояние
  void reset() {
    _isLoading = false;
    _isChecking = false;
    _checkResponse = null;
    _error = null;
    _isConnected = false;
    _lastCheckTime = null;
    notifyListeners();
  }
}
