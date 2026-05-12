import 'package:flutter/material.dart';

import '../../data/models/kanban_board_models.dart';
import 'kanban_column_widget.dart';
import 'kanban_theme.dart';

class BoardView extends StatefulWidget {
  final VoidCallback onBack;

  const BoardView({
    super.key,
    required this.onBack,
  });

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  static const double _columnWidth = 280;
  static const double _columnSpacing = 12;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newColumnController = TextEditingController();

  late List<KanbanColumnModel> _columns;

  double _scale = 1;
  int _currentColumnIndex = 0;
  String? _dragTargetId;
  bool _showAddColumn = false;

  bool get _isZoomed => _scale < 1;

  @override
  void initState() {
    super.initState();
    _columns = initialKanbanColumns();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newColumnController.dispose();
    super.dispose();
  }

  void _scrollToColumn(int index) {
    setState(() => _currentColumnIndex = index);

    final target = index * (_columnWidth + _columnSpacing);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    final index = (_scrollController.offset / (_columnWidth + _columnSpacing))
        .round()
        .clamp(0, _columns.length);
    if (index != _currentColumnIndex) {
      setState(() => _currentColumnIndex = index);
    }
  }

  void _moveCard(KanbanDragData data, String targetColumnId) {
    if (data.fromColumnId == targetColumnId) return;

    final fromColumn = _columns.firstWhere((c) => c.id == data.fromColumnId);
    final card = fromColumn.cards.firstWhere((c) => c.id == data.cardId);

    setState(() {
      _columns = _columns.map((column) {
        if (column.id == data.fromColumnId) {
          return column.copyWith(
            cards: column.cards.where((c) => c.id != data.cardId).toList(),
          );
        }

        if (column.id == targetColumnId) {
          return column.copyWith(
            cards: [
              ...column.cards,
              card.copyWith(columnId: targetColumnId),
            ],
          );
        }

        return column;
      }).toList();

      _dragTargetId = null;
    });
  }

  void _addColumn() {
    final title = _newColumnController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _columns = [
        ..._columns,
        KanbanColumnModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          isSystem: false,
          cards: const [],
        ),
      ];
      _newColumnController.clear();
      _showAddColumn = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToColumn(_columns.length - 1);
    });
  }

  void _showAddCardInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Тут можно открыть твой bottom sheet выбора транзакции'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalDots = _columns.length + 1;

    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      child: Column(
        children: [
          _BoardHeader(
            isZoomed: _isZoomed,
            onBack: widget.onBack,
            onToggleZoom: () {
              setState(() {
                _scale = _isZoomed ? 1 : 0.65;
              });
            },
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  _onScroll();
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Transform.scale(
                  scale: _scale,
                  alignment: Alignment.topLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._columns.map(
                        (column) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: _columnSpacing,
                            ),
                            child: SizedBox(
                              width: _columnWidth,
                              height: double.infinity,
                              child: KanbanColumnWidget(
                                column: column,
                                isDragTarget: _dragTargetId == column.id,
                                onDragHover: (columnId) {
                                  setState(() {
                                    _dragTargetId = columnId;
                                  });
                                },
                                onCardDropped: (data) {
                                  _moveCard(data, column.id);
                                },
                                onAddCard: _showAddCardInfo,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: _columnWidth,
                        child: _AddColumnCard(
                          showForm: _showAddColumn,
                          controller: _newColumnController,
                          onOpen: () {
                            setState(() {
                              _showAddColumn = true;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToColumn(_columns.length);
                            });
                          },
                          onCancel: () {
                            setState(() {
                              _showAddColumn = false;
                              _newColumnController.clear();
                            });
                          },
                          onAdd: _addColumn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _DotsIndicator(
            total: totalDots,
            currentIndex: _currentColumnIndex,
            onTap: _scrollToColumn,
          ),
        ],
      ),
    );
  }
}

class _BoardHeader extends StatelessWidget {
  final bool isZoomed;
  final VoidCallback onBack;
  final VoidCallback onToggleZoom;

  const _BoardHeader({
    required this.isZoomed,
    required this.onBack,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доска мая',
                  style: kanbanText(
                    size: 18,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Разбор расходов за месяц',
                  style: kanbanText(
                    size: 12,
                    color: KanbanUiColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggleZoom,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isZoomed
                    ? KanbanUiColors.blue
                    : Colors.white.withOpacity(0.07),
                border: Border.all(color: KanbanUiColors.border),
              ),
              child: Text(
                isZoomed ? '⊕' : '⊖',
                style: kanbanText(size: 18, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddColumnCard extends StatelessWidget {
  final bool showForm;
  final TextEditingController controller;
  final VoidCallback onOpen;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const _AddColumnCard({
    required this.showForm,
    required this.controller,
    required this.onOpen,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (!showForm) {
      return SizedBox(
        height: 72,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: KanbanUiColors.textMuted,
            side: BorderSide(color: Colors.white.withOpacity(0.18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white.withOpacity(0.04),
          ),
          onPressed: onOpen,
          child: Text(
            '+ Добавить колонку',
            style: kanbanText(
              size: 14,
              weight: FontWeight.w600,
              color: KanbanUiColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KanbanUiColors.bgColumn,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KanbanUiColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Название колонки',
              style: kanbanText(
                size: 13,
                color: KanbanUiColors.textDim,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            autofocus: true,
            style: kanbanText(size: 14),
            cursorColor: KanbanUiColors.blue,
            decoration: InputDecoration(
              hintText: 'Например: Транспорт',
              hintStyle: kanbanText(
                size: 14,
                color: KanbanUiColors.textMuted,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: KanbanUiColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: KanbanUiColors.blue),
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KanbanUiColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onAdd,
                  child: Text(
                    'Добавить',
                    style: kanbanText(size: 13, weight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KanbanUiColors.textMuted,
                    side: BorderSide(color: KanbanUiColors.border),
                    backgroundColor: Colors.white.withOpacity(0.07),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onCancel,
                  child: Text(
                    'Отмена',
                    style: kanbanText(
                      size: 13,
                      color: KanbanUiColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int total;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DotsIndicator({
    required this.total,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) {
            final isActive = currentIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? 22 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                decoration: BoxDecoration(
                  color: isActive
                      ? KanbanUiColors.blue
                      : Colors.white.withOpacity(index == total - 1 ? 0.12 : 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}