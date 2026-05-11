/// Модель для summary аналитики
class AnalyticsSummaryModel {
  final double income;
  final double expense;
  final double total;
  final int transactionsCount;
  final String period;
  final DateTime fromDate;
  final DateTime toDate;

  AnalyticsSummaryModel({
    required this.income,
    required this.expense,
    required this.total,
    required this.transactionsCount,
    required this.period,
    required this.fromDate,
    required this.toDate,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      transactionsCount: json['transactions_count'] ?? 0,
      period: json['period'] ?? 'month',
      fromDate: json['from_date'] != null
          ? DateTime.parse(json['from_date'] as String)
          : DateTime.now(),
      toDate: json['to_date'] != null
          ? DateTime.parse(json['to_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': income,
      'expense': expense,
      'total': total,
      'transactions_count': transactionsCount,
      'period': period,
      'from_date': fromDate.toIso8601String(),
      'to_date': toDate.toIso8601String(),
    };
  }
}
