abstract class Failure {
  final String message;

  const Failure(this.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Неизвестная ошибка']) : super(message);
}

class ParsingFailure extends Failure {
  const ParsingFailure([String message = 'Ошибка парсинга']) : super(message);
}

class SaveFailure extends Failure {
  const SaveFailure([String message = 'Ошибка сохранения']) : super(message);
}

class EmptyContentFailure extends Failure {
  const EmptyContentFailure([String message = 'Пустое содержимое']) : super(message);
}

class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure([String message = 'Неподдерживаемый формат']) : super(message);
}