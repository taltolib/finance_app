import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';
import 'small_transaction_card.dart';

typedef OnEditColumn = void Function(String columnId, String currentTitle);
typedef OnDeleteColumn = void Function(String columnId);

class KanbanColumnWidget extends StatelessWidget {
  final KanbanColumnModel column;
  final bool isDragTarget;
  final VoidCallback onAddCard;
  final ValueChanged<KanbanDragData> onCardDropped;
  final ValueChanged<String> onDragHover;
  final OnEditColumn? onEditColumn;
  final OnDeleteColumn? onDeleteColumn;

  // Delete mode
  final bool deleteMode;
  final Set<String> selectedCardIds;
  final ValueChanged<String>? onCardSelected;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.isDragTarget,
    required this.onAddCard,
    required this.onCardDropped,
    required this.onDragHover,
    this.onEditColumn,
    this.onDeleteColumn,
    this.deleteMode = false,
    this.selectedCardIds = const {},
    this.onCardSelected,
  });

  void _showColumnMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.60),
      builder: (_) => _ColumnMenuSheet(
        column: column,
        onEdit: (title) {
          Navigator.of(context).pop();
          onEditColumn?.call(column.id, title);
        },
        onDelete: () {
          Navigator.of(context).pop();
          onDeleteColumn?.call(column.id);
        },
      ),
    );
  }

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
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.text.withOpacity(0.5),
              width: 0.5
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
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _ColumnHeader(
                  title: column.title,
                  count: column.cards.length,
                  totalAmount: totalAmount,
                  isSystem: column.isSystem,
                  onTap: () => _showColumnMenu(context),
                ),
                if (column.cards.length > 6)
                   SizedBox(
                    height: 420,
                    child: _CardsList(
                      column: column,
                      onAddCard: onAddCard,
                      shrinkWrap: false,
                      deleteMode: deleteMode,
                      selectedCardIds: selectedCardIds,
                      onCardSelected: onCardSelected,
                    ),
                  )
                else
                // До 6 карточек — высота по содержимому (как Trello)
                  _CardsList(
                    column: column,
                    onAddCard: onAddCard,
                    shrinkWrap: true,
                    deleteMode: deleteMode,
                    selectedCardIds: selectedCardIds,
                    onCardSelected: onCardSelected,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Cards List ───────────────────────────────────────────────────────────────
class _CardsList extends StatelessWidget {
  final KanbanColumnModel column;
  final VoidCallback onAddCard;
  final bool shrinkWrap;
  final bool deleteMode;
  final Set<String> selectedCardIds;
  final ValueChanged<String>? onCardSelected;

  const _CardsList({
    required this.column,
    required this.onAddCard,
    this.shrinkWrap = false,
    this.deleteMode = false,
    this.selectedCardIds = const {},
    this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      children: [
        ...column.cards.map((card) {
          final isSelected = selectedCardIds.contains(card.id);

          if (deleteMode) {
            // В режиме удаления — нажатие выделяет карточку
            return GestureDetector(
              onTap: () => onCardSelected?.call(card.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.red
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    SmallTransactionCard(card: card),
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          // Обычный режим — drag & drop
          return LongPressDraggable<KanbanDragData>(
            data: KanbanDragData(
              cardId: card.id,
              fromColumnId: column.id,
            ),
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 200,
                child: SmallTransactionCard(card: card, dragging: true),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.35,
              child: SmallTransactionCard(card: card),
            ),
            child: SmallTransactionCard(card: card),
          );
        }),

        if (!column.isSystem)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: KanbanUiColors.textMuted,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.15),
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
                  color: Theme.of(context)
                      .extension<AppThemeColors>()!
                      .text
                      .withOpacity(0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Column Header ────────────────────────────────────────────────────────────
class _ColumnHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;
  final double totalAmount;
  final bool isSystem;

  const _ColumnHeader({
    required this.title,
    required this.count,
    required this.totalAmount,
    required this.onTap,
    required this.isSystem,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Column Menu Sheet ────────────────────────────────────────────────────────
class _ColumnMenuSheet extends StatefulWidget {
  final KanbanColumnModel column;
  final ValueChanged<String> onEdit;
  final VoidCallback onDelete;

  const _ColumnMenuSheet({
    required this.column,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ColumnMenuSheet> createState() => _ColumnMenuSheetState();
}

class _ColumnMenuSheetState extends State<_ColumnMenuSheet> {
  bool _showEditField = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.column.title);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color:colors.text.withOpacity(0.5),width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.column.title,
                style: AppFonts.mulish.s18w700(color: colors.text)),
          ),
          const SizedBox(height: 16),
          if (_showEditField) ...[
            TextField(
              controller: _controller,
              autofocus: true,
              style:AppFonts.mulish.s14w400(color: colors.text),
              cursorColor: KanbanUiColors.blue,
              decoration: InputDecoration(
                hintText: 'Новое название',
                hintStyle:
                kanbanText(size: 14, color: KanbanUiColors.textMuted),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.text.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KanbanUiColors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final newTitle = _controller.text.trim();
                  if (newTitle.isNotEmpty) widget.onEdit(newTitle);
                },
                child: Text('Сохранить',
                    style: AppFonts.mulish.s14w700(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: KanbanUiColors.textMuted,
                  side: BorderSide(color: KanbanUiColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => setState(() => _showEditField = false),
                child: Text('Отмена',
                    style:
                    kanbanText(size: 14, color: KanbanUiColors.textMuted)),
              ),
            ),
          ] else ...[
            if (!widget.column.isSystem) ...[
              _MenuButton(
                icon: Icons.edit_outlined,
                label: 'Переименовать',
                color: KanbanUiColors.blue,
                onTap: () => setState(() => _showEditField = true),
              ),
              const SizedBox(height: 10),
              _MenuButton(
                icon: Icons.delete_outline,
                label: 'Удалить колонку',
                color: KanbanUiColors.red,
                onTap: () => _confirmDelete(context),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KanbanUiColors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: KanbanUiColors.blue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: KanbanUiColors.blue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Системная колонка — нельзя переименовать или удалить',
                        style:
                        kanbanText(size: 13, color: KanbanUiColors.textDim),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KanbanUiColors.textMuted,
                    side: BorderSide(color: KanbanUiColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Закрыть',
                      style: kanbanText(
                          size: 14, color: KanbanUiColors.textMuted)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => AlertDialog(
        backgroundColor: KanbanUiColors.bgCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Удалить колонку?',
            style: kanbanText(size: 17, weight: FontWeight.w700)),
        content: Text(
          'Колонка «${widget.column.title}» и все её карточки будут удалены.',
          style: kanbanText(size: 13, color: KanbanUiColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Отмена',
                style: kanbanText(size: 14, color: KanbanUiColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KanbanUiColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete();
            },
            child:
            Text('Удалить', style: kanbanText(size: 14, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: kanbanText(
                      size: 14,
                      color: color,
                      weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}