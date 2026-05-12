import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';
import 'small_transaction_card.dart';

// ─── Callbacks typedef ────────────────────────────────────────────────────────
typedef OnEditColumn = void Function(String columnId, String currentTitle);
typedef OnDeleteColumn = void Function(String columnId);

class KanbanColumnWidget extends StatelessWidget {
  final KanbanColumnModel column;
  final bool isDragTarget;
  final VoidCallback onAddCard;
  final ValueChanged<KanbanDragData> onCardDropped;
  final ValueChanged<String> onDragHover;

  /// Вызывается когда пользователь хочет переименовать колонку
  final OnEditColumn? onEditColumn;

  /// Вызывается когда пользователь хочет удалить колонку
  final OnDeleteColumn? onDeleteColumn;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.isDragTarget,
    required this.onAddCard,
    required this.onCardDropped,
    required this.onDragHover,
    this.onEditColumn,
    this.onDeleteColumn,
  });

  // ─── Открыть bottom sheet с действиями ───────────────────────────────────
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
          // ✅ Убрали maxHeight: 150 — теперь колонка растягивается по содержимому
          // но ограничена родительским SizedBox (высота доски)
          decoration: BoxDecoration(
            color: isDragTarget
                ? KanbanUiColors.blue.withOpacity(0.08)
                : colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
              isDragTarget ? KanbanUiColors.blue : KanbanUiColors.border,
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
            mainAxisSize: MainAxisSize.min, // ✅ колонка сжимается по содержимому
            children: [
              // ─── Header ──────────────────────────────────────────────────
              _ColumnHeader(
                title: column.title,
                count: column.cards.length,
                totalAmount: totalAmount,
                isSystem: column.isSystem,
                onTap: () => _showColumnMenu(context),
              ),

              // ─── Cards list ───────────────────────────────────────────────
              // ✅ Если карточек > 5 — добавляем ограничение и скролл
              if (column.cards.length > 5)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: _CardsList(
                    column: column,
                    onAddCard: onAddCard,
                  ),
                )
              else
                _CardsList(
                  column: column,
                  onAddCard: onAddCard,
                  shrinkWrap: true,
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Cards list (отдельный виджет для переиспользования) ─────────────────────
class _CardsList extends StatelessWidget {
  final KanbanColumnModel column;
  final VoidCallback onAddCard;
  final bool shrinkWrap;

  const _CardsList({
    required this.column,
    required this.onAddCard,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return ListView(
      shrinkWrap: shrinkWrap,
      // ✅ Если shrinkWrap=true, скролл не нужен (мало карточек)
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

        // ─── Кнопка «+ Добавить карточку» (только для не системных колонок) ───
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
                  color: Theme.of(context).extension<AppThemeColors>()!.text.withOpacity(0.5),
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
              // ✅ Показываем меню только для не системных колонок
              // Для системных — только просмотр
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

// ─── Column Menu Bottom Sheet ─────────────────────────────────────────────────
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
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
      ),
      decoration: BoxDecoration(
        color: KanbanUiColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: KanbanUiColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.column.title,
              style: kanbanText(size: 18, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Edit field (появляется по нажатию на «Переименовать») ───
          if (_showEditField) ...[
            TextField(
              controller: _controller,
              autofocus: true,
              style: kanbanText(size: 14),
              cursorColor: KanbanUiColors.blue,
              decoration: InputDecoration(
                hintText: 'Новое название',
                hintStyle: kanbanText(
                  size: 14,
                  color: KanbanUiColors.textMuted,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: KanbanUiColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: KanbanUiColors.blue),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final newTitle = _controller.text.trim();
                  if (newTitle.isNotEmpty) {
                    widget.onEdit(newTitle);
                  }
                },
                child: Text(
                  'Сохранить',
                  style: kanbanText(size: 14, weight: FontWeight.w700),
                ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => setState(() => _showEditField = false),
                child: Text(
                  'Отмена',
                  style:
                  kanbanText(size: 14, color: KanbanUiColors.textMuted),
                ),
              ),
            ),
          ] else ...[
            // ─── Кнопка «Переименовать» ───────────────────────────────
            if (!widget.column.isSystem) ...[
              _MenuButton(
                icon: Icons.edit_outlined,
                label: 'Переименовать',
                color: KanbanUiColors.blue,
                onTap: () => setState(() => _showEditField = true),
              ),
              const SizedBox(height: 10),
            ],

            // ─── Кнопка «Удалить» (только для не системных) ──────────
            if (!widget.column.isSystem) ...[
              _MenuButton(
                icon: Icons.delete_outline,
                label: 'Удалить колонку',
                color: KanbanUiColors.red,
                onTap: () => _confirmDelete(context),
              ),
            ] else ...[
              // Для системной колонки — только информация
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KanbanUiColors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: KanbanUiColors.blue.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: KanbanUiColors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Системная колонка — нельзя переименовать или удалить',
                        style: kanbanText(
                          size: 13,
                          color: KanbanUiColors.textDim,
                        ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Закрыть',
                    style: kanbanText(
                        size: 14, color: KanbanUiColors.textMuted),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ─── Диалог подтверждения удаления ───────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => AlertDialog(
        backgroundColor: KanbanUiColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Удалить колонку?',
          style: kanbanText(size: 17, weight: FontWeight.w700),
        ),
        content: Text(
          'Колонка «${widget.column.title}» и все её карточки будут удалены. Это действие нельзя отменить.',
          style: kanbanText(size: 13, color: KanbanUiColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Отмена',
              style: kanbanText(size: 14, color: KanbanUiColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KanbanUiColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete();
            },
            child: Text(
              'Удалить',
              style: kanbanText(size: 14, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Кнопка меню ─────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: kanbanText(size: 14, color: color, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}