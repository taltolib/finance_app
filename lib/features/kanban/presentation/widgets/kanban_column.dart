import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_app/core/state/providers/theme_provider.dart';
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

class _KanbanColumnWidgetState extends State<KanbanColumnWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;
  bool _isHovering = false;
  bool _isDragTargetActive = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.column.title;
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 300,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: _buildColumnDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Column header
            _buildColumnHeader(),
            // Cards list with drag target
            Flexible(
              child: DragTarget<KanbanCard>(
                onWillAccept: (data) {
                  setState(() => _isDragTargetActive = true);
                  return true;
                },
                onLeave: (data) {
                  setState(() => _isDragTargetActive = false);
                },
                onAcceptWithDetails: (details) {
                  setState(() => _isDragTargetActive = false);
                  widget.onCardMoved(details.data, widget.column.id);
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: _isDragTargetActive
                          ? Colors.white.withOpacity(0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: _isDragTargetActive
                            ? Colors.white.withOpacity(0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: _buildCardsList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildColumnDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(_isHovering ? 0.15 : 0.10),
          Colors.white.withOpacity(_isHovering ? 0.10 : 0.06),
        ],
      ),
      border: Border.all(
        color: Colors.white.withOpacity(_isHovering ? 0.25 : 0.12),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(_isHovering ? 0.2 : 0.1),
          blurRadius: _isHovering ? 16 : 8,
          spreadRadius: 0,
          offset: _isHovering ? const Offset(0, 8) : const Offset(0, 4),
        ),
        if (_isHovering)
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
          ),
      ],
    );
  }

  Widget _buildColumnHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _isEditingTitle
                    ? _buildTitleEditField()
                    : _buildTitleDisplay(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  widget.column.cards.length.toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleDisplay() {
    return GestureDetector(
      onTap: () => setState(() => _isEditingTitle = true),
      child: Text(
        widget.column.title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTitleEditField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      onSubmitted: (_) => setState(() => _isEditingTitle = false),
      autofocus: true,
    );
  }

  Widget _buildMoreButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showColumnMenu,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.more_vert,
            color: Colors.white.withOpacity(0.6),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return widget.column.cards.isEmpty
        ? _buildEmptyState()
        : ListView(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ...widget.column.cards.indexed.map((entry) {
                final index = entry.$1;
                final card = entry.$2;
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: KanbanCardWidget(
                    key: ValueKey(card.id),
                    card: card,
                    onUpdated: widget.onCardUpdated,
                    onDeleted: () => widget.onCardDeleted(card.id),
                  ),
                );
              }),
              const SizedBox(height: 4),
              _buildAddCardButton(),
            ],
          );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inbox_outlined,
          color: Colors.white.withOpacity(0.3),
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          'Нет карточек',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildAddCardButton(),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onAddCard,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
              style: BorderStyle.solid,
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Добавить карточку',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColumnMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildMenuOption(
                  icon: Icons.edit_outlined,
                  label: 'Переименовать',
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _isEditingTitle = true);
                  },
                ),
                _buildMenuOption(
                  icon: Icons.delete_outline,
                  label: 'Удалить список',
                  color: Colors.red,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color.withOpacity(0.7), size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}