import '../../../../shared/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/share_intent_repository.dart';

class GetInitialSharedTextUseCase extends UseCase<String?, NoParams> {
  final ShareIntentRepository repository;

  GetInitialSharedTextUseCase(this.repository);

  @override
  Future<String?> call(NoParams params) async {
    return await repository.getInitialSharedText();
  }
}

class ListenShareIntentUseCase extends UseCase<Stream<String>, NoParams> {
  final ShareIntentRepository repository;

  ListenShareIntentUseCase(this.repository);

  @override
  Future<Stream<String>> call(NoParams params) async {
    return repository.listenToSharedText();
  }
}

class ParseSharedContentUseCase extends UseCase<Transaction, String> {
  final ShareIntentRepository repository;

  ParseSharedContentUseCase(this.repository);

  @override
  Future<Transaction> call(String content) async {
    return await repository.parseSharedContent(content);
  }
}

class SaveTransactionUseCase extends UseCase<void, Transaction> {
  final ShareIntentRepository repository;

  SaveTransactionUseCase(this.repository);

  @override
  Future<void> call(Transaction params) async {
    return await repository.saveTransaction(params);
  }
}
