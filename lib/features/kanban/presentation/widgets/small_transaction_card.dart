import 'package:flutter/material.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
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
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color:colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.text.withOpacity(0.08),
          width: 1
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
                    style: AppFonts.mulish.s12w400(color: colors.text),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '-$amount',
                    style: AppFonts.mulish.s14w700(color: AppColors.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                card.date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.mulish.s12w700(color: colors.text.withOpacity(0.5)),),

    ]
    )
        ],
      ),
    );
  }
}