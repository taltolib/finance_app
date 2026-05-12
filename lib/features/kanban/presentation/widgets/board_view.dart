import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/transactions/data/models/transaction.dart';
import '../../../../features/transactions/presentation/providers/transaction_provider.dart';
import '../../data/models/kanban_board_models.dart';
import '../../data/models/kanban_model.dart' show KanbanCard, KanbanColumn;
import '../providers/kanban_provider.dart';
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

  double _scale = 1;
  int _currentColumnIndex = 0;
  String? _dragTargetId;
  bool _showAddColumn = false;

  bool get _isZoomed => _scale < 1;

  @override
  void initState() {
    super.initState();
    // ✅ После первой отрисовки — загружаем транзакции в «Неразобранные»
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTransactionsToUnsorted();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newColumnController.dispose();
    super.dispose();
  }

  // ─── Синхронизация транзакций текущего месяца в «Неразобранные» ──────────
  void _syncTransactionsToUnsorted() {
    if (!mounted) return;

    final kanbanProvider = context.read<KanbanProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    // Найти колонку «Неразобранные»
    final unsortedIndex =
    kanbanProvider.columns.indexWhere((c) => c.id == 'unsorted');
    if (unsortedIndex == -1) return;

    final unsortedColumn = kanbanProvider.columns[unsortedIndex];

    // Получить транзакции текущего месяца
    final monthlyTransactions =
        transactionProvider.currentMonthTransactions;

    // Найти транзакции которых ещё нет в колонке
    final existingTransactionIds = unsortedColumn.cards
        .where((c) => c.transactionId != null)
        .map((c) => c.transactionId!)
        .toSet();

    // Добавить все карточки которых нет
    for (final tx in monthlyTransactions) {
      if (!existingTransactionIds.contains(tx.id)) {
        final card = KanbanCard(
          id: 'tx_${tx.id}',
          transactionId: tx.id,
          cardColor: const Color(0xFF1C1C1E),
          note: tx.location,
          status: 'Неразобранное',
          createdAt: tx.dateTime,
        );
        // Добавить без повторного сохранения если уже есть
        kanbanProvider.addCardToColumn('unsorted', card);
      }
    }
  }

  // ─── Map KanbanColumn → KanbanColumnModel для виджета ────────────────────
  KanbanColumnModel _mapColumnToModel(
      KanbanColumn column,
      TransactionProvider transactionProvider,
      ) {
    return KanbanColumnModel(
      id: column.id,
      title: column.title,
      isSystem: column.id == 'unsorted',
      cards: column.cards
          .map((card) =>
          _mapCardToModel(card, transactionProvider, column.id))
          .toList(),
    );
  }

  KanbanCardModel _mapCardToModel(
      KanbanCard card,
      TransactionProvider transactionProvider,
      String columnId,
      ) {
    Transaction? transaction;
    if (card.transactionId != null) {
      for (final item in transactionProvider.transactions) {
        if (item.id == card.transactionId) {
          transaction = item;
          break;
        }
      }
    }

    return KanbanCardModel(
      id: card.id,
      place: transaction?.location ?? card.note ?? 'Карточка',
      amount: transaction?.amount ?? 0,
      date: _formatDate(transaction?.dateTime ?? card.createdAt),
      columnId: columnId,
    );
  }

  String _formatDate(DateTime dateTime) {
    const monthNames = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = monthNames[dateTime.month];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month в $hour:$minute';
  }

  // ─── Скролл к колонке ─────────────────────────────────────────────────────
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
    final kanbanProvider = context.read<KanbanProvider>();
    final index =
    (_scrollController.offset / (_columnWidth + _columnSpacing))
        .round()
        .clamp(0, kanbanProvider.columns.length);
    if (index != _currentColumnIndex) {
      setState(() => _currentColumnIndex = index);
    }
  }

  // ─── Добавить колонку ─────────────────────────────────────────────────────
  void _addColumn() {
    final title = _newColumnController.text.trim();
    if (title.isEmpty) return;

    context
        .read<KanbanProvider>()
        .addColumn(title, const Color(0xFF1C1C1E));
    _newColumnController.clear();
    setState(() => _showAddColumn = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colCount = context.read<KanbanProvider>().columns.length;
      _scrollToColumn(colCount - 1);
    });
  }

  // ─── Добавить карточку ────────────────────────────────────────────────────
  void _addCardToColumn(KanbanColumn column) {
    final transactionProvider = context.read<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCardBottomSheet(
        transactions: transactions,
        onCardAdded: (tx) {
          final card = KanbanCard(
            id: 'tx_${tx.id}_${DateTime.now().millisecondsSinceEpoch}',
            transactionId: tx.id,
            cardColor: const Color(0xFF1C1C1E),
            note: tx.location,
            status: 'Новое',
            createdAt: DateTime.now(),
          );
          context.read<KanbanProvider>().addCardToColumn(column.id, card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final columns = kanbanProvider.columns;
    final totalDots = columns.length + 1; // +1 для кнопки «Добавить»

    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      child: Column(
        children: [
          // ─── Header ────────────────────────────────────────────────────
          _BoardHeader(
            isZoomed: _isZoomed,
            onBack: widget.onBack,
            onToggleZoom: () {
              setState(() {
                _scale = _isZoomed ? 1 : 0.65;
              });
            },
          ),

          // ─── Board (горизонтальный скролл) ────────────────────────────
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
                      // ─── Колонки ───────────────────────────────────────
                      ...columns.map(
                            (column) {
                          final model = _mapColumnToModel(
                            column,
                            transactionProvider,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: _columnSpacing,
                            ),
                            child: SizedBox(
                              width: _columnWidth,
                              // ✅ Убрали фиксированный height — колонка
                              // растягивается по содержимому
                              child: KanbanColumnWidget(
                                column: model,
                                isDragTarget: _dragTargetId == column.id,
                                onDragHover: (columnId) {
                                  setState(() {
                                    _dragTargetId = columnId;
                                  });
                                },
                                onCardDropped: (data) {
                                  kanbanProvider.moveCard(
                                    data.cardId,
                                    data.fromColumnId,
                                    column.id,
                                  );
                                  setState(() => _dragTargetId = null);
                                },
                                onAddCard: () => _addCardToColumn(column),
                                // ✅ Переименование
                                onEditColumn: (columnId, currentTitle) {
                                  _showRenameDialog(context, columnId, currentTitle);
                                },
                                // ✅ Удаление
                                onDeleteColumn: (columnId) {
                                  kanbanProvider.deleteColumn(columnId);
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      // ─── Кнопка «+ Добавить колонку» ──────────────────
                      SizedBox(
                        width: _columnWidth,
                        child: _AddColumnCard(
                          showForm: _showAddColumn,
                          controller: _newColumnController,
                          onOpen: () {
                            setState(() => _showAddColumn = true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToColumn(columns.length);
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

          // ─── Dots indicator ────────────────────────────────────────────
          _DotsIndicator(
            total: totalDots,
            currentIndex: _currentColumnIndex,
            onTap: _scrollToColumn,
          ),
        ],
      ),
    );
  }

  // ─── Диалог переименования ────────────────────────────────────────────────
  void _showRenameDialog(
      BuildContext context,
      String columnId,
      String currentTitle,
      ) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => AlertDialog(
        backgroundColor: KanbanUiColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Переименовать колонку',
          style: kanbanText(size: 17, weight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: kanbanText(size: 14),
          cursorColor: KanbanUiColors.blue,
          decoration: InputDecoration(
            hintText: 'Название колонки',
            hintStyle: kanbanText(size: 14, color: KanbanUiColors.textMuted),
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
              backgroundColor: KanbanUiColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                context.read<KanbanProvider>().renameColumn(columnId, newTitle);
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'Сохранить',
              style: kanbanText(size: 14, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

// ─── Board Header ─────────────────────────────────────────────────────────────
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
    final now = DateTime.now();
    const months = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    final monthName = months[now.month];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: KanbanUiColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back, color: KanbanUiColors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доска $monthName',
                  style: kanbanText(size: 18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Разбор расходов за месяц',
                  style: kanbanText(size: 12, color: KanbanUiColors.textMuted),
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

// ─── Add Column Card ──────────────────────────────────────────────────────────
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
              style: kanbanText(size: 13, color: KanbanUiColors.textDim),
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
              hintStyle: kanbanText(size: 14, color: KanbanUiColors.textMuted),
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
                    style: kanbanText(size: 13, color: KanbanUiColors.textMuted),
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

// ─── Dots Indicator ───────────────────────────────────────────────────────────
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
                      : Colors.white.withOpacity(
                    index == total - 1 ? 0.12 : 0.18,
                  ),
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

// ─── Add Card Bottom Sheet ────────────────────────────────────────────────────
class _AddCardBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onCardAdded;

  const _AddCardBottomSheet({
    required this.transactions,
    required this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: const BoxDecoration(
        color: KanbanUiColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Добавить транзакцию',
              style: kanbanText(size: 18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                child: Text(
                  'Нет транзакций за текущий месяц',
                  style:
                  kanbanText(size: 14, color: KanbanUiColors.textMuted),
                ),
              )
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        tx.location,
                        style: kanbanText(size: 14, weight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${tx.amount.toStringAsFixed(0)} UZS',
                        style: kanbanText(
                          size: 12,
                          color: KanbanUiColors.red,
                        ),
                      ),
                      onTap: () {
                        onCardAdded(tx);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}