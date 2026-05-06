import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String location;
  final String cardNumber;
  final DateTime dateTime;
  final double balanceAfter;
  final String rawText;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.location,
    required this.cardNumber,
    required this.dateTime,
    required this.balanceAfter,
    required this.rawText,
  });

  @override
  List<Object?> get props => [id, type, amount, location, cardNumber, dateTime, balanceAfter, rawText];

  /// Парсинг Telegram сообщений от @HUMOcardbot
  /// Поддерживает форматы:
  /// - emoji-based (✅ Пополнение: 50250.00 UZS ...)
  /// - text-based (HUMOCARD: Счисление 87500 UZS ...)
  static Transaction? parse(String text) {
    if (text.isEmpty) return null;

    try {
      final lines = text.trim().split('\n');
      if (lines.isEmpty) return null;

      TransactionType type = TransactionType.expense;
      double amount = 0;
      String location = '';
      String cardNumber = '';
      double balance = 0;
      DateTime? transactionDate;

      // Определение типа по первой строке (emoji)
      final firstLine = lines[0].toLowerCase();
      if (firstLine.contains('✅') ||
          firstLine.contains('пополнение') ||
          firstLine.contains('зачисление') ||
          firstLine.contains('входящий')) {
        type = TransactionType.income;
      }

      // Парсинг каждой строки
      for (final line in lines) {
        // Сумма: "Пополнение: 50250.00 UZS" или "Счисление: 87500 UZS"
        if (line.contains('Пополнение:') ||
            line.contains('Счисление:') ||
            line.contains('Списание:') ||
            line.contains(':')) {
          final amountMatch = RegExp(r'[\d\s]+\.\d{2}').firstMatch(line) ??
              RegExp(r'[\d\s]+').firstMatch(line);
          if (amountMatch != null) {
            amount = double.tryParse(
                  amountMatch.group(0)!.replaceAll(' ', '').replaceAll(',', '.'),
                ) ??
                0;
          }
        }

        // Место: "Место: Кофе-хаус" или прямо в начале
        if (line.contains('Место:')) {
          location = line.replaceAll('Место:', '').trim();
        }

        // Карта: "Карта: *7591" или "Корзинка"
        if (line.contains('Карта:')) {
          cardNumber = line.replaceAll('Карта:', '').trim();
        } else if (line.contains('*')) {
          final cardMatch = RegExp(r'\*\d+').firstMatch(line);
          if (cardMatch != null) {
            cardNumber = cardMatch.group(0) ?? '';
          }
        }

        // Баланс: "Баланс: 100500.00 UZS"
        if (line.contains('Баланс:') || line.contains('Balance:')) {
          final balanceMatch =
              RegExp(r'[\d\s]+\.\d{2}').firstMatch(line.replaceAll('Баланс:', ''));
          if (balanceMatch != null) {
            balance = double.tryParse(
                  balanceMatch.group(0)!.replaceAll(' ', '').replaceAll(',', '.'),
                ) ??
                0;
          }
        }

        // Дата и время: "01.05.2026 09:30" или "May 1, 2026"
        if (line.contains(RegExp(r'\d{2}\.\d{2}\.\d{4}'))) {
          final dateMatch = RegExp(r'(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2})')
              .firstMatch(line);
          if (dateMatch != null) {
            final day = int.parse(dateMatch.group(1)!);
            final month = int.parse(dateMatch.group(2)!);
            final year = int.parse(dateMatch.group(3)!);
            final hour = int.parse(dateMatch.group(4)!);
            final minute = int.parse(dateMatch.group(5)!);
            transactionDate = DateTime(year, month, day, hour, minute);
          }
        }
      }

      if (amount == 0 || location.isEmpty) {
        return null;
      }

      final uuid = _generateId();
      final datetime = transactionDate ?? DateTime.now();

      return Transaction(
        id: uuid,
        type: type,
        amount: amount,
        location: location,
        cardNumber: cardNumber.isNotEmpty ? cardNumber : 'HUMOCARD',
        dateTime: datetime,
        balanceAfter: balance,
        rawText: text,
      );
    } catch (e) {
      return null;
    }
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'location': location,
      'card_number': cardNumber,
      'date_time': dateTime.toIso8601String(),
      'balance_after': balanceAfter,
      'raw_text': rawText,
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (map['amount'] as num).toDouble(),
      location: map['location'],
      cardNumber: map['card_number'] ?? 'HUMOCARD',
      dateTime: DateTime.parse(map['date_time']),
      balanceAfter: (map['balance_after'] as num).toDouble(),
      rawText: map['raw_text'] ?? '',
    );
  }
}
