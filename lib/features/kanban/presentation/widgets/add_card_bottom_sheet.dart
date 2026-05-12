import 'package:flutter/material.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../transactions/data/models/transaction.dart';

class AddCardBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onCardAdded;

  const AddCardBottomSheet({
    required this.transactions,
    required this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Добавить транзакцию',
                  style:AppFonts.mulish.s18w700(color: colors.text)),
              const SizedBox(height: 16),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                  child: Text('Нет транзакций за текущий месяц',
                      style:AppFonts.mulish.s14w500(color: colors.text)),
                )
                    : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: ListTile(
                        title: Text(tx.location,
                            style:AppFonts.mulish.s14w500(color: colors.text)),
                        subtitle: Text(
                          '${tx.amount.toStringAsFixed(0)} UZS',
                          style: AppFonts.mulish.s12w500(color: Colors.white)),
                        onTap: () {
                          onCardAdded(tx);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}