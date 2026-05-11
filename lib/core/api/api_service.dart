import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_exceptions.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,

    ),
  );

  String? _sessionToken;

  /// Установить session token
  void setSessionToken(String token) {
    _sessionToken = token;
  }

  /// Очистить session token
  void clearSessionToken() {
    _sessionToken = null;
  }

  /// Получить session token
  String? getSessionToken() {
    return _sessionToken;
  }

  /// Проверить, есть ли session token
  bool hasSessionToken() {
    return _sessionToken != null;
  }

  /// Получить headers с авторизацией
  Map<String, String> _getHeaders({
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    if (needsAuth && _sessionToken != null) {
      headers['x-session-token'] = _sessionToken!;
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// GET запрос
  Future<Map<String, dynamic>> get(String endpoint, {
    Map<String, String>? queryParams,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response =  await dio.get(endpoint,
          queryParameters: queryParams,
          options: Options(
            headers:
            _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders),
          ));

      return _handleResponse(response);
    } on TimeoutException {
      throw TimeoutException(message: 'Запрос истёк. Проверьте соединение.');
    } on SocketException {
      throw NetworkException(message: 'Нет соединения с интернетом');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: 'Ошибка при получении данных: $e');
    }
  }

  /// POST запрос
  Future<Map<String, dynamic>> post(String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response = await dio.post(endpoint, options: Options(
        headers: _getHeaders(
            needsAuth: needsAuth, customHeaders: customHeaders),),
        data: jsonEncode(body),);

      return _handleResponse(response);
    } on TimeoutException {
      throw TimeoutException(message: 'Запрос истёк. Проверьте соединение.');
    } on SocketException {
      throw NetworkException(message: 'Нет соединения с интернетом');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: 'Ошибка при отправке данных: $e');
    }
  }

  /// PATCH запрос
  Future<Map<String, dynamic>> patch(String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response = await dio.patch(endpoint, options: Options(
        headers: _getHeaders(
            needsAuth: needsAuth, customHeaders: customHeaders),),
        data: jsonEncode(body),

      );
      return _handleResponse(response);
    } on TimeoutException {
      throw TimeoutException(message: 'Запрос истёк. Проверьте соединение.');
    } on SocketException {
      throw NetworkException(message: 'Нет соединения с интернетом');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: 'Ошибка при обновлении данных: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {
    bool needsAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response = await dio
          .delete(
       endpoint, options:Options(headers:  _getHeaders(needsAuth: needsAuth, customHeaders: customHeaders)),
      );

      return _handleResponse(response);
    } on TimeoutException {
      throw TimeoutException(message: 'Запрос истёк. Проверьте соединение.');
    } on SocketException {
      throw NetworkException(message: 'Нет соединения с интернетом');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: 'Ошибка при удалении данных: $e');
    }
  }

  /// Обработать ответ от сервера
  Map<String, dynamic> _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode == 401) {
      clearSessionToken();
      throw UnauthorizedException(
        message: 'Ваша сессия истекла. Пожалуйста, авторизуйтесь заново.',
      );
    }

    if (statusCode == 403) {
      throw ForbiddenException(message: 'Доступ запрещён');
    }

    if (statusCode == 404) {
      throw NotFoundException(message: 'Ресурс не найден');
    }

    if (statusCode == 400) {
      throw BadRequestException(message: 'Некорректный запрос');
    }

    if (statusCode >= 500) {
      throw ServerException(message: 'Ошибка сервера. Попробуйте позже.');
    }

    if (statusCode != 200 && statusCode != 201) {
      throw UnknownException(message: 'Ошибка запроса: $statusCode');
    }

    final data = response.data;

    if (data == null) {
      throw EmptyResponseException(message: 'Сервер вернул пустой ответ');
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      if (data.isEmpty) {
        throw EmptyResponseException(message: 'Сервер вернул пустой ответ');
      }

      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        throw InvalidResponseException(
          message: 'Некорректный формат ответа от сервера',
        );
      }
    }

    throw InvalidResponseException(
      message: 'Некорректный формат ответа от сервера',
    );
  }



}
