/// Universal Transaction Tile Widget
/// Переиспользуемая плитка для отображения транзакций

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/features/transactions/data/models/transaction.dart' show TransactionType;

class TransactionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String amount;
  final String? currency;
  final IconData icon;
  final TransactionType type;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDismissible;

  const TransactionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.amount,
    this.currency = 'UZS',
    this.icon = Icons.shopping_cart,
    this.type = TransactionType.expense,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.onDelete,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Цвета по типу транзакции
    final transactionColor = type == TransactionType.income
        ? Colors.green
        : Colors.orange;
    
    final icon_ = type == TransactionType.income
        ? Icons.arrow_downward
        : Icons.arrow_upward;

    final tile = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? transactionColor).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon_,
                color: iconColor ?? transactionColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${type == TransactionType.income ? '+' : '-'}$amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor ?? transactionColor,
                  ),
                ),
                if (currency != null)
                  Text(
                    currency!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isDismissible && onDelete != null) {
      return Dismissible(
        key: Key('$title-$amount'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
        onDismissed: (_) => onDelete!(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: tile,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: tile,
    );
  }
}
