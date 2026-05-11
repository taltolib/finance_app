/// Сервис для работы с аутентификацией
import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import '../models/auth_models.dart';

class AuthApiService {
  final ApiService _apiService = ApiService();

  /// Отправить код авторизации на номер Telegram
  Future<SendCodeResponse> sendCode({
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.authSendCode,
        body: {
          'phone_number': phoneNumber,
        },
      );

      return SendCodeResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Проверить код и получить session token
  Future<VerifyCodeResponse> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.authVerifyCode,
        body: {
          'phone_number': phoneNumber,
          'code': code,
        },
      );

      final verifyResponse = VerifyCodeResponse.fromJson(response);

      // Сохранить session token
      if (verifyResponse.sessionToken != null) {
        _apiService.setSessionToken(verifyResponse.sessionToken!);
      }

      return verifyResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Выйти из аккаунта
  Future<void> logout() async {
    try {
      await _apiService.post(
        ApiEndpoints.authLogout,
        body: {},
        needsAuth: true,
      );

      // Очистить session token
      _apiService.clearSessionToken();
    } catch (e) {
      rethrow;
    }
  }
}
