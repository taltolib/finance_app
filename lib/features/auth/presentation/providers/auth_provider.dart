/// Auth Provider
/// Управление состоянием авторизации

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/features/auth/data/models/auth_models.dart';
import 'package:finance_app/features/auth/data/services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // State
  String? _phoneNumber;
  String? _sessionToken;
  UserInfo? _user;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  String? get phoneNumber => _phoneNumber;
  String? get sessionToken => _sessionToken;
  UserInfo? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSendingCode => _isSendingCode;
  bool get isVerifyingCode => _isVerifyingCode;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Инициализировать провайдер - загрузить сохранённый session token
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _secureStorage.read(key: 'session_token');
      if (token != null) {
        _sessionToken = token;
        _isAuthenticated = true;
        ApiService().setSessionToken(token);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при загрузке сессии: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Отправить код на номер телефона
  Future<bool> sendCode(String phoneNumber) async {
    try {
      _isSendingCode = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.sendCode(phoneNumber: phoneNumber);

      if (response.success) {
        _phoneNumber = phoneNumber;
        _isSendingCode = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Ошибка отправки кода';
        _isSendingCode = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка при отправке кода: $e';
      _isSendingCode = false;
      notifyListeners();
      return false;
    }
  }

  /// Проверить код и авторизоваться
  Future<bool> verifyCode(String code) async {
    if (_phoneNumber == null) {
      _error = 'Номер телефона не установлен';
      notifyListeners();
      return false;
    }

    try {
      _isVerifyingCode = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.verifyCode(
        phoneNumber: _phoneNumber!,
        code: code,
      );

      if (response.success && response.sessionToken != null) {
        _sessionToken = response.sessionToken;
        _user = response.user;
        _isAuthenticated = true;

        // Сохранить session token безопасно
        await _secureStorage.write(
          key: 'session_token',
          value: response.sessionToken!,
        );

        // Установить token в API service
        ApiService().setSessionToken(response.sessionToken!);

        _isVerifyingCode = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Ошибка проверки кода';
        _isVerifyingCode = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка при проверке кода: $e';
      _isVerifyingCode = false;
      notifyListeners();
      return false;
    }
  }

  /// Выйти из аккаунта
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.logout();

      // Очистить все данные
      _phoneNumber = null;
      _sessionToken = null;
      _user = null;
      _isAuthenticated = false;
      _error = null;

      // Удалить session token из secure storage
      await _secureStorage.delete(key: 'session_token');

      // Очистить token в API service
      ApiService().clearSessionToken();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при выходе: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
