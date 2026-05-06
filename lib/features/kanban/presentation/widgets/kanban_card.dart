import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../data/models/kanban_model.dart';

class KanbanCardWidget extends StatefulWidget {
  final KanbanCard card;
  final Function(KanbanCard) onUpdated;
  final VoidCallback onDeleted;

  const KanbanCardWidget({
    super.key,
    required this.card,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<KanbanCardWidget> createState() => _KanbanCardWidgetState();
}

class _KanbanCardWidgetState extends State<KanbanCardWidget> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<KanbanCard>(
      data: widget.card,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: _buildCardContent(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(),
      ),
      child: GestureDetector(
        onTap: () => _showCardDetails(context),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // Dark card with slight tint like in the photo
        color: const Color(0xFF2A2A2A).withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox circle (like in photo)
          GestureDetector(
            onTap: () => setState(() => _done = !_done),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 1, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _done ? Colors.white70 : Colors.white38,
                  width: 1.5,
                ),
                color: _done ? Colors.white24 : Colors.transparent,
              ),
              child: _done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          // Card text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.note ??
                      (widget.card.transactionId != null
                          ? 'Транзакция #${widget.card.transactionId}'
                          : 'Без заметки'),
                  style: TextStyle(
                    color: _done ? Colors.white38 : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: _done ? TextDecoration.lineThrough : null,
                    height: 1.4,
                  ),
                ),
                if (widget.card.status.isNotEmpty && widget.card.status != 'Новая') ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.card.status,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDetailsBottomSheet(
        card: widget.card,
        onUpdated: widget.onUpdated,
        onDeleted: widget.onDeleted,
      ),
    );
  }
}

// ─── Card Details Bottom Sheet ────────────────────────────────────────────────
class CardDetailsBottomSheet extends StatefulWidget {
  final KanbanCard card;
  final Function(KanbanCard) onUpdated;
  final VoidCallback onDeleted;

  const CardDetailsBottomSheet({
    super.key,
    required this.card,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<CardDetailsBottomSheet> createState() => _CardDetailsBottomSheetState();
}

class _CardDetailsBottomSheetState extends State<CardDetailsBottomSheet> {
  late Color _selectedColor;
  late TextEditingController _noteController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.card.cardColor;
    _noteController = TextEditingController(text: widget.card.note ?? '');
    _statusController = TextEditingController(text: widget.card.status);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            'Редактировать карточку',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Note field
          _buildTextField(_noteController, 'Заметка'),
          const SizedBox(height: 12),
          // Status field
          _buildTextField(_statusController, 'Статус'),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDeleted();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Удалить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white10,
      ),
    );
  }

  void _saveChanges() {
    final updatedCard = KanbanCard(
      id: widget.card.id,
      transactionId: widget.card.transactionId,
      cardColor: _selectedColor,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      status: _statusController.text,
      createdAt: widget.card.createdAt,
    );
    widget.onUpdated(updatedCard);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}