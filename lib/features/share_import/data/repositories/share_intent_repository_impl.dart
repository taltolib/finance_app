import 'package:finance_app/shared/database/database_helper.dart';
import '../../../../shared/errors/failure.dart';
import '../../../../features/transactions/data/models/transaction.dart' as tx;
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/repositories/share_intent_repository.dart';
import '../datasources/share_intent_service.dart';
import '../models/transaction.dart' as model;

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
      throw const UnknownFailure();
    }
  }

  @override
  Stream<String> listenToSharedText() {
    return shareIntentService.listenToSharedText();
  }

  @override
  Future<entity.Transaction> parseSharedContent(String content) async {
    try {
      return await shareIntentService.parseSharedContent(content);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ParsingFailure('Ошибка парсинга: $e');
    }
  }

  @override
  Future<void> saveTransaction(entity.Transaction transaction) async {
    try {
      // Конвертируем доменную сущность в модель данных для сохранения
      final dataModel = tx.Transaction(
        id: transaction.id,
        type: transaction.type == model.TransactionType.income ? tx.TransactionType.income : tx.TransactionType.expense,
        amount: transaction.amount,
        location: transaction.place,
        cardNumber: transaction.cardNumber,
        dateTime: transaction.dateTime,
        balanceAfter: transaction.balance,
        rawText: transaction.rawText,
      );
      await databaseHelper.insertTransaction(dataModel);
    } catch (e) {
      throw SaveFailure('Не удалось сохранить транзакцию: $e');
    }
  }
}
