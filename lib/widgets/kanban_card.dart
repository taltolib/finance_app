import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/kanban_model.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class KanbanCardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LongPressDraggable<KanbanCard>(
      data: card,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: card.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            card.transactionId != null ? 'Транзакция' : (card.note ?? 'Карточка'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(context),
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCardDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color strip
            Container(
              height: 4,
              width: double.infinity,
              color: card.cardColor.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            // Content
            if (card.transactionId != null) ...[
              Text(
                'Транзакция', // In real app, get transaction details
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Сумма: ??? UZS', // Placeholder
                style: const TextStyle(color: Colors.white70),
              ),
            ] else ...[
              Text(
                card.note ?? 'Без заметки',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              DateFormat('dd.MM.yyyy', 'ru_RU').format(card.createdAt),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            // Status badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                card.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CardDetailsBottomSheet(
        card: card,
        onUpdated: onUpdated,
        onDeleted: onDeleted,
      ),
    );
  }
}

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
  late String _note;
  late String _status;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.card.cardColor;
    _note = widget.card.note ?? '';
    _status = widget.card.status;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Редактировать карточку',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Color picker
          Row(
            children: [
              const Text('Цвет:'),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _pickColor,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Note field
          TextField(
            controller: TextEditingController(text: _note),
            decoration: const InputDecoration(labelText: 'Заметка'),
            onChanged: (value) => _note = value,
          ),
          const SizedBox(height: 16),
          // Status field
          TextField(
            controller: TextEditingController(text: _status),
            decoration: const InputDecoration(labelText: 'Статус'),
            onChanged: (value) => _status = value,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDeleted,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Удалить'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите цвет'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedCard = KanbanCard(
      id: widget.card.id,
      transactionId: widget.card.transactionId,
      cardColor: _selectedColor,
      note: _note.isEmpty ? null : _note,
      status: _status,
      createdAt: widget.card.createdAt,
    );
    widget.onUpdated(updatedCard);
    Navigator.of(context).pop();
  }
}