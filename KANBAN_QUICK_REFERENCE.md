# 🎯 Kanban Board - Quick Reference

## Files Structure
```
lib/features/kanban/
├── data/
│   └── models/
│       └── kanban_model.dart (KanbanColumn, KanbanCard)
├── presentation/
│   ├── pages/
│   │   └── kanban_screen.dart ⭐ MAIN SCREEN
│   ├── providers/
│   │   └── kanban_provider.dart (State management)
│   └── widgets/
│       ├── kanban_column.dart (Column component)
│       └── kanban_card.dart (Card component)
```

---

## 🎨 Design Features at a Glance

| Feature | Implementation | Duration |
|---------|----------------|----------|
| **Hover Scale** | ScaleTransition 1.0→1.02 | 200ms |
| **Drag Scale** | ScaleTransition 1.0→1.08 | On start |
| **Shadow Animation** | AnimatedContainer | 200ms |
| **Fade In** | FadeTransition | 300ms |
| **Slide Bottom Sheet** | SlideTransition | 300ms |
| **Column Decoration** | AnimatedContainer | 250ms |
| **Drag Highlight** | DragTarget active state | Instant |

---

## 🎭 Animation Curves

```dart
// Primary curve - smooth & elegant
Curves.easeOutCubic

// Used for:
- Scale transitions (hover/drag)
- Fade animations
- Slide animations
- Shadow changes
```

---

## 🖼️ Visual Hierarchy

### Opacity Scale
```
Text Primary:        1.0 (White)
Text Secondary:      0.6 (White)
Text Tertiary:       0.4 (White)
Borders/Dividers:    0.15-0.25 (White)
Backgrounds:         0.05-0.18 (White)
Shadows:             0.1-0.25 (Black)
```

### Shadow Elevations
```
Normal Card:    blurRadius: 8px,  offset: 0, 4px,  opacity: 0.15
Hover Card:     blurRadius: 16px, offset: 0, 8px, opacity: 0.25
Dragging:       blurRadius: 20px, offset: 0, 10px (+ blue glow)
```

---

## 🎬 Animation Patterns

### Pattern 1: Hover Effect
```dart
MouseRegion(
  onEnter: (_) => setState(() => _isHovering = true),
  onExit: (_) => setState(() => _isHovering = false),
)

// Then use _isHovering to trigger:
- Scale animation
- Shadow increase
- Gradient change
- Border opacity increase
```

### Pattern 2: Drag Feedback
```dart
LongPressDraggable<KanbanCard>(
  feedback: ScaleTransition(scale: 1.08),
  childWhenDragging: Opacity(opacity: 0.2),
)
```

### Pattern 3: State Transition
```dart
DragTarget<KanbanCard>(
  onWillAccept: (data) {
    setState(() => _isDragTargetActive = true);
    return true;
  },
)

// Visual feedback via:
- Border highlight
- Background color change
- Shadow increase
```

---

## 📊 Component Interaction Map

```
User Action          → Component       → Animation          → Result
─────────────────────────────────────────────────────────────────
Hover Card           → KanbanCard      → Scale (1.0→1.02)   → Visual lift
LongPress Card       → LongPressDrag   → Scale (1.0→1.08)   → Grab feedback
Drag Over Column     → DragTarget      → Border highlight   → Drop zone hint
Drop Card            → Provider        → Opacity (1.0→0.2)  → Card removed from old col
                     → New Column      → Opacity (0.2→1.0)  → Card appears in new col
Hover Column         → ColumnWidget    → Scale decoration   → Subtle lift
Click Add Card       → BottomSheet     → Slide + Fade       → Panel slides up
```

---

## 🎨 Glassmorphism Recipe

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(
      decoration: BoxDecoration(
        // Gradient makes it look glass-like
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),  // Light
            Colors.white.withOpacity(0.08),  // Dark
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // Border creates definition
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        // Shadow gives depth
        boxShadow: [BoxShadow(...)],
      ),
    ),
  ),
)
```

---

## 🔧 State Variables Mapping

### KanbanScreen
```dart
_scrollController     → Horizontal scroll position
_fadeController       → Screen entry fade animation
_showScrollIndicator  → Scroll indicator visibility
```

### KanbanColumnWidget
```dart
_titleController      → Column title edit field
_isEditingTitle       → Title edit mode
_isHovering           → Mouse hover state
_isDragTargetActive   → Drop zone active state
_hoverController      → Hover animation controller
```

### KanbanCardWidget
```dart
_done                 → Task completion checkbox
_isHovering           → Mouse hover state
_hoverController      → Hover animation controller
_hoverScale           → Scale animation value (1.0-1.02)
```

---

## 📱 Responsive Values

```
Column Width:         300px
Max Column Height:    700px
Column Spacing:       16px
Card Bottom Margin:   8px
Card Border Radius:   16px
Button Border Radius: 12-14px

Padding Horizontal:   16-24px
Padding Vertical:     12-20px
```

---

## 🎯 Interaction States Reference

### Card States
- **Normal**: opacity 1.0, shadow small, gradient dim
- **Hover**: opacity 1.0, shadow large, gradient bright
- **Dragging**: opacity 0.2 (original), 1.0 (feedback), scale 1.08
- **Done**: strikethrough text, opacity 0.4

### Column States
- **Normal**: gradient 0.10, border 0.12, shadow small
- **Hover**: gradient 0.15, border 0.25, shadow large
- **DragTarget Active**: border highlight, background tint

### Dialog States
- **Entering**: scale 0.8→1.0, opacity 0→1.0
- **Exiting**: scale 1.0→0.8, opacity 1.0→0

---

## 🔗 Provider Integration

```dart
// Reading data
final provider = context.watch<KanbanProvider>();
final columns = provider.columns; // List<KanbanColumn>

// Modifying data
context.read<KanbanProvider>().addColumn(title, color);
context.read<KanbanProvider>().addCardToColumn(columnId, card);
context.read<KanbanProvider>().moveCard(cardId, fromId, toId);
context.read<KanbanProvider>().updateCard(card, columnId);
context.read<KanbanProvider>().deleteCard(cardId);
```

---

## ✨ Pro Tips

1. **Smooth Scrolling**: Use `BouncingScrollPhysics()` instead of default
2. **Hover Effects**: Always pair MouseRegion with setState for responsiveness
3. **Animation Timing**: 150-300ms is the sweet spot for micro-interactions
4. **Curves**: `easeOutCubic` works best for UI animations
5. **Drag Feedback**: Scale up when dragging, opacity down for original
6. **Empty States**: Show friendly icon + message when no cards
7. **Glass Effect**: Combine blur + gradient + border + shadow
8. **Shadows**: Multi-layer shadows create depth (dark shadow + colored glow)

---

## 🐛 Common Customizations

### Change Card Size
```dart
// In kanban_column.dart - adjust width in KanbanColumnWidget
width: 300, // Change this value
```

### Change Animation Speed
```dart
// Global animation duration
const Duration(milliseconds: 200) // Adjust this
```

### Change Color Scheme
```dart
// Modify opacity values in _buildCardContent, _buildColumnDecoration
Colors.white.withOpacity(0.15) // Change opacity
```

### Disable Animations
```dart
// Just set all durations to 0ms
duration: const Duration(milliseconds: 0),
```

---

## 📚 Key Imports

```dart
import 'dart:ui';                    // For blur effects
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
```

---

## 🎓 Learning Path

1. Start with `kanban_screen.dart` to understand the main layout
2. Look at `KanbanColumnWidget` for column-level interactions
3. Study `KanbanCardWidget` for card animations and drag/drop
4. Review animation curves and timing
5. Experiment with opacity and color values

Enjoy your premium Kanban board! 🚀
