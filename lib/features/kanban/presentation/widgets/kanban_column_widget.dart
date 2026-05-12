import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:finance_app/shared/widgets/custom_show_dialog.dart';
import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';
import 'small_transaction_card.dart';

class KanbanColumnWidget extends StatelessWidget {
  final KanbanColumnModel column;
  final bool isDragTarget;
  final VoidCallback onAddCard;
  final ValueChanged<KanbanDragData> onCardDropped;
  final ValueChanged<String> onDragHover;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.isDragTarget,
    required this.onAddCard,
    required this.onCardDropped,
    required this.onDragHover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final totalAmount = column.cards.fold<double>(
      0,
      (sum, card) => sum + card.amount,
    );

    return DragTarget<KanbanDragData>(
      onWillAccept: (data) {
        onDragHover(column.id);
        return data != null && data.fromColumnId != column.id;
      },
      onAccept: onCardDropped,
      onLeave: (_) {},
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          constraints: const BoxConstraints(maxHeight:150 ),///тут будет высота колонки и она должна раширатся в зависемости скролько там транзакций
          decoration: BoxDecoration(
            color: isDragTarget
                ? KanbanUiColors.blue.withOpacity(0.08)
                : colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDragTarget ? KanbanUiColors.blue : KanbanUiColors.border,
            ),
            boxShadow: isDragTarget
                ? [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              _ColumnHeader(
                  title: column.title,
                  count: column.cards.length,
                  totalAmount: totalAmount,
                  onTap: () => customShowBottomSheetDialog(

                      context,
                      0.2,
                      const SizedBox.shrink(),
                      ListView(
                        children:  const[
                          ///Пусту будеть кнопка редактаци
                          /// и кнопка удаления колонки  у обоих будеть он тап вкотором будеть передавайтя логика(провайдер + поклучон на апи запросы)
                        ],
                      ),
                      const SizedBox.shrink())),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  children: [
                    ...column.cards.map(
                      (card) {
                        return LongPressDraggable<KanbanDragData>(
                          data: KanbanDragData(
                            cardId: card.id,
                            fromColumnId: column.id,
                          ),
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 200,
                              child: SmallTransactionCard(
                                card: card,
                                dragging: true,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.35,
                            child: SmallTransactionCard(card: card),
                          ),
                          child: SmallTransactionCard(card: card),
                        );
                      },
                    ),
                    if (!column.isSystem)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KanbanUiColors.textMuted,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                              style: BorderStyle.solid,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: onAddCard,
                          child: Text(
                            '+ Добавить карточку',
                            style: kanbanText(
                              size: 12,
                              color: colors.text.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;
  final double totalAmount;

  const _ColumnHeader({
    required this.title,
    required this.count,
    required this.totalAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.text.withOpacity(0.10)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.mulish.s15w600(color: colors.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '•••',
                    style: AppFonts.mulish
                        .s11w400(color: colors.text.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Количество: ',
                style: AppFonts.mulish
                    .s11w400(color: colors.text.withOpacity(0.5)),
              ),
              Text(
                '$count',
                style: AppFonts.mulish
                    .s11w400(color: colors.text.withOpacity(0.5)),
              ),
              const SizedBox(width: 16),
              Text(
                'Итог: ',
                style: AppFonts.mulish
                    .s11w400(color: colors.text.withOpacity(0.5)),
              ),
              Expanded(
                child: Text(
                  totalAmount.toStringAsFixed(0),
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.mulish.s11w400(color: AppColors.red),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
