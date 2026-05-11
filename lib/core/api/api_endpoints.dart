/// Все доступные endpoints backend-а
class ApiEndpoints {
  // Auth endpoints
  static const String authSendCode = '/auth/send-code';
  static const String authVerifyCode = '/auth/verify-code';
  static const String authRefreshToken = '/auth/refresh-token';
  static const String authLogout = '/auth/logout';

  // HUMO Bot endpoints
  static const String checkBot = '/check-bot';

  // Transactions endpoints
  static const String transactions = '/transactions';
  static const String transactionsLatest = '/transactions/latest';
  static const String transactionDetail = '/transactions/{id}';
  static const String transactionCategoryColumn = '/transactions/{id}/category-column';

  // Analytics endpoints
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsChart = '/analytics/chart';

  // Boards endpoints
  static const String boards = '/boards';
  static const String boardsCurrent = '/boards/current';
  static const String boardsArchived = '/boards/archived';
  static const String boardDetail = '/boards/{id}';
  static const String boardsArchiveExpired = '/boards/archive-expired';
  static const String boardsMonthStatus = '/boards/month-status';

  // Board Columns endpoints
  static const String boardColumns = '/boards/{boardId}/columns';
  static const String boardColumnDetail = '/boards/{boardId}/columns/{columnId}';

  // Board Cards endpoints
  static const String boardCards = '/boards/{boardId}/columns/{columnId}/cards';
  static const String boardCardMove = '/boards/{boardId}/cards/{cardId}/move';
  static const String boardCardDetail = '/boards/{boardId}/cards/{cardId}';
}
