/// Все возможные ошибки при работе с API
abstract class ApiException implements Exception {
  final String message;
  final String? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

/// 400 - Bad Request
class BadRequestException extends ApiException {
  BadRequestException({required String message})
      : super(
          message: message,
          statusCode: '400',
        );
}

/// 401 - Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException({required String message})
      : super(
          message: message,
          statusCode: '401',
        );
}

/// 403 - Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException({required String message})
      : super(
          message: message,
          statusCode: '403',
        );
}

/// 404 - Not Found
class NotFoundException extends ApiException {
  NotFoundException({required String message})
      : super(
          message: message,
          statusCode: '404',
        );
}

/// 500 - Internal Server Error
class ServerException extends ApiException {
  ServerException({required String message})
      : super(
          message: message,
          statusCode: '500',
        );
}

/// Network error - нет интернета
class NetworkException extends ApiException {
  NetworkException({required String message})
      : super(
          message: message,
          statusCode: 'NETWORK_ERROR',
        );
}

/// Timeout error
class TimeoutException extends ApiException {
  TimeoutException({required String message})
      : super(
          message: message,
          statusCode: 'TIMEOUT',
        );
}

/// Invalid JSON response
class InvalidResponseException extends ApiException {
  InvalidResponseException({required String message})
      : super(
          message: message,
          statusCode: 'INVALID_RESPONSE',
        );
}

/// Empty response
class EmptyResponseException extends ApiException {
  EmptyResponseException({required String message})
      : super(
          message: message,
          statusCode: 'EMPTY_RESPONSE',
        );
}

/// Unknown error
class UnknownException extends ApiException {
  UnknownException({required String message})
      : super(
          message: message,
          statusCode: 'UNKNOWN',
        );
}
