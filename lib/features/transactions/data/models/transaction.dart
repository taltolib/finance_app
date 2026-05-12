import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;/// Количество
  final String location; /// Откуда
  final String cardNumber; /// карта номер *1119
  final DateTime dateTime; /// 2026-05-07
  final double balanceAfter;/// Балан после расходов(остаток)
  final String rawText; //// Оригинальное сообщение

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.location,
    required this.cardNumber,
    required this.dateTime,
    required this.balanceAfter,
    required this.rawText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'location': location,
      'cardNumber': cardNumber,
      'dateTime': dateTime.toIso8601String(),
      'balanceAfter': balanceAfter,
      'rawText': rawText,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: TransactionType.values[map['type']],
      amount: map['amount'],
      location: map['location'],
      cardNumber: map['cardNumber'],
      dateTime: DateTime.parse(map['dateTime']),
      balanceAfter: map['balanceAfter'],
      rawText: map['rawText'],
    );
  }

  static Transaction? parse(String rawText) {
    final lines = rawText.split('\n').map((line) => line.trim()).toList();

    if (lines.isEmpty) return null;

    TransactionType? type;
    double? amount;
    String? location;
    String? cardNumber;
    DateTime? dateTime;
    double? balanceAfter;

    for (final line in lines) {
      if (line.contains('🎉 Пополнение') || line.contains('➕')) {
        type = TransactionType.income;
      } else if (line.contains('❌ Списание') || line.contains('➖')) {
        type = TransactionType.expense;
      } else if (line.contains('UZS') && (line.contains('➕') || line.contains('➖'))) {
        // Парсинг суммы: "50.250,00 UZS" -> 50250.0
        final amountStr = line.replaceAll('UZS', '').replaceAll('➕', '').replaceAll('➖', '').trim();
        final parts = amountStr.split(',');
        if (parts.length == 2) {
          final whole = parts[0].replaceAll('.', '');
          final decimal = parts[1];
          amount = double.tryParse('$whole.$decimal');
        }
      } else if (line.startsWith('📍')) {
        location = line.substring(1).trim();
      } else if (line.startsWith('💳')) {
        cardNumber = line.substring(1).trim();
      } else if (line.startsWith('🕓')) {
        // "10:56 01.05.2026"
        final timeStr = line.substring(1).trim();
        final parts = timeStr.split(' ');
        if (parts.length == 2) {
          final time = parts[0];
          final date = parts[1];
          final dateTimeStr = '$date $time';
          dateTime = DateTime.tryParse(dateTimeStr.replaceAll('.', '-').replaceAll(' ', 'T'));
        }
      } else if (line.startsWith('💰')) {
        final balanceStr = line.substring(1).replaceAll('UZS', '').trim();
        final parts = balanceStr.split(',');
        if (parts.length == 2) {
          final whole = parts[0].replaceAll('.', '');
          final decimal = parts[1];
          balanceAfter = double.tryParse('$whole.$decimal');
        }
      }
    }

    if (type == null || amount == null || location == null || cardNumber == null || dateTime == null || balanceAfter == null) {
      return null;
    }

    const uuid = Uuid();
    return Transaction(
      id: uuid.v4(),
      type: type,
      amount: amount,
      location: location,
      cardNumber: cardNumber,
      dateTime: dateTime,
      balanceAfter: balanceAfter,
      rawText: rawText,
    );
  }

  /// Парсер SMS-сообщений от HUMO банка
  /// Поддерживает разные форматы SMS
  static Transaction? parseFromSms(String smsBody) {
    if (smsBody.isEmpty) return null;

    try {
      final body = smsBody.toLowerCase();

      // Определить тип транзакции
      TransactionType type;
      if (body.contains('popolnenie') || 
          body.contains('пополнение') ||
          body.contains('zachislenie') ||
          body.contains('зачисление')) {
        type = TransactionType.income;
      } else if (body.contains('spisanie') || 
                 body.contains('списание') ||
                 body.contains('oplata') ||
                 body.contains('оплата')) {
        type = TransactionType.expense;
      } else {
        return null; // Не похоже на финансовое SMS
      }

      // Извлечь сумму (ищем число перед UZS)
      final amountRegex = RegExp(r'(\d[\d\s.,]*)\s*uzs', caseSensitive: false);
      final amountMatch = amountRegex.firstMatch(smsBody);
      if (amountMatch == null) return null;

      final amountStr = amountMatch.group(1)!
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      final amount = double.tryParse(amountStr) ?? 0;
      if (amount == 0) return null;

      // Извлечь баланс (второе вхождение числа перед UZS или после "balans")
      double balance = 0;
      final balanceRegex = RegExp(
        r'balans[:\s]+(\d[\d\s.,]*)\s*uzs', 
        caseSensitive: false,
      );
      final balanceMatch = balanceRegex.firstMatch(smsBody);
      if (balanceMatch != null) {
        final balStr = balanceMatch.group(1)!
            .replaceAll(' ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        balance = double.tryParse(balStr) ?? 0;
      }

      // Извлечь номер карты
      final cardRegex = RegExp(r'\*(\d{4})');
      final cardMatch = cardRegex.firstMatch(smsBody);
      final cardNumber = cardMatch != null ? '*${cardMatch.group(1)}' : '*7591';

      // Извлечь место/мерчант (всё что не является числом и ключевыми словами)
      String place = _extractMerchantFromSms(smsBody);

      // Извлечь дату (ищем DD.MM.YYYY HH:MM)
      DateTime date = DateTime.now();
      final dateRegex = RegExp(
        r'(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2})',
      );
      final dateMatch = dateRegex.firstMatch(smsBody);
      if (dateMatch != null) {
        date = DateTime(
          int.parse(dateMatch.group(3)!),
          int.parse(dateMatch.group(2)!),
          int.parse(dateMatch.group(1)!),
          int.parse(dateMatch.group(4)!),
          int.parse(dateMatch.group(5)!),
        );
      }

      return Transaction(
        id: '${date.millisecondsSinceEpoch}_${amount.toInt()}',
        type: type,
        amount: amount,
        location: place,
        cardNumber: cardNumber,
        dateTime: date,
        balanceAfter: balance,
        rawText: smsBody,
      );
    } catch (e) {
      debugPrint('Ошибка парсинга SMS: $e');
      return null;
    }
  }

  /// Вспомогательный метод — извлечь название магазина из SMS
  static String _extractMerchantFromSms(String body) {
    // Убираем известные паттерны и оставляем название
    final cleaned = body
        .replaceAll(RegExp(r'\d[\d.,\s]*UZS', caseSensitive: false), '')
        .replaceAll(RegExp(r'Balans[:\s]+', caseSensitive: false), '')
        .replaceAll(RegExp(r'Karta\s+\*\d+', caseSensitive: false), '')
        .replaceAll(RegExp(r'HUMOCARD[:\s]*', caseSensitive: false), '')
        .replaceAll(RegExp(r'Popolnenie|Spisanie|Zachislenie|Oplata', caseSensitive: false), '')
        .replaceAll(RegExp(r'\d{2}\.\d{2}\.\d{4}'), '')
        .replaceAll(RegExp(r'\d{2}:\d{2}'), '')
        .replaceAll(RegExp(r'[.!]'), '')
        .trim();

    // Берём первую непустую "значимую" часть
    final parts = cleaned.split(RegExp(r'[.,\n]'));
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.length > 2) return trimmed;
    }
    return 'HUMO транзакция';
  }
}