class AnalyticsSummaryModel {
  final double income;
  final double expense;
  final double total;
  final int transactionsCount;
  final String period;
  final DateTime fromDate;
  final DateTime toDate;

  const AnalyticsSummaryModel({
    required this.income,
    required this.expense,
    required this.total,
    required this.transactionsCount,
    required this.period,
    required this.fromDate,
    required this.toDate,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : json;

    return AnalyticsSummaryModel(
      income: _num(summary['income_total'] ?? summary['income']),
      expense: _num(summary['expense_total'] ?? summary['expense']),
      total: _num(summary['net_total'] ?? summary['total']),
      transactionsCount: (summary['transactions_count'] as num?)?.toInt() ?? 0,
      period: (json['period'] ?? summary['period'] ?? 'day').toString(),
      fromDate: _parseDate(json['from'] ?? summary['from_date']),
      toDate: _parseDate(json['to'] ?? summary['to_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'income': income,
        'expense': expense,
        'total': total,
        'transactions_count': transactionsCount,
        'period': period,
        'from_date': fromDate.toIso8601String(),
        'to_date': toDate.toIso8601String(),
      };

  static double _num(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  static DateTime _parseDate(dynamic raw) {
    final value = raw?.toString();
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }
}
