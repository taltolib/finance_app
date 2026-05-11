/// Сервис для работы с аутентификацией
import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import '../models/auth_models.dart';

class AuthApiService {
  final ApiService _apiService = ApiService();

  /// Backend ждёт body: { "phone": "+998..." }
  Future<SendCodeResponse> sendCode({
    required String phoneNumber,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.authSendCode,
      body: {
        'phone': phoneNumber,
      },
    );

    return SendCodeResponse.fromJson(response);
  }

  /// Backend ждёт body:
  /// {
  ///   "phone": "+998...",
  ///   "phone_code_hash": "...",
  ///   "code": "12345",
  ///   "password": null
  /// }
  Future<VerifyCodeResponse> verifyCode({
    required String phoneNumber,
    required String phoneCodeHash,
    required String code,
    String? password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.authVerifyCode,
      body: {
        'phone': phoneNumber,
        'phone_code_hash': phoneCodeHash,
        'code': code,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );

    final verifyResponse = VerifyCodeResponse.fromJson(response);

    if (verifyResponse.sessionToken != null) {
      _apiService.setSessionToken(verifyResponse.sessionToken!);
    }

    return verifyResponse;
  }

  Future<void> logout() async {
    await _apiService.post(
      ApiEndpoints.authLogout,
      body: {},
      needsAuth: true,
    );

    _apiService.clearSessionToken();
  }
}
