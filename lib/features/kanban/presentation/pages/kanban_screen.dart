import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/providers/theme_provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../transactions/data/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/kanban_provider.dart';
import '../widgets/kanban_column_widget.dart';
import '../../data/models/kanban_board_models.dart';
import '../../data/models/kanban_model.dart' show KanbanColumn, KanbanCard;

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  static const double _columnWidth = 280;
  static const double _columnSpacing = 12;

  final ScrollController _scrollController = ScrollController();

  String? _dragTargetId;

  double _scale = 1;
  int _currentColumnIndex = 0;

  bool _deleteMode = false;
  final Set<String> _selectedCardIds = {};

  bool get _isZoomed => _scale < 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ВАЖНО:
      // Дизайн не трогаем.
      // Логику загрузки оставляем через KanbanProvider.
      // Если provider уже подключен к backend /kanban/current,
      // он сам загрузит колонки и карточки.
      context.read<KanbanProvider>().loadColumns();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  KanbanColumnModel _mapColumnToModel(
      KanbanColumn column,
      TransactionProvider transactionProvider,
      ) {
    final kanbanProvider = context.read<KanbanProvider>();

    return KanbanColumnModel(
      id: column.id,
      title: column.title,
      isSystem: column.id == kanbanProvider.uncategorizedColumnId,
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
      place: _transactionTitle(transaction, card),
      amount: transaction?.amount ?? 0,
      date: _formatDate(transaction?.dateTime ?? card.createdAt),
      columnId: columnId,
    );
  }

  String _transactionTitle(Transaction? transaction, KanbanCard card) {
    if (transaction == null) {
      return card.note ?? 'Карточка';
    }

    // Оставил совместимость со старым transaction.location.
    // Если в твоей новой модели location уже нет, замени эту строку на:
    // return transaction.merchant.isNotEmpty ? transaction.merchant : transaction.description;
    return transaction.location;
  }

  String _transactionBottomSheetTitle(Transaction transaction) {
    // Оставил совместимость со старым transaction.location.
    // Если в новой модели location нет, замени на merchant/description.
    return transaction.location;
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

  void _toggleZoom() {
    final nextScale = _isZoomed ? 1.0 : 0.62;

    setState(() => _scale = nextScale);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToColumn(_currentColumnIndex);
      }
    });
  }


  void _addColumn() {
    showDialog(
      context: context,
      builder: (_) => const AddColumnDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = context.watch<ThemeProvider>().isDark;

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
      'декабря',
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
         elevation: 0,
        leading: GestureDetector(
            onTap: context.pop,
            child: const Icon(Icons.arrow_back, color: AppColors.blue)
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
        actions: [
          // Кнопка обновления данных
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () async {
                await context.read<KanbanProvider>().loadColumns();
              },
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          // Кнопка zoom
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
      ),
      body: Stack(
        children: [
          // Фоновая картинка — всегда видна, без чёрного перекрытия
          Positioned.fill(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: Image.asset(
                isDark
                    ? 'assets/images/kanban_bg_dark.png'
                    : 'assets/images/kanban_bg.png',
                fit: BoxFit.cover,
                color: null,
                colorBlendMode: null,
                   ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(),
                ),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...kanbanProvider.columns.map(
                            (column) => Padding(
                          padding: const EdgeInsets.only(
                            right: _columnSpacing,
                          ),
                          child: SizedBox(
                            width: _columnWidth,
                            child: KanbanColumnWidget(
                              column: _mapColumnToModel(
                                column,
                                transactionProvider,
                              ),
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
                                setState(() {
                                  _dragTargetId = null;
                                });
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
                              vertical: 12,
                              horizontal: 12,
                            ),
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

  void _addCardToColumn(KanbanColumn column) {
    final transactionProvider = context.read<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    final List<dynamic> items;

    if (column.id == 'all') {
      items = transactions;
    } else if (column.id == 'income') {
      items = transactions
          .where((transaction) => transaction.type == TransactionType.income)
          .toList();
    } else if (column.id == 'expense') {
      items = transactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .toList();
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
  State<AddColumnDialog> createState() => _AddColumnDialogState();
}

class _AddColumnDialogState extends State<AddColumnDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Новый список',
        style: TextStyle(color: Colors.white),
      ),
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
          child: const Text(
            'Отмена',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            final title = _controller.text.trim();

            if (title.isEmpty) return;

            context.read<KanbanProvider>().addColumn(
              title,
              const Color(0xFF1C1C1E),
            );

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

class AddCardBottomSheets extends StatelessWidget {
  final List<dynamic> items;
  final void Function(dynamic item) onCardAdded;

  const AddCardBottomSheets({
    super.key,
    required this.items,
    required this.onCardAdded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration:  BoxDecoration(
        color:colors.background,
        borderRadius:  const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                        item is Transaction
                            ? item.location
                            : item.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: item is Transaction
                          ? Text(
                        '${item.amount.toStringAsFixed(0)} UZS',
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
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