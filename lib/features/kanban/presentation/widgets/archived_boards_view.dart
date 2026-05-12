import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';

class ArchivedBoardsView extends StatelessWidget {
  final VoidCallback onBack;

  const ArchivedBoardsView({
    super.key,
    required this.onBack,
  });

  void _showArchivedDialog(BuildContext context, ArchivedBoardModel board) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          decoration: BoxDecoration(
            color: KanbanUiColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: KanbanUiColors.border),
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
                child: Text(
                  board.title,
                  style: kanbanText(size: 20, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Эта доска закрыта. Все данные сохранены, но редактирование недоступно. '
                    'Вы можете просмотреть транзакции за ${board.month}.',
                style: kanbanText(
                  size: 14,
                  color: KanbanUiColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: KanbanUiColors.red.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KanbanUiColors.red.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: KanbanUiColors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Доска архивирована и доступна только для чтения',
                        style: kanbanText(
                            size: 13, color: const Color(0xFFFF7A7A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KanbanUiColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Понятно',
                      style: kanbanText(size: 15, weight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ─── AppBar с кнопкой назад ───────────────────────────────────────
      appBar: AppBar(
        backgroundColor: KanbanUiColors.bg.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KanbanUiColors.blue),
          onPressed: onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Архивированные',
              style: kanbanText(size: 17, weight: FontWeight.w700),
            ),
            Text(
              '${archivedBoards.length} досок · Закрытые',
              style: kanbanText(size: 11, color: KanbanUiColors.textMuted),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KanbanUiColors.border),
        ),
      ),
      body: Container(
        color: KanbanUiColors.bg.withOpacity(0.72),
        child: archivedBoards.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Colors.white.withOpacity(0.18),
              ),
              const SizedBox(height: 16),
              Text(
                'Нет архивированных досок',
                style: kanbanText(
                    size: 16, color: KanbanUiColors.textMuted),
              ),
            ],
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: archivedBoards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final board = archivedBoards[index];
            return Material(
              color: KanbanUiColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showArchivedDialog(context, board),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: KanbanUiColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.folder_outlined,
                            color: KanbanUiColors.text, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(board.title,
                                style: kanbanText(
                                    size: 15,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(board.month,
                                style: kanbanText(
                                    size: 12,
                                    color: KanbanUiColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Закрыта',
                          style: kanbanText(
                              size: 11,
                              color: KanbanUiColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}