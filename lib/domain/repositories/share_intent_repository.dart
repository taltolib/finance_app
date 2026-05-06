import '../entities/transaction.dart';

abstract class ShareIntentRepository {
  /// Получить начальный shared текст (при холодном запуске)
  Future<String?> getInitialSharedText();

  /// Слушать входящие shared данные (когда приложение открыто)
  Stream<String> listenToSharedText();

  /// Распарсить текст в транзакцию
  Future<Transaction> parseSharedContent(String content);

  /// Сохранить транзакцию в БД
  Future<void> saveTransaction(Transaction transaction);
}
