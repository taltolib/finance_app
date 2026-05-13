class ChartPointModel {
  final DateTime date;
  final String label;
  final double income;
  final double expense;

  const ChartPointModel({
    required this.date,
    required this.label,
    required this.income,
    required this.expense,
  });

  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
    return ChartPointModel(
      date: _parseDate(json['date']),
      label: (json['label'] ?? '').toString(),
      income: _num(json['income']),
      expense: _num(json['expense']),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'label': label,
        'income': income,
        'expense': expense,
      };

  double get net => income - expense;

  static double _num(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  static DateTime _parseDate(dynamic raw) {
    final value = raw?.toString();
    if (value == null || value.isEmpty) return DateTime.now();
    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(value)) return DateTime.parse('$value-01');
    return DateTime.tryParse(value) ?? DateTime.now();
  }
}
