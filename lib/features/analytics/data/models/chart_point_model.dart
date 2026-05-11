/// Модель для точки графика
class ChartPointModel {
  final DateTime date;
  final String label;
  final double income;
  final double expense;

  ChartPointModel({
    required this.date,
    required this.label,
    required this.income,
    required this.expense,
  });

  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
    return ChartPointModel(
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      label: json['label'] ?? '',
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'label': label,
      'income': income,
      'expense': expense,
    };
  }

  double get net => income - expense;
}
