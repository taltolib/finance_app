import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../data/models/kanban_model.dart';
import 'kanban_card.dart';

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
    final colors =context.watch<ThemeProvider>().isDark;

    return Container(
      width: 260,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color:  colors == false ?  Colors.white.withOpacity(0.88) : const Color(0xFF1A1A1A).withOpacity(0.88),
        boxShadow: [
          BoxShadow(
            color:   colors  == false ?   Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: _isEditingTitle
                      ? TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color:  Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: _saveTitle,
                    autofocus: true,
                  )
                      : GestureDetector(
                    onTap: () => setState(() => _isEditingTitle = true),
                    child: Text(
                      widget.column.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showColumnMenu,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.more_horiz, color: Colors.white60, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Cards list
          Flexible(
            child: DragTarget<KanbanCard>(
              onAcceptWithDetails: (details) =>
                  widget.onCardMoved(details.data, widget.column.id),
              builder: (context, candidateData, rejectedData) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  shrinkWrap: true,
                  children: [
                    ...widget.column.cards.map(
                          (card) => KanbanCardWidget(
                        card: card,
                        onUpdated: widget.onCardUpdated,
                        onDeleted: () => widget.onCardDeleted(card.id),
                      ),
                    ),
                    // Add card button
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: widget.onAddCard,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        child: Row(
                          children: const [
                            Icon(Icons.add, color: Colors.white54, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Добавить карточку',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.image_outlined, color: Colors.white38, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveTitle(String value) {
    setState(() => _isEditingTitle = false);
    // Update column title in provider if needed
  }

  void _showColumnMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.white),
            title: const Text('Переименовать', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop();
              setState(() => _isEditingTitle = true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Удалить список', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
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