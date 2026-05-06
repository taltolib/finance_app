import 'dart:async';
import 'package:flutter/services.dart';
import '../../../../shared/errors/failure.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../models/transaction.dart' as model;

class ShareIntentService {
  static const _channel = MethodChannel('com.example_finance_app.finance_app/share_intent');
  static final StreamController<String> _shareStream = StreamController<String>.broadcast();

  static Future<void> initialize() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onShareIntentReceived') {
        final text = call.arguments as String?;
        if (text != null && text.isNotEmpty) {
          _shareStream.add(text);
        }
      }
    });
  }

  Future<String?> getInitialSharedText() async {
    try {
      final text = await _channel.invokeMethod<String>('getInitialText');
      // Не выбрасываем ошибку здесь, просто возвращаем null или пустую строку, 
      // чтобы BLoC мог обработать это как отсутствие данных при запуске.
      return text;
    } on PlatformException {
      return null;
    } catch (_) {
      rethrow;
    }
  }

  /// Слушать входящие shared данные (когда приложение открыто)
  Stream<String> listenToSharedText() {
    return _shareStream.stream;
  }

  /// Распарсить текст в транзакцию
  Future<entity.Transaction> parseSharedContent(String content) async {
    if (content.isEmpty) {
      throw const EmptyContentFailure();
    }

    // Используем парсер из слоя данных
    final parsed = model.Transaction.parse(content);
    if (parsed == null) {
      throw const UnsupportedFormatFailure();
    }

    // Мапим модель данных в доменную сущность
    return entity.Transaction(
      id: parsed.id,
      type: entity.TransactionType.values.firstWhere(
        (e) => e.name == parsed.type.name,
        orElse: () => entity.TransactionType.unknown,
      ),
      amount: parsed.amount,
      place: parsed.place,
      cardNumber: parsed.cardNumber,
      dateTime: parsed.dateTime,
      balance: parsed.balance,
      rawText: parsed.rawText,
    );
  }

  /// Закрыть stream при завершении
  void dispose() {
    _shareStream.close();
  }
}
