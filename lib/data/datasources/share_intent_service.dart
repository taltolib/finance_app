import 'dart:async';
import 'package:flutter/services.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/transaction.dart';

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
      if (text == null || text.isEmpty) {
        throw const EmptyContentFailure();
      }
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
  Future<Transaction> parseSharedContent(String content) async {
    if (content.isEmpty) {
      throw const EmptyContentFailure();
    }

    final transaction = Transaction.parse(content);
    if (transaction == null) {
      throw const UnsupportedFormatFailure();
    }

    return transaction;
  }

  /// Закрыть stream при завершении
  void dispose() {
    _shareStream.close();
  }
}
