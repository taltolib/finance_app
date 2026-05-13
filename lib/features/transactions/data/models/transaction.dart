import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String location;
  final String cardNumber;
  final DateTime dateTime;
  final double balanceAfter;
  final String rawText;

  final String? currency;
  final String? title;
  final String? category;
  final String? categoryTitle;
  final int? telegramMessageId;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.location,
    required this.cardNumber,
    required this.dateTime,
    required this.balanceAfter,
    required this.rawText,
    this.currency,
    this.title,
    this.category,
    this.categoryTitle,
    this.telegramMessageId,
  });

  String get merchant => location;
  String get cardLast4 => cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'location': location,
      'cardNumber': cardNumber,
      'dateTime': dateTime.toIso8601String(),
      'balanceAfter': balanceAfter,
      'rawText': rawText,
      'currency': currency,
      'title': title,
      'category': category,
      'category_title': categoryTitle,
      'telegram_message_id': telegramMessageId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: (map['id'] ?? '').toString(),
      type: _parseType(map['type']),
      amount: _num(map['amount']),
      location: (map['location'] ?? map['merchant'] ?? map['description'] ?? 'Транзакция').toString(),
      cardNumber: (map['cardNumber'] ?? map['card_name'] ?? map['card_last4'] ?? '').toString(),
      dateTime: _parseDate(map['dateTime'] ?? map['datetime'] ?? map['tx_datetime']),
      balanceAfter: _num(map['balanceAfter'] ?? map['balance']),
      rawText: (map['rawText'] ?? map['raw_text'] ?? '').toString(),
      currency: (map['currency'] ?? 'UZS').toString(),
      title: map['title']?.toString(),
      category: (map['category'] ?? map['category_id'])?.toString(),
      categoryTitle: map['category_title']?.toString(),
      telegramMessageId: map['telegram_message_id'] is int
          ? map['telegram_message_id'] as int
          : int.tryParse('${map['telegram_message_id'] ?? ''}'),
    );
  }

  static TransactionType _parseType(dynamic raw) {
    if (raw is int) return TransactionType.values[raw.clamp(0, 1)];
    final value = raw?.toString().toLowerCase().trim();
    return value == 'income' ? TransactionType.income : TransactionType.expense;
  }

  static double _num(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    final value = raw?.toString();
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
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
        final amountStr = line.replaceAll('UZS', '').replaceAll('➕', '').replaceAll('➖', '').trim();
        final parts = amountStr.split(',');
        if (parts.length == 2) {
          amount = double.tryParse('${parts[0].replaceAll('.', '')}.${parts[1]}');
        }
      } else if (line.startsWith('📍')) {
        location = line.substring(1).trim();
      } else if (line.startsWith('💳')) {
        cardNumber = line.substring(1).trim();
      } else if (line.startsWith('🕓')) {
        final parts = line.substring(1).trim().split(' ');
        if (parts.length == 2) {
          final time = parts[0].split(':');
          final date = parts[1].split('.');
          if (time.length == 2 && date.length == 3) {
            dateTime = DateTime(
              int.parse(date[2]),
              int.parse(date[1]),
              int.parse(date[0]),
              int.parse(time[0]),
              int.parse(time[1]),
            );
          }
        }
      } else if (line.startsWith('💰')) {
        final balanceStr = line.substring(1).replaceAll('UZS', '').trim();
        final parts = balanceStr.split(',');
        if (parts.length == 2) {
          balanceAfter = double.tryParse('${parts[0].replaceAll('.', '')}.${parts[1]}');
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
      currency: 'UZS',
    );
  }

  static Transaction? parseFromSms(String smsBody) {
    if (smsBody.isEmpty) return null;

    try {
      final body = smsBody.toLowerCase();
      TransactionType type;
      if (body.contains('popolnenie') || body.contains('пополнение') || body.contains('zachislenie') || body.contains('зачисление')) {
        type = TransactionType.income;
      } else if (body.contains('spisanie') || body.contains('списание') || body.contains('oplata') || body.contains('оплата')) {
        type = TransactionType.expense;
      } else {
        return null;
      }

      final amountMatch = RegExp(r'(\d[\d\s.,]*)\s*uzs', caseSensitive: false).firstMatch(smsBody);
      if (amountMatch == null) return null;
      final amount = double.tryParse(amountMatch.group(1)!.replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0;
      if (amount == 0) return null;

      double balance = 0;
      final balanceMatch = RegExp(r'balans[:\s]+(\d[\d\s.,]*)\s*uzs', caseSensitive: false).firstMatch(smsBody);
      if (balanceMatch != null) {
        balance = double.tryParse(balanceMatch.group(1)!.replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0;
      }

      final cardMatch = RegExp(r'\*(\d{4})').firstMatch(smsBody);
      final cardNumber = cardMatch != null ? '*${cardMatch.group(1)}' : '';
      final place = _extractMerchantFromSms(smsBody);

      DateTime date = DateTime.now();
      final dateMatch = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2})').firstMatch(smsBody);
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
        currency: 'UZS',
      );
    } catch (e) {
      debugPrint('Ошибка парсинга SMS: $e');
      return null;
    }
  }

  static String _extractMerchantFromSms(String body) {
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

    for (final part in cleaned.split(RegExp(r'[.,\n]'))) {
      final trimmed = part.trim();
      if (trimmed.length > 2) return trimmed;
    }
    return 'HUMO транзакция';
  }
}
