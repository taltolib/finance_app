import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exceptions.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    dio.options.headers.addAll(ApiConfig.defaultHeaders);
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      responseType: ResponseType.json,
    ),
  );

  String? _sessionToken;

  void setSessionToken(String token) => _sessionToken = token;
  void clearSessionToken() => _sessionToken = null;
  String? getSessionToken() => _sessionToken;
  bool hasSessionToken() => _sessionToken != null && _sessionToken!.isNotEmpty;

  Map<String, String> _getHeaders({
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    if (needsAuth && hasSessionToken()) {
      headers['x-session-token'] = _sessionToken!;
    }

    if (customHeaders != null) headers.addAll(customHeaders);
    return headers;
  }

  String _normalizeEndpoint(String endpoint) => endpoint;

  String buildPath(String template, Map<String, String> params) {
    var path = template;
    params.forEach((key, value) {
      path = path.replaceAll('{$key}', value);
    });
    return path;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    return _request(
      () => dio.get(
        _normalizeEndpoint(endpoint),
        queryParameters: queryParams,
        options: Options(headers: _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders)),
      ),
      fallbackMessage: 'Ошибка при получении данных',
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    return _request(
      () => dio.post(
        _normalizeEndpoint(endpoint),
        queryParameters: queryParams,
        options: Options(headers: _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders)),
        data: body.isEmpty ? null : jsonEncode(body),
      ),
      fallbackMessage: 'Ошибка при отправке данных',
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic> body = const {},
    Map<String, dynamic>? queryParams,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    return _request(
      () => dio.patch(
        _normalizeEndpoint(endpoint),
        queryParameters: queryParams,
        options: Options(headers: _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders)),
        data: body.isEmpty ? null : jsonEncode(body),
      ),
      fallbackMessage: 'Ошибка при обновлении данных',
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    return _request(
      () => dio.delete(
        _normalizeEndpoint(endpoint),
        queryParameters: queryParams,
        options: Options(headers: _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders)),
      ),
      fallbackMessage: 'Ошибка при удалении данных',
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      final response = await action();
      return _handleResponse(response);
    } on TimeoutException {
      throw TimeoutException(message: 'Запрос истёк. Проверьте соединение.');
    } on SocketException {
      throw NetworkException(message: 'Нет соединения с интернетом');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      final statusCode = e.response?.statusCode ?? 0;

      if (statusCode == 401) {
        clearSessionToken();
        throw UnauthorizedException(message: message);
      }
      if (statusCode == 400) throw BadRequestException(message: message);
      if (statusCode == 403) throw ForbiddenException(message: message);
      if (statusCode == 404) throw NotFoundException(message: message);
      if (statusCode >= 500) throw ServerException(message: message);

      throw NetworkException(message: message);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: '$fallbackMessage: $e');
    }
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      final message = data['message'];
      if (detail != null) return detail.toString();
      if (message != null) return message.toString();
    }

    if (data is String && data.trim().isNotEmpty) return data;
    if ((error.message ?? '').isNotEmpty) return error.message!;

    return 'Сервер вернул ошибку ${error.response?.statusCode ?? 'unknown'}';
  }

  Map<String, dynamic> _handleResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode == 401) {
      clearSessionToken();
      throw UnauthorizedException(message: 'Ваша сессия истекла. Авторизуйтесь заново.');
    }
    if (statusCode == 400) throw BadRequestException(message: _messageFromData(data, 'Некорректный запрос'));
    if (statusCode == 403) throw ForbiddenException(message: _messageFromData(data, 'Доступ запрещён'));
    if (statusCode == 404) throw NotFoundException(message: _messageFromData(data, 'Ресурс не найден'));
    if (statusCode >= 500) throw ServerException(message: _messageFromData(data, 'Ошибка сервера'));
    if (statusCode < 200 || statusCode >= 300) throw UnknownException(message: 'Ошибка запроса: $statusCode');

    if (data == null) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }

    throw InvalidResponseException(message: 'Некорректный формат ответа от сервера');
  }

  String _messageFromData(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ?? data['message'] ?? fallback).toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }
}
