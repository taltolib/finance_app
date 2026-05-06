import 'dart:convert';
import 'package:uuid/uuid.dart';

enum TransactionType { income, expense, unknown }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String place;
  final String cardNumber;
  final DateTime dateTime;
  final double balance;
  final String rawText;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.place,
    required this.cardNumber,
    required this.dateTime,
    required this.balance,
    required this.rawText,
  });

  // ─── ПАРСЕРЫ ──────────────────────────────────────────────────────────────

  /// Основной парсер для сообщений от @HUMOcardbot
  static Transaction? parse(String rawText) {
    try {
      final lines = rawText.trim().split('\n').map((l) => l.trim()).toList();
      if (lines.isEmpty) return null;

      TransactionType type = TransactionType.unknown;
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (lower.contains('пополнение') || line.contains('➕')) {
          type = TransactionType.income;
          break;
        } else if (lower.contains('списание') || line.contains('➖')) {
          type = TransactionType.expense;
          break;
        }
      }

      double amount = 0;
      final amountReg = RegExp(r'[➕➖]\s*([\d\s.,]+)\s*UZS', caseSensitive: false);
      for (final line in lines) {
        final m = amountReg.firstMatch(line);
        if (m != null) {
          amount = _parseAmount(m.group(1)!);
          break;
        }
      }

      String place = '';
      for (final line in lines) {
        if (line.contains('📍')) {
          place = line.replaceAll('📍', '').trim();
          break;
        }
      }

      String cardNumber = '';
      for (final line in lines) {
        if (line.contains('💳')) {
          cardNumber = line.replaceAll('💳', '').trim();
          break;
        }
      }

      DateTime dateTime = DateTime.now();
      for (final line in lines) {
        if (line.contains('🕓')) {
          final dateStr = line.replaceAll('🕓', '').trim();
          dateTime = _parseDateTime(dateStr);
          break;
        }
      }

      double balance = 0;
      final balanceReg = RegExp(r'💰\s*([\d\s.,]+)\s*UZS', caseSensitive: false);
      for (final line in lines) {
        final m = balanceReg.firstMatch(line);
        if (m != null) {
          balance = _parseAmount(m.group(1)!);
          break;
        }
      }

      if (amount == 0) return parseFromSms(rawText); // Пробуем другой формат

      return Transaction(
        id: const Uuid().v4(),
        type: type,
        amount: amount,
        place: place.isEmpty ? 'Неизвестно' : place,
        cardNumber: cardNumber.isEmpty ? 'HUMOCARD' : cardNumber,
        dateTime: dateTime,
        balance: balance,
        rawText: rawText,
      );
    } catch (e) {
      return null;
    }
  }

  /// Парсер для обычных SMS сообщений
  static Transaction? parseFromSms(String smsBody) {
    try {
      final body = smsBody.toLowerCase();
      TransactionType type;
      if (body.contains('popolnenie') || body.contains('пополнение')) {
        type = TransactionType.income;
      } else if (body.contains('spisanie') || body.contains('oplata')) {
        type = TransactionType.expense;
      } else {
        return null;
      }

      final amountRegex = RegExp(r'(\d[\d\s.,]*)\s*uzs', caseSensitive: false);
      final amountMatch = amountRegex.firstMatch(smsBody);
      if (amountMatch == null) return null;
      final amount = _parseAmount(amountMatch.group(1)!);

      double balance = 0;
      final balanceRegex = RegExp(r'balans[:\s]+(\d[\d\s.,]*)\s*uzs', caseSensitive: false);
      final balanceMatch = balanceRegex.firstMatch(smsBody);
      if (balanceMatch != null) {
        balance = _parseAmount(balanceMatch.group(1)!);
      }

      final cardRegex = RegExp(r'\*(\d{4})');
      final cardMatch = cardRegex.firstMatch(smsBody);
      final cardNumber = cardMatch != null ? '*${cardMatch.group(1)}' : 'HUMOCARD';

      DateTime date = DateTime.now();
      final dateRegex = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2})');
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
        id: const Uuid().v4(),
        type: type,
        amount: amount,
        place: 'HUMO транзакция',
        cardNumber: cardNumber,
        dateTime: date,
        balance: balance,
        rawText: smsBody,
      );
    } catch (e) {
      return null;
    }
  }

  static double _parseAmount(String raw) {
    String s = raw.trim().replaceAll(' ', '');
    if (s.contains(',') && s.contains('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      s = s.replaceAll(',', '.');
    }
    return double.tryParse(s) ?? 0;
  }

  static DateTime _parseDateTime(String raw) {
    try {
      final parts = raw.trim().split(' ');
      if (parts.length >= 2) {
        final timeParts = parts[0].split(':');
        final dateParts = parts[1].split('.');
        return DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    } catch (_) {}
    return DateTime.now();
  }

  // ─── СЕРИАЛИЗАЦИЯ ────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'place': place,
    'cardNumber': cardNumber,
    'dateTime': dateTime.toIso8601String(),
    'balance': balance,
    'rawText': rawText,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'] as String,
    type: TransactionType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => TransactionType.unknown,
    ),
    amount: (map['amount'] as num).toDouble(),
    place: map['place'] as String,
    cardNumber: map['cardNumber'] as String,
    dateTime: DateTime.parse(map['dateTime'] as String),
    balance: (map['balance'] as num).toDouble(),
    rawText: map['rawText'] as String,
  );

  String toJson() => jsonEncode(toMap());
  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
