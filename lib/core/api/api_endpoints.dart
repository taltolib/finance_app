/// Endpoints текущего FastAPI backend-а.
/// Важно: старые `/boards/*` и `/transactions/latest` убраны, потому что backend
/// из API_DOCS работает через `/kanban/*`, `/transactions`, `/dashboard`, `/analytics`.
class ApiEndpoints {
  // Auth
  static const String authSendCode = '/auth/send-code';
  static const String authVerifyCode = '/auth/verify-code';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // HUMO
  static const String checkBot = '/check-bot';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionsSync = '/transactions/sync';

  // Dashboard / Analytics
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsChart = '/analytics/chart';

  // Kanban
  static const String kanbanCurrent = '/kanban/current';
  static const String kanbanArchived = '/kanban/archived';
  static const String kanbanColumns = '/kanban/columns';
  static const String kanbanColumnDetail = '/kanban/columns/{column_id}';
  static const String kanbanMoveCard = '/kanban/cards/move';
  static const String kanbanCategories = '/kanban/categories';
}
