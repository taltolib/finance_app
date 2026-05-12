import 'package:flutter/material.dart';

 import '../../data/models/kanban_board_models.dart';
import 'kanban_theme.dart';

class BoardsHomeView extends StatelessWidget {
  final VoidCallback onOpenCurrent;
  final VoidCallback onOpenArchived;

  const BoardsHomeView({
    super.key,
    required this.onOpenCurrent,
    required this.onOpenArchived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Управление расходами',
            style: kanbanText(
              size: 11,
              weight: FontWeight.w700,
              color: KanbanUiColors.textMuted,
            ).copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            'Разбор расходов',
            style: kanbanText(
              size: 22,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Доски',
            style: kanbanText(
              size: 13,
              weight: FontWeight.w700,
              color: KanbanUiColors.textMuted,
            ).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          _BoardTile(
            title: 'Текущий месяц',
            subtitle: 'Май 2025 · Активна',
            icon: Icons.dashboard_customize_outlined,
            iconColor: KanbanUiColors.blue,
            borderColor: KanbanUiColors.borderActive,
            activeDot: true,
            onTap: onOpenCurrent,
          ),
          const SizedBox(height: 10),
          _BoardTile(
            title: 'Архивированные',
            subtitle: '${archivedBoards.length} досок · Закрытые',
            icon: Icons.inventory_2_outlined,
            iconColor: KanbanUiColors.textDim,
            borderColor: KanbanUiColors.border,
            showArrow: true,
            onTap: onOpenArchived,
          ),
          const SizedBox(height: 24),
          const _InfoCard(),
        ],
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final bool activeDot;
  final bool showArrow;
  final VoidCallback onTap;

  const _BoardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    this.activeDot = false,
    this.showArrow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KanbanUiColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: activeDot
                ? [
                    BoxShadow(
                      color: KanbanUiColors.blue.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: kanbanText(
                        size: 15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: kanbanText(
                        size: 12,
                        color: activeDot
                            ? KanbanUiColors.blue
                            : KanbanUiColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeDot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: KanbanUiColors.green,
                  ),
                ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: KanbanUiColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      'Все расходы месяца попадают в «Неразобранные» автоматически',
      'Перетащите карточку в нужную колонку',
      'Скролл → переход между колонками',
      'Кнопка ⊖ отдаляет доску для обзора',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: KanbanUiColors.blue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: KanbanUiColors.blue.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Как работает разбор',
            style: kanbanText(
              size: 12,
              weight: FontWeight.w700,
              color: KanbanUiColors.blue,
            ),
          ),
          const SizedBox(height: 6),
          ...items.indexed.map(
            (entry) {
              final index = entry.$1;
              final text = entry.$2;

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: kanbanText(
                        size: 12,
                        weight: FontWeight.w700,
                        color: KanbanUiColors.blue,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: kanbanText(
                          size: 12,
                          color: KanbanUiColors.textDim,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}