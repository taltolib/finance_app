import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';


class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final color = isIncome ?  AppColors.green :  AppColors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colors.text.withOpacity(0.2), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15 , vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                     border:  Border.all(color: color.withOpacity(0.2), width: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child:  Icon(icon, color: color,size: 20),
                ),
              ),
              const SizedBox(width: 15,),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.location,
                      style: AppFonts.mulish.s12w700(color: colors.text),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      '${isIncome ? '+' : '-'}${NumberFormat('#,##0.00', 'ru_RU').format(transaction.amount)} UZS',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                flex:1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat('dd.MM.yyyy HH:mm', 'ru_RU').format(transaction.dateTime),style: AppFonts.mulish.s12w400(color: colors.text.withOpacity(0.5),)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}