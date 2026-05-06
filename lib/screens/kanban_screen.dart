import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kanban_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/kanban_model.dart';
import '../models/transaction.dart';
import '../widgets/kanban_column.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanbanProvider>().loadColumns();
    });
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(0.5, 2.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.2).clamp(0.5, 2.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Канбан доска'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addColumn,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Transform.scale(
                scale: _scale,
                child: Row(
                  children: [
                    ...kanbanProvider.columns.map((column) => KanbanColumnWidget(
                      column: column,
                      onCardMoved: (card, toColumnId) {
                        kanbanProvider.moveCard(card.id, column.id, toColumnId);
                      },
                      onCardUpdated: kanbanProvider.updateCard,
                      onCardDeleted: kanbanProvider.deleteCard,
                      onAddCard: () => _addCardToColumn(column),
                    )),
                    // Add new column button
                    Container(
                      width: 280,
                      margin: const EdgeInsets.all(8),
                      child: Card(
                        child: InkWell(
                          onTap: _addColumn,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 48),
                                Text('+ Новый столбец'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Zoom controls
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: _zoomOut,
                ),
                Text('${(_scale * 100).round()}%'),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: _zoomIn,
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

    // Filter transactions based on column
    List<dynamic> items = [];
    if (column.id == 'all') {
      items = transactions;
    } else if (column.id == 'income') {
      items = transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (column.id == 'expense') {
      items = transactions.where((t) => t.type == TransactionType.expense).toList();
    } else {
      // For custom columns, allow adding notes
      items = ['Новая заметка'];
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => AddCardBottomSheet(
        items: items,
        onCardAdded: (item) {
          final card = KanbanCard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            transactionId: item is Transaction ? item.id : null,
            cardColor: Colors.blue,
            note: item is String ? item : null,
            status: 'Новая',
            createdAt: DateTime.now(),
          );
          context.read<KanbanProvider>().addCardToColumn(column.id, card);
        },
      ),
    );
  }

  void _showSettings() {
    // Placeholder for settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки канбана')),
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
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый столбец'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 16),
          // Simple color picker
          Wrap(
            children: [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
            ].map((color) => GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: _selectedColor == color
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              context.read<KanbanProvider>().addColumn(title, _selectedColor);
              Navigator.of(context).pop();
            }
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

class AddCardBottomSheet extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Выберите транзакцию или добавьте заметку',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item is Transaction ? item.location : item),
                  subtitle: item is Transaction
                      ? Text('${item.amount} UZS')
                      : null,
                  onTap: () {
                    onCardAdded(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}