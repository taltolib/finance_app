/// Auth Provider
/// Управление состоянием авторизации

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/api/api_service.dart';
import '../../data/models/auth_models.dart';
import '../../data/services/auth_api_service.dart';

enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _phoneNumber;
  String? _phoneCodeHash;
  String? _sessionToken;
  UserInfo? _user;

  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _error;
  bool _isAuthenticated = false;

  String? get phoneNumber => _phoneNumber;
  String? get phoneCodeHash => _phoneCodeHash;
  String? get sessionToken => _sessionToken;
  UserInfo? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isSendingCode => _isSendingCode;
  bool get isVerifyingCode => _isVerifyingCode;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final token = await _secureStorage.read(key: 'session_token');

      if (token != null && token.isNotEmpty) {
        _sessionToken = token;
        _isAuthenticated = true;
        ApiService().setSessionToken(token);
      }

      _isLoading = false;
      _status = AuthStatus.success;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при загрузке сессии: $e';
      _isLoading = false;
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<bool> sendCode(String phoneNumber) async {
    try {
      _isSendingCode = true;
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.sendCode(phoneNumber: phoneNumber);

      if (response.success && response.phoneCodeHash != null) {
        _phoneNumber = phoneNumber;
        _phoneCodeHash = response.phoneCodeHash;
        _isSendingCode = false;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      }

      _error = response.message ?? 'Backend не вернул phone_code_hash';
      _isSendingCode = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ошибка при отправке кода: $e';
      _isSendingCode = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      _error = 'Номер телефона не установлен';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    if (_phoneCodeHash == null || _phoneCodeHash!.isEmpty) {
      _error = 'phone_code_hash не установлен. Сначала отправьте код заново';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    try {
      _isVerifyingCode = true;
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.verifyCode(
        phoneNumber: _phoneNumber!,
        phoneCodeHash: _phoneCodeHash!,
        code: code,
      );

      if (response.success && response.sessionToken != null) {
        _sessionToken = response.sessionToken;
        _user = response.user;
        _isAuthenticated = true;

        await _secureStorage.write(
          key: 'session_token',
          value: response.sessionToken!,
        );

        ApiService().setSessionToken(response.sessionToken!);

        _isVerifyingCode = false;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      }

      _error = response.message ?? 'Ошибка проверки кода';
      _isVerifyingCode = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ошибка при проверке кода: $e';
      _isVerifyingCode = false;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _status = AuthStatus.loading;
      notifyListeners();

      await _apiService.logout();

      _phoneNumber = null;
      _phoneCodeHash = null;
      _sessionToken = null;
      _user = null;
      _isAuthenticated = false;
      _error = null;

      await _secureStorage.delete(key: 'session_token');
      ApiService().clearSessionToken();

      _isLoading = false;
      _status = AuthStatus.initial;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при выходе: $e';
      _isLoading = false;
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }
}
