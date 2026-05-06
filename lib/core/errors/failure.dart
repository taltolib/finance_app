import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ParsingFailure extends Failure {
  const ParsingFailure(String message) : super(message);
}

class EmptyContentFailure extends Failure {
  const EmptyContentFailure() : super('Пусто. Поделитесь текстом из Telegram');
}

class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure()
      : super('Неподдерживаемый формат. Используйте @HUMOcardbot');
}

class SaveFailure extends Failure {
  const SaveFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Неизвестная ошибка');
}
