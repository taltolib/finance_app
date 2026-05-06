import '../../core/errors/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/share_intent_repository.dart';
import '../datasources/share_intent_service.dart';
import '../../services/database_helper.dart';
import '../../models/transaction.dart' as tx_model;

class ShareIntentRepositoryImpl implements ShareIntentRepository {
  final ShareIntentService shareIntentService;
  final DatabaseHelper databaseHelper;

  ShareIntentRepositoryImpl({
    required this.shareIntentService,
    required this.databaseHelper,
  });

  @override
  Future<String?> getInitialSharedText() async {
    try {
      return await shareIntentService.getInitialSharedText();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure();
    }
  }

  @override
  Stream<String> listenToSharedText() {
    return shareIntentService.listenToSharedText();
  }

  @override
  Future<Transaction> parseSharedContent(String content) async {
    try {
      return await shareIntentService.parseSharedContent(content);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParsingFailure('Ошибка парсинга: $e');
    }
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    try {
      // Конвертируем доменную Transaction в модель для БД
      final oldModel = tx_model.Transaction(
        id: transaction.id,
        type: transaction.type == TransactionType.income
            ? tx_model.TransactionType.income
            : tx_model.TransactionType.expense,
        amount: transaction.amount,
        location: transaction.location,
        cardNumber: transaction.cardNumber,
        dateTime: transaction.dateTime,
        balanceAfter: transaction.balanceAfter,
        rawText: transaction.rawText,
      );
      await databaseHelper.insertTransaction(oldModel);
    } catch (e) {
      throw SaveFailure('Не удалось сохранить транзакцию: $e');
    }
  }
}
