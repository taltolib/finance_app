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
  static const double _boardPadding = 16;

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
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTransactionsToUnsorted();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _newColumnController.dispose();
    super.dispose();
  }

  // ─── Синхронизация расходов текущего месяца в «Неразобранные» ─────────────
  void _syncTransactionsToUnsorted() {
    if (!mounted) return;

    final kanbanProvider = context.read<KanbanProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final unsortedIndex =
        kanbanProvider.columns.indexWhere((c) => c.id == 'unsorted');
    if (unsortedIndex == -1) return;

    // Важно: проверяем все колонки, а не только «Неразобранные».
    // Иначе пользователь перетащит карточку в «Еда», а мы, как очень умная
    // машина хаоса, вернём её обратно в «Неразобранные» при следующем билде.
    final existingTransactionIds = kanbanProvider.columns
        .expand((column) => column.cards)
        .where((card) => card.transactionId != null)
        .map((card) => card.transactionId!)
        .toSet();

    final expenseTransactions = transactionProvider.currentMonthTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .toList();

    for (final tx in expenseTransactions) {
      if (existingTransactionIds.contains(tx.id)) continue;

      final card = KanbanCard(
        id: 'tx_${tx.id}',
        transactionId: tx.id,
        cardColor: const Color(0xFF1C1C1E),
        note: tx.location,
        status: 'Неразобранное',
        createdAt: tx.dateTime,
      );
      kanbanProvider.addCardToColumn('unsorted', card);
      existingTransactionIds.add(tx.id);
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
          .map((card) => _mapCardToModel(card, transactionProvider, column.id))
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

  void _scrollToColumn(int index) {
    final kanbanProvider = context.read<KanbanProvider>();
    final totalItems = kanbanProvider.columns.length + 1;
    final safeIndex = index.clamp(0, totalItems - 1);

    setState(() => _currentColumnIndex = safeIndex);

    final target = safeIndex * (_columnWidth + _columnSpacing) * _scale;
    final maxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : target;

    _scrollController.animateTo(
      target.clamp(0, maxExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final kanbanProvider = context.read<KanbanProvider>();
    final totalItems = kanbanProvider.columns.length + 1;
    final rawIndex = _scrollController.offset /
        ((_columnWidth + _columnSpacing) * _scale).clamp(1, double.infinity);
    final index = rawIndex.round().clamp(0, totalItems - 1);

    if (index != _currentColumnIndex) {
      setState(() => _currentColumnIndex = index);
    }
  }

  void _addColumn() {
    final title = _newColumnController.text.trim();
    if (title.isEmpty) return;

    context.read<KanbanProvider>().addColumn(title, const Color(0xFF1C1C1E));
    _newColumnController.clear();
    setState(() => _showAddColumn = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colCount = context.read<KanbanProvider>().columns.length;
      _scrollToColumn(colCount);
    });
  }

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

  void _toggleZoom() {
    final nextScale = _isZoomed ? 1.0 : 0.62;
    setState(() => _scale = nextScale);

    // После изменения масштаба пересчитываем позицию скролла, чтобы индикатор
    // и видимая колонка не жили каждый в своей вселенной, как это любят UI-баги.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToColumn(_currentColumnIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final columns = kanbanProvider.columns;
    final totalItems = columns.length + 1;
    final totalDots = totalItems;

    // Если транзакции загрузились после первого кадра, всё равно докидываем
    // расходы месяца в «Неразобранные». Без дублей и без возврата уже
    // перетащенных карточек.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTransactionsToUnsorted();
    });

    return Container(
      color: KanbanUiColors.bg.withOpacity(0.72),
      child: Column(
        children: [
          _BoardHeader(
            isZoomed: _isZoomed,
            onBack: widget.onBack,
            onToggleZoom: _toggleZoom,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boardHeight =
                    (constraints.maxHeight - (_boardPadding * 2)).clamp(260.0, double.infinity);
                final contentWidth =
                    (totalItems * _columnWidth) + ((totalItems - 1) * _columnSpacing);

                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(_boardPadding),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: contentWidth * _scale,
                    height: boardHeight * _scale,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: contentWidth,
                        maxWidth: contentWidth,
                        minHeight: boardHeight,
                        maxHeight: boardHeight,
                        child: Transform.scale(
                          scale: _scale,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: contentWidth,
                            height: boardHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...columns.map((column) {
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
                                      height: boardHeight,
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
                                        onEditColumn: (columnId, currentTitle) {
                                          _showRenameDialog(
                                            context,
                                            columnId,
                                            currentTitle,
                                          );
                                        },
                                        onDeleteColumn: (columnId) {
                                          kanbanProvider.deleteColumn(columnId);
                                        },
                                      ),
                                    ),
                                  );
                                }),
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
                  ),
                );
              },
            ),
          ),
          _DotsIndicator(
            total: totalDots,
            currentIndex: _currentColumnIndex.clamp(0, totalDots - 1),
            onTap: _scrollToColumn,
          ),
        ],
      ),
    );
  }

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
                  isZoomed
                      ? 'Обзор доски: все колонки уменьшены'
                      : 'Разбор расходов за месяц',
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

class _AddCardBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onCardAdded;

  const _AddCardBottomSheet({
    required this.transactions,
    required this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
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
                          style: kanbanText(
                            size: 14,
                            color: KanbanUiColors.textMuted,
                          ),
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
                                style: kanbanText(
                                  size: 14,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${tx.amount.toStringAsFixed(0)} UZS',
                                style: kanbanText(
                                  size: 12,
                                  color: tx.type == TransactionType.expense
                                      ? KanbanUiColors.red
                                      : KanbanUiColors.blue,
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
      ),
    );
  }
}
