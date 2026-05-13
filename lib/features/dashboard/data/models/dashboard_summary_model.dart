class DashboardSummaryModel {
  final double income;
  final double expense;
  final double balance;
  final int transactionsCount;
  final int month;
  final int year;
  final String monthId;
  final String monthTitle;
  final bool canGoNextMonth;
  final bool canGoPreviousMonth;

  const DashboardSummaryModel({
    required this.income,
    required this.expense,
    required this.balance,
    required this.transactionsCount,
    required this.month,
    required this.year,
    required this.monthId,
    required this.monthTitle,
    required this.canGoNextMonth,
    required this.canGoPreviousMonth,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : json;

    final monthId = (json['month'] ?? '').toString();
    final now = DateTime.now();
    final parsedYear = monthId.length >= 4 ? int.tryParse(monthId.substring(0, 4)) : null;
    final parsedMonth = monthId.length >= 7 ? int.tryParse(monthId.substring(5, 7)) : null;

    return DashboardSummaryModel(
      income: _num(summary['income_total'] ?? summary['income']),
      expense: _num(summary['expense_total'] ?? summary['expense']),
      balance: _num(summary['net_total'] ?? summary['balance']),
      transactionsCount: (summary['transactions_count'] as num?)?.toInt() ?? 0,
      month: parsedMonth ?? (json['month'] is int ? json['month'] as int : now.month),
      year: parsedYear ?? (json['year'] is int ? json['year'] as int : now.year),
      monthId: monthId.isNotEmpty ? monthId : '${now.year}-${now.month.toString().padLeft(2, '0')}',
      monthTitle: (json['month_title'] ?? '').toString(),
      canGoNextMonth: json['can_go_next_month'] == true,
      canGoPreviousMonth: json['can_go_previous_month'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'income': income,
        'expense': expense,
        'balance': balance,
        'transactions_count': transactionsCount,
        'month': month,
        'year': year,
        'month_id': monthId,
        'month_title': monthTitle,
        'can_go_next_month': canGoNextMonth,
        'can_go_previous_month': canGoPreviousMonth,
      };

  static double _num(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }
}
