import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../transactions/data/models/transaction.dart';
import '../providers/kanban_provider.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
import '../../data/models/kanban_model.dart' show KanbanColumn, KanbanCard;
import '../widgets/kanban_column.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  static const double _columnWidth = 280;
  static const double _columnSpacing = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KanbanProvider>().loadColumns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final colors =context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container()
                ),
                // Kanban board — horizontal scroll
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...kanbanProvider.columns.map(
                              (column) => Padding(
                            padding: const EdgeInsets.only(right: _columnSpacing),
                            child: SizedBox(
                              width: _columnWidth,
                              child: KanbanColumnWidget(
                                column: column,
                                onCardMoved: (card, toColumnId) {
                                  kanbanProvider.moveCard(
                                    card.id,
                                    column.id,
                                    toColumnId,
                                  );
                                },
                                onCardUpdated: (card) {
                                  kanbanProvider.updateCard(card, column.id);
                                },
                                onCardDeleted: kanbanProvider.deleteCard,
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
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  void _addCardToColumn(KanbanColumn column) {
    final transactionProvider = context.read<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    final List<dynamic> items;
    if (column.id == 'all') {
      items = transactions;
    } else if (column.id == 'income') {
      items = transactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    } else if (column.id == 'expense') {
      items = transactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    } else {
      items = ['Новая заметка'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCardBottomSheet(
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
          labelStyle:  const TextStyle(color: Colors.white54),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isEmpty) return;
            context.read<KanbanProvider>().addColumn(title, const Color(0xFF1C1C1E));
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

// ─── Add Card Bottom Sheet ────────────────────────────────────────────────────
class AddCardBottomSheet extends StatelessWidget  {
  final List<dynamic> items;
  final Function(dynamic) onCardAdded;

  const AddCardBottomSheet({
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
                        item is Transaction ? item.location : item.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: item is Transaction
                          ? Text(
                        '${item.amount.toStringAsFixed(0)} UZS',
                        style: const TextStyle(color: Colors.white54),
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
|--------------------------------------------------------------------------
| Screen responsibility
|--------------------------------------------------------------------------
| Screen: KanbanScreen
|
| Responsibility:
| - Shows the Kanban board for organizing transactions by columns/categories.
| - Allows users to create columns.
| - Allows users to add transactions or notes as Kanban cards.
| - Allows moving, updating and deleting cards through KanbanProvider.
|
| This screen must NOT:
| - Parse raw bank messages.
| - Work directly with local database.
| - Contain transaction analytics calculations.
| - Contain Share Intent import logic.
|--------------------------------------------------------------------------
*/