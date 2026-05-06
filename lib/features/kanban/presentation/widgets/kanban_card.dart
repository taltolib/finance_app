import 'package:flutter/material.dart';
import 'dart:ui';
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

class _KanbanCardWidgetState extends State<KanbanCardWidget>
    with SingleTickerProviderStateMixin {
  bool _done = false;
  bool _isHovering = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverScale;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovering = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovering = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<KanbanCard>(
      data: widget.card,
      feedback: Material(
        color: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
          ),
          child: _buildCardContent(isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: _buildCardContent(),
      ),
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTap: () => _showCardDetails(context),
          child: ScaleTransition(
            scale: _hoverScale,
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent({bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(_isHovering && !isDragging ? 0.18 : 0.12),
                  Colors.white.withOpacity(_isHovering && !isDragging ? 0.12 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(
                  _isHovering && !isDragging ? 0.25 : 0.15,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    _isHovering && !isDragging ? 0.25 : 0.15,
                  ),
                  blurRadius: _isHovering && !isDragging ? 16 : 8,
                  offset: _isHovering && !isDragging
                      ? const Offset(0, 8)
                      : const Offset(0, 4),
                  spreadRadius: 0,
                ),
                if (_isHovering && !isDragging)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _done = !_done),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 0, right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _done
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white.withOpacity(0.35),
                            width: 1.5,
                          ),
                          color: _done
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          boxShadow: [
                            if (_done)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: _done
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
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
                              color: _done
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: _done
                                  ? TextDecoration.lineThrough
                                  : null,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.card.status.isNotEmpty &&
                              widget.card.status != 'Новая') ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                widget.card.status,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

class _CardDetailsBottomSheetState extends State<CardDetailsBottomSheet>
    with SingleTickerProviderStateMixin {
  late Color _selectedColor;
  late TextEditingController _noteController;
  late TextEditingController _statusController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.card.cardColor;
    _noteController = TextEditingController(text: widget.card.note ?? '');
    _statusController = TextEditingController(text: widget.card.status);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _statusController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Редактировать карточку',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Note field
                _buildGlassmorphicTextField(
                  _noteController,
                  'Заметка',
                  Icons.note_outlined,
                ),
                const SizedBox(height: 14),
                // Status field
                _buildGlassmorphicTextField(
                  _statusController,
                  'Статус',
                  Icons.flag_outlined,
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildGlassmorphicButton(
                        label: 'Удалить',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDeleted();
                        },
                        isDestructive: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassmorphicButton(
                        label: 'Сохранить',
                        onPressed: _saveChanges,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.5),
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicButton({
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.2),
                    ],
                  )
                : isDestructive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.4)
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDestructive
                    ? Colors.red.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
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
}