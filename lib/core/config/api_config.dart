// API Configuration
// NOT TO CHANGE: базовые конфиги для API

class ApiConfig {
  // Base URL для API
  // TODO: Заменить на реальный URL backend-а
  static const String baseUrl = 'https://financebackend-78.up.railway.app';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
