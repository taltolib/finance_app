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
}
