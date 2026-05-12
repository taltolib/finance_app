import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../share_import/data/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/kanban_provider.dart';
import '../widgets/kanban_column_widget.dart';
import '../../data/models/kanban_board_models.dart';
import '../../data/models/kanban_model.dart' show KanbanColumn, KanbanCard;

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State {
  static const double _columnWidth = 280;
  static const double _columnSpacing = 12;
  static const double _boardPadding = 16;

  String? _dragTargetId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KanbanProvider>().loadColumns();
      _syncTransactionsToUnsorted();
    });
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newColumnController = TextEditingController();

  double _scale = 1;
  int _currentColumnIndex = 0;

  bool _deleteMode = false;
  final Set _selectedCardIds = {};

  bool get _isZoomed => _scale < 1;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _newColumnController.dispose();
    super.dispose();
  }

  void _syncTransactionsToUnsorted() {
    if (!mounted) return;
    final kanbanProvider = context.read();
    final transactionProvider = context.read();

    final unsortedIndex =
        kanbanProvider.columns.indexWhere((c) => c.id == 'unsorted');
    if (unsortedIndex == -1) return;

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
          transaction = item  ;
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
    final kanbanProvider = context.read();
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

  void _toggleZoom() {
    final nextScale = _isZoomed ? 1.0 : 0.62;
    setState(() => _scale = nextScale);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToColumn(_currentColumnIndex);
    });
  }

  void _toggleDeleteMode() {
    setState(() {
      _deleteMode = !_deleteMode;
      if (!_deleteMode) _selectedCardIds.clear();
    });
  }

  void _deleteSelectedCards() {
    final kanbanProvider = context.read();
    for (final cardId in _selectedCardIds) {
      kanbanProvider.deleteCard(cardId);
    }
    setState(() {
      _selectedCardIds.clear();
      _deleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch();
    final transactionProvider = context.watch();
    final colors = Theme.of(context).extension()!;
    final columns = kanbanProvider.columns;
    final totalItems = columns.length + 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTransactionsToUnsorted();
    });
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: context.pop,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Доска ${months[now.month]}',
              style: AppFonts.mulish.s18w700(color: colors.text),
            ),
          ],
        ),
        // ─── Кнопка зума (⊖/⊕) как на фото справа ───────────────────────
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _toggleZoom,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isZoomed
                      ? AppColors.blue
                      : Colors.white.withOpacity(0.07),
                  border: Border.all(color: AppColors.red),
                ),
                child: Icon(
                  _isZoomed ? Icons.zoom_in : Icons.zoom_out,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.blue.withOpacity(0.1)),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          colors == false
              ? Positioned.fill(
                  child: Image.asset(
                    'assets/images/kanban_bg.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Positioned.fill(
                  child: Image.asset(
                    'assets/images/kanban_bg_dark.png',
                    fit: BoxFit.cover,
                  ),
                ),
          // Subtle dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container()),
                // Kanban board — horizontal scroll
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...kanbanProvider.columns.map(
                        (column) => Padding(
                          padding: const EdgeInsets.only(right: _columnSpacing),
                          child: SizedBox(
                            width: _columnWidth,
                            child: KanbanColumnWidget(
                              column: _mapColumnToModel(
                                  column, transactionProvider),
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
                              },
                              onAddCard: () => _addCardToColumn(column),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 70,
                        width: _columnWidth,
                        child: GestureDetector(
                          onTap: _addColumn,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '+ Добавить список',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) => const AddColumnDialog(),
    );
  }

  KanbanColumnModel _mapColumnToModel(
      KanbanColumn column, TransactionProvider transactionProvider) {
    return KanbanColumnModel(
      id: column.id,
      title: column.title,
      isSystem: false,
      cards: column.card
          .map((card) => _mapCardToModel(card, transactionProvider, column.id))
          .toList(),
    );
  }

  KanbanCardModel _mapCardToModel(KanbanCard card,
      TransactionProvider transactionProvider, String columnId) {
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

  void _addCardToColumn(KanbanColumn column) {
    final transactionProvider = context.read();
    final transactions = transactionProvider.transactions;

    final List<dynamic> items;
    if (column.id == 'all') {
      items = transactions;
    } else if (column.id == 'income') {
      items =
          transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (column.id == 'expense') {
      items =
          transactions.where((t) => t.type == TransactionType.expense).toList();
    } else {
      items = ['Новая заметка'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCardBottomSheets(
        items: items,
        onCardAdded: (item) {
          final card = KanbanCard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            transactionId: item is Transaction ? item.id : null,
            cardColor: const Color(0xFF1C1C1E),
            note: item is String ? item : null,
            status: 'Новая',
            createdAt: DateTime.now(),
          );
          context.read<KanbanProvider>().addCardToColumn(column.id, card);
        },
      ),
    );
  }
}

class AddColumnDialog extends StatefulWidget {
  const AddColumnDialog({super.key});

  @override
  State createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Новый список', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Название',
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            context.read().addColumn(title, const Color(0xFF1C1C1E));
            Navigator.of(context).pop();
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//─── Add Card Bottom Sheet ────────────────────────────────────────────────────
class AddCardBottomSheets extends StatelessWidget {
  final List items;
  final Function(dynamic) onCardAdded;

  const AddCardBottomSheets({
    super.key,
    required this.items,
    required this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Добавить карточку',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Нет доступных элементов',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              item
                                  ? item.location
                                  : item.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: item is Transaction
                                ? Text(
                                    '${item.amount.toStringAsFixed(0)} UZS',
                                    style:
                                        const TextStyle(color: Colors.white54),
                                  )
                                : null,
                            onTap: () {
                              onCardAdded(item);
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

/*

Screen responsibility

--------------------------------------------------------------------------

Screen: KanbanScreen



Responsibility:

- Shows the Kanban board for organizing transactions by columns/categories.

- Allows users to create columns.

- Allows users to add transactions or notes as Kanban cards.

- Allows moving, updating and deleting cards through KanbanProvider.



This screen must NOT:

- Parse raw bank messages.

- Work directly with local database.

- Contain transaction analytics calculations.

- Contain Share Intent import logic.

--------------------------------------------------------------------------

*/
