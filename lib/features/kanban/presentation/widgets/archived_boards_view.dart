import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';

class ArchivedBoardsView extends StatelessWidget {
  final VoidCallback onBack;

  const ArchivedBoardsView({
    super.key,
    required this.onBack,
  });

  void _showArchivedDialog(
    BuildContext context,
    ArchivedBoardModel board,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          decoration: BoxDecoration(
            color: KanbanUiColors.bgCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22),
            ),
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
                  style: kanbanText(
                    size: 20,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Эта доска закрыта. Все данные сохранены, но редактирование недоступно. Вы можете просмотреть транзакции за ${board.month}.',
                style: kanbanText(
                  size: 14,
                  color: KanbanUiColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: KanbanUiColors.red.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: KanbanUiColors.red.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: KanbanUiColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Доска архивирована и доступна только для чтения',
                        style: kanbanText(
                          size: 13,
                          color: const Color(0xFFFF7A7A),
                        ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Понятно',
                    style: kanbanText(
                      size: 15,
                      weight: FontWeight.w700,
                    ),
                  ),
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
    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: KanbanUiColors.border),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: KanbanUiColors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Архивированные',
                  style: kanbanText(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
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
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: KanbanUiColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.folder_outlined,
                              color: KanbanUiColors.text,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  board.title,
                                  style: kanbanText(
                                    size: 15,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  board.month,
                                  style: kanbanText(
                                    size: 12,
                                    color: KanbanUiColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Закрыта',
                            style: kanbanText(
                              size: 12,
                              color: KanbanUiColors.textMuted,
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
        ],
      ),
    );
  }
}