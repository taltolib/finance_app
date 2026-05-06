# 🎨 Modern Premium Kanban Board - Flutter Implementation

## Overview
Полнофункциональная Kanban-доска с glassmorphism дизайном, smooth анимациями и Trello-like взаимодействием.

---

## 🎯 **Основные компоненты**

### 1. **KanbanScreen** (`lib/features/kanban/presentation/pages/kanban_screen.dart`)

#### Функциональность:
- Отображение всех колонок горизонтально
- Красивый AppBar с статистикой (количество задач)
- Кнопка добавления новой колонки
- Scroll indicator на правой стороне
- Fade-in анимация при загрузке

#### Ключевые элементы:
```dart
// Animated gradient background
Positioned.fill(
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 800),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade900, Colors.grey.shade800, Colors.black87],
      ),
    ),
  ),
)

// Enhanced AppBar with BackdropFilter
ClipRRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
    ),
  ),
)
```

#### State Management:
- `_scrollController`: управление горизонтальным скроллом
- `_fadeController`: анимация появления
- `_showScrollIndicator`: видимость scroll indicator

---

### 2. **KanbanColumnWidget** (`lib/features/kanban/presentation/widgets/kanban_column.dart`)

#### Дизайн:
- Glassmorphic background с градиентом
- Hover effect (тень и прозрачность увеличиваются)
- DragTarget с активным state (highlight при hover карточки)
- Empty state вью с иконкой

#### Анимации:
```dart
// Hover scale на всю колонку
MouseRegion(
  onEnter: (_) => setState(() => _isHovering = true),
  onExit: (_) => setState(() => _isHovering = false),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    decoration: _buildColumnDecoration(),
  ),
)

// Drag target highlight
DragTarget<KanbanCard>(
  onWillAccept: (data) {
    setState(() => _isDragTargetActive = true);
    return true;
  },
  onLeave: (data) {
    setState(() => _isDragTargetActive = false);
  },
)
```

#### Компоненты:
- **Column Header**: Название + количество карточек + меню
- **Cards List**: ListView с BouncingScrollPhysics
- **Add Card Button**: Красивая кнопка с иконкой
- **Empty State**: "Нет карточек" + иконка
- **Column Menu**: Переименование / Удаление

---

### 3. **KanbanCardWidget** (`lib/features/kanban/presentation/widgets/kanban_card.dart`)

#### Glassmorphic Design:
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.18), // hover
            Colors.white.withOpacity(0.12), // normal
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25), // hover
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // hover
            blurRadius: 16,
          ),
        ],
      ),
    ),
  ),
)
```

#### Hover Animation:
```dart
// Scale 1.0 → 1.02
_hoverScale = Tween<double>(begin: 1.0, end: 1.02).animate(
  CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
)

// Smooth shadow and gradient transition
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  // автоматически переходит между значениями при _isHovering
)
```

#### Drag & Drop:
```dart
// LongPressDraggable - работает при долгом удержании
LongPressDraggable<KanbanCard>(
  data: widget.card,
  feedback: Material(
    // Что видно при dragging (scale 1.08)
    child: ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.08).animate(...),
    ),
  ),
  childWhenDragging: Opacity(
    opacity: 0.2, // Исходная карточка становится прозрачной
  ),
)
```

#### Состояния карточки:
- ✅ **Hover**: Тень увеличивается, градиент светлеет, граница ярче
- 🎯 **Pressing**: Стандартная InkWell реакция
- 🚀 **Dragging**: Scale 1.08, opacity feedback
- ✔️ **Done**: Чекбокс + strikethrough text
- 🏷️ **Status Badge**: Красивая rounded capsule с иконкой

---

## 🎬 **Animations Deep Dive**

### Scale Animation (Hover)
```dart
_hoverScale = Tween<double>(begin: 1.0, end: 1.02).animate(
  CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
)

ScaleTransition(scale: _hoverScale, child: _buildCardContent())
Duration: 200ms | Curve: easeOutCubic
```

### Shadow Animation
```dart
// Динамическое изменение тени в зависимости от _isHovering
BoxShadow(
  color: Colors.black.withOpacity(_isHovering ? 0.25 : 0.15),
  blurRadius: _isHovering ? 16 : 8,
  offset: _isHovering ? const Offset(0, 8) : const Offset(0, 4),
)
```

### Slide Transition (Bottom Sheet)
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(...)),
  child: child,
)
Duration: 300ms
```

### Fade Transition (Screen Load)
```dart
FadeTransition(
  opacity: _fadeController,
  child: Column(...),
)
Duration: 300ms | Curve: default
```

---

## 🎨 **Color Scheme & Opacity Values**

### Background
- Primary: `Colors.grey.shade900` / `Colors.grey.shade800` / `Colors.black87`
- Overlay: `Colors.black.withOpacity(0.2)`

### Cards & Columns
| State | Color | Opacity |
|-------|-------|---------|
| Normal | White | 0.08-0.12 |
| Hover | White | 0.12-0.18 |
| Borders | White | 0.12-0.25 |
| Shadows | Black | 0.1-0.25 |

### Text
| Type | Color | Opacity |
|------|-------|---------|
| Primary | White | 1.0 |
| Secondary | White | 0.6 |
| Tertiary | White | 0.4 |
| Disabled | White | 0.3 |

### Accent Colors
- Destructive: `Colors.red` (с opacity 0.2-0.7)
- Hover Glow: `Colors.blue.withOpacity(0.1)`

---

## 🔄 **State Management Flow**

```
KanbanScreen (watches KanbanProvider)
├── KanbanColumnWidget (multiple)
│   ├── Column Header
│   ├── DragTarget (accepts KanbanCard)
│   └── ListView
│       └── KanbanCardWidget (multiple)
│           ├── Checkbox state
│           └── LongPressDraggable
└── Add Column Button

Data Flow:
1. User drags card → LongPressDraggable feedback
2. Drops on column → DragTarget.onAcceptWithDetails
3. Calls kanbanProvider.moveCard()
4. Provider notifyListeners()
5. UI rebuilds with new state
```

---

## 🎯 **Usage Examples**

### Adding New Card
```dart
void _addCardToColumn(KanbanColumn column) {
  final card = KanbanCard(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    cardColor: const Color(0xFF1C1C1E),
    note: "Task name",
    status: 'Новая',
    createdAt: DateTime.now(),
  );
  context.read<KanbanProvider>().addCardToColumn(column.id, card);
}
```

### Moving Card Between Columns
```dart
// Automatic via DragTarget
kanbanProvider.moveCard(
  cardId,      // Карточка для перемещения
  fromColumnId, // Откуда (не используется, но может быть полезно)
  toColumnId,   // Куда
)
```

### Creating New Column
```dart
context.read<KanbanProvider>().addColumn(
  "Column Name",
  const Color(0xFF1C1C1E),
)
```

---

## 🎪 **Dialog & Bottom Sheet Features**

### Add Column Dialog
- **Entry Animation**: ScaleTransition (0.8 → 1.0)
- **Glassmorphic**: BackdropFilter + gradient
- **Loading State**: Spinner during creation
- **Duration**: 300ms

### Add Card Bottom Sheet
- **Entry Animation**: SlideTransition (0.4 offset → 0)
- **Exit Animation**: Reverse slide
- **Physics**: BouncingScrollPhysics на ListView
- **Height**: 75% от экрана

### Card Details Sheet
- **Glassmorphic Design**: Full backdrop filter
- **Edit Fields**: Note, Status (с иконками)
- **Delete/Save Actions**: Gradient buttons
- **Animation**: Fade + Slide на вход

---

## 📱 **Responsive Design**

### Column Width
- Desktop/Tablet: 300px
- Min height: 700px (constrained)
- Flexible height based on cards

### Spacing
- Column gap: 16px
- Card margin: 8px bottom
- Padding: 16-24px horizontal

### Scroll Behavior
- **Physics**: BouncingScrollPhysics
- **Indicator**: Auto-hide/show
- **Speed**: Smooth with momentum

---

## ⚡ **Performance Optimizations**

1. **SingleTickerProviderStateMixin** - Эффективные animations
2. **ValueKey** на cards - Prevents rebuilds
3. **const constructors** - Reduces widget allocations
4. **Indexed.map** - Efficient list rendering
5. **AnimatedContainer** - Native optimized animations

---

## 🚀 **Production Checklist**

- [x] Glassmorphism design implemented
- [x] Smooth animations (150-300ms)
- [x] Drag & drop fully functional
- [x] Hover/pressed/dragging states
- [x] Empty state handling
- [x] Dark premium UI
- [x] Responsive layout
- [x] Clean code architecture
- [x] Proper state management
- [x] Error handling integrated

---

## 📝 **Notes**

- Все animations используют `CurvedAnimation` с `easeOutCubic`
- BackdropFilter применен ко всем dialogs и модальам
- Color opacity значения оптимизированы для dark mode
- Используется `indexed.map` для staggered animations
- Provider integration полностью сохранена
