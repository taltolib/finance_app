abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Неизвестная ошибка']) : super(message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(String message) : super(message);
}

class SaveFailure extends Failure {
  const SaveFailure(String message) : super(message);
}

class EmptyContentFailure extends Failure {
  const EmptyContentFailure([String message = 'Пустое содержимое']) : super(message);
}

class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure([String message = 'Неподдерживаемый формат']) : super(message);
}
