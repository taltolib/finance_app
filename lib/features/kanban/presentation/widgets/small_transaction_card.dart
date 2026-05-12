import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';

class SmallTransactionCard extends StatelessWidget {
  final KanbanCardModel card;
  final bool dragging;

  const SmallTransactionCard({
    super.key,
    required this.card,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final amount = card.amount.toStringAsFixed(0).replaceAll('-', '-');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: dragging
            ? KanbanUiColors.blue.withOpacity(0.18)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: dragging
              ? KanbanUiColors.blue
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: kanbanText(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kanbanText(
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kanbanText(
                      size: 10,
                      color: KanbanUiColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: kanbanText(
              size: 13,
              weight: FontWeight.w700,
              color: KanbanUiColors.red,
            ),
          ),
        ],
      ),
    );
  }
}