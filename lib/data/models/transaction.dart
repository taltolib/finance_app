import 'dart:convert';

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

  // ─── ПАРСЕР ───────────────────────────────────────────────────────────────
  // Парсит сообщение от @HUMOcardbot
  //
  // Пример входного текста:
  // 🎉 Пополнение
  // ➕ 50.250,00 UZS
  // 📍 ZOOMRAD P2P HU2HU>TO
  // 💳 HUMOCARD *7591
  // 🕓 10:56 01.05.2026
  // 💰 50.250,66 UZS
  // ─────────────────────────────────────────────────────────────────────────
  static Transaction? parse(String rawText) {
    try {
      final lines = rawText.trim().split('\n').map((l) => l.trim()).toList();

      // Тип транзакции
      TransactionType type = TransactionType.unknown;
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (lower.contains('пополнение') ||
            lower.contains("to'lov qabul qilindi") ||
            lower.contains('kirim') ||
            line.contains('➕')) {
          type = TransactionType.income;
          break;
        } else if (lower.contains('списание') ||
            lower.contains('оплата') ||
            lower.contains('chiqim') ||
            line.contains('➖')) {
          type = TransactionType.expense;
          break;
        }
      }

      // Сумма — ищем строку с ➕ или ➖ и "UZS"
      double amount = 0;
      final amountReg = RegExp(r'[➕➖]\s*([\d\s.,]+)\s*UZS', caseSensitive: false);
      for (final line in lines) {
        final m = amountReg.firstMatch(line);
        if (m != null) {
          amount = _parseAmount(m.group(1)!);
          break;
        }
      }

      // Место — строка с 📍
      String place = '';
      for (final line in lines) {
        if (line.contains('📍')) {
          place = line.replaceAll('📍', '').trim();
          break;
        }
      }

      // Номер карты — строка с 💳
      String cardNumber = '';
      for (final line in lines) {
        if (line.contains('💳')) {
          cardNumber = line.replaceAll('💳', '').trim();
          break;
        }
      }

      // Дата и время — строка с 🕓
      DateTime dateTime = DateTime.now();
      for (final line in lines) {
        if (line.contains('🕓')) {
          final dateStr = line.replaceAll('🕓', '').trim();
          dateTime = _parseDateTime(dateStr);
          break;
        }
      }

      // Баланс — строка с 💰
      double balance = 0;
      final balanceReg = RegExp(r'💰\s*([\d\s.,]+)\s*UZS', caseSensitive: false);
      for (final line in lines) {
        final m = balanceReg.firstMatch(line);
        if (m != null) {
          balance = _parseAmount(m.group(1)!);
          break;
        }
      }

      if (amount == 0) return null; // не похоже на транзакцию

      return Transaction(
        id: '${dateTime.millisecondsSinceEpoch}_${amount.toInt()}',
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

  // Парсит "50.250,66" или "50 250,66" или "50250.66" → double
  static double _parseAmount(String raw) {
    String s = raw.trim();
    // Убираем пробелы внутри числа
    s = s.replaceAll(' ', '');
    // Формат "50.250,66" (точка — разделитель тысяч, запятая — дробная)
    if (s.contains(',') && s.contains('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',')) {
      // Только запятая — дробная часть
      s = s.replaceAll(',', '.');
    }
    return double.tryParse(s) ?? 0;
  }

  // Парсит "10:56 01.05.2026"
  static DateTime _parseDateTime(String raw) {
    try {
      final parts = raw.trim().split(' ');
      if (parts.length >= 2) {
        final timeParts = parts[0].split(':');
        final dateParts = parts[1].split('.');
        if (timeParts.length == 2 && dateParts.length == 3) {
          return DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }
    } catch (_) {}
    return DateTime.now();
  }

  // ─── JSON сериализация для SQLite ──────────────────────────────────────
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