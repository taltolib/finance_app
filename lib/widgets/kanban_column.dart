import 'package:flutter/material.dart';
import '../models/kanban_model.dart';
import '../widgets/kanban_card.dart';

class KanbanColumnWidget extends StatefulWidget {
  final KanbanColumn column;
  final Function(KanbanCard, String) onCardMoved;
  final Function(KanbanCard) onCardUpdated;
  final Function(String) onCardDeleted;
  final VoidCallback onAddCard;

  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.onCardMoved,
    required this.onCardUpdated,
    required this.onCardDeleted,
    required this.onAddCard,
  });

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.column.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Column header
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: widget.column.color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _isEditingTitle
                      ? TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: _saveTitle,
                        )
                      : GestureDetector(
                          onTap: () => setState(() => _isEditingTitle = true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              widget.column.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showColumnMenu,
                ),
              ],
            ),
          ),
          // Cards list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: DragTarget<KanbanCard>(
                onAccept: (card) => widget.onCardMoved(card, widget.column.id),
                builder: (context, candidateData, rejectedData) {
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      ...widget.column.cards.map((card) => KanbanCardWidget(
                        card: card,
                        onUpdated: widget.onCardUpdated,
                        onDeleted: () => widget.onCardDeleted(card.id),
                      )),
                      // Add card button
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(top: 8),
                        child: OutlinedButton(
                          onPressed: widget.onAddCard,
                          child: const Text('+ Добавить карточку'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTitle(String value) {
    setState(() {
      _isEditingTitle = false;
      // In real implementation, update column title in provider
    });
  }

  void _showColumnMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Переименовать'),
            onTap: () {
              Navigator.of(context).pop();
              setState(() => _isEditingTitle = true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Удалить столбец'),
            onTap: () {
              Navigator.of(context).pop();
              // Delete column logic
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}