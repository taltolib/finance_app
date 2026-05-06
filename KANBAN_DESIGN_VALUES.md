# 📐 Kanban Board - Animation & Design Values Reference

## ⏱️ Animation Durations

```dart
// Screen Level
FadeTransition on Screen Load:        300ms
AnimatedContainer (background):       800ms

// Column Level  
Column Decoration AnimatedContainer:  250ms
Column Title Edit Field:              Instant
Drag Target Highlight:                150ms

// Card Level
Card Hover Scale:                     200ms
Card Shadow Animation:                200ms
Card Drag Scale (feedback):           Instant
Card Opacity (dragging):              Instant

// Dialog Level
Dialog/BottomSheet Entry:             300ms
Dialog Scale (enter/exit):            300ms
Column Menu Animation:                200ms

// Bottom Sheet
Add Card BottomSheet Slide:           300ms
Add Card Item Animation:              200ms + (index * 50ms) stagger
```

---

## 🎯 Scale Values

```dart
// Hover States
Card Hover:           1.0 → 1.02
Column Hover:         No scale (gradient only)

// Drag States
Card Being Dragged:   1.0 → 1.08
Feedback Widget:      1.08 (constant)

// Dialog States
Dialog Enter:         0.8 → 1.0 (ScaleTransition)
Dialog Exit:          1.0 → 0.8 (ScaleTransition)

// Add Card BottomSheet Items
Item List Stagger:    opacity 1.0 (each item)
```

---

## 🌈 Color Opacity Values

### Text Colors (Base: White)
```dart
Primary Text:         Colors.white (opacity: 1.0)
Secondary Text:       Colors.white.withOpacity(0.6)
Tertiary Text:        Colors.white.withOpacity(0.4)
Disabled/Hint Text:   Colors.white.withOpacity(0.3)
Placeholder:          Colors.white.withOpacity(0.5)
```

### Background Colors (Base: White)
```dart
AppBar Normal:        Colors.white.withOpacity(0.1)
AppBar Hover:         Colors.white.withOpacity(0.12)
AppBar Bottom:        Colors.white.withOpacity(0.05)

Card Normal:          Colors.white.withOpacity(0.08)
Card Hover:           Colors.white.withOpacity(0.12) - 0.18
Card Gradient Light:  Colors.white.withOpacity(0.15) - 0.18
Card Gradient Dark:   Colors.white.withOpacity(0.05) - 0.08

Column Normal:        Colors.white.withOpacity(0.10)
Column Hover:         Colors.white.withOpacity(0.15)
Column Bottom:        Colors.white.withOpacity(0.10)

Button Primary:       Colors.white.withOpacity(0.18) - 0.25
Button Secondary:     Colors.white.withOpacity(0.05) - 0.08
Button Hover:         Colors.white.withOpacity(0.20) - 0.30

Input Field:          Colors.white.withOpacity(0.08)
Border:               Colors.white.withOpacity(0.1) - 0.3
```

### Shadow Colors (Base: Black)
```dart
Card Shadow Normal:   Colors.black.withOpacity(0.1) - 0.15
Card Shadow Hover:    Colors.black.withOpacity(0.2) - 0.25
Card Shadow Drag:     Colors.black.withOpacity(0.15) - 0.3

Column Shadow Normal: Colors.black.withOpacity(0.1)
Column Shadow Hover:  Colors.black.withOpacity(0.2)

Dialog/Sheet:         Colors.black.withOpacity(0.3)

Drag Glow:            Colors.blue.withOpacity(0.1) - 0.15
Red Accent:           Colors.red.withOpacity(0.1) - 0.7
```

### Special Colors
```dart
Blue Glow (Hover):    Colors.blue.withOpacity(0.1)
Red Accent:           Colors.red (destructive buttons)
Green Accent:         Colors.green (if needed)
```

---

## 📏 Layout Dimensions

### Column Dimensions
```dart
Width:                300px
Max Height:           700px
Border Radius:        16px
```

### Card Dimensions
```dart
Width:                240-300px (auto in column)
Margin Bottom:        8px
Padding:              12px (all)
Border Radius:        16px
Checkbox Size:        22px x 22px
Status Badge Size:    Auto (padding 8x3)
```

### Button/Widget Dimensions
```dart
Standard Button:      Vertical: 12-14px, Horizontal: 16-20px
Border Radius:        10-14px
Icon Size:            16-24px (varies by context)

Add Column Button:    300px wide, ~140px tall
Scroll Indicator:     4px wide, 60px tall
Card Count Badge:     Auto (padding 8x4)
```

### Padding & Spacing
```dart
Screen Horizontal:    16-24px
Screen Vertical:      16px
Column Spacing:       16px
Card Spacing:         8px bottom margin
Item Spacing:         8-12px
Dialog Padding:       20-24px
```

---

## 🎬 Blur Filter Values

```dart
// BackdropFilter blur amounts
AppBar:               sigmaX: 10, sigmaY: 10
Card:                 sigmaX: 8,  sigmaY: 8
Dialog/Sheet:         sigmaX: 10, sigmaY: 10
Input Fields:         sigmaX: 5,  sigmaY: 5
Menu:                 sigmaX: 10, sigmaY: 10
```

---

## 🔲 Border Styles

```dart
// Border opacity and width
Card Border:          width: 1px, color: White.opacity(0.12-0.25)
Column Border:        width: 1px, color: White.opacity(0.12-0.25)
Button Border:        width: 1px, color: White.opacity(0.15-0.25)
Input Border:         width: 1px, color: White.opacity(0.2-0.3)
Active Drag Border:   width: 2px, color: White.opacity(0.3)

Border Radius:
  - Cards:            16px
  - Columns:          16px
  - Buttons:          10-14px
  - Dialogs:          20-28px
  - Input Fields:     12-14px
```

---

## 💨 Shadow Specifications

### Normal State
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: const Offset(0, 4),
  spreadRadius: 0,
)
```

### Hover State
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 16,
  offset: const Offset(0, 8),
  spreadRadius: 0,
)

// Plus optional glow
BoxShadow(
  color: Colors.blue.withOpacity(0.1),
  blurRadius: 12,
  spreadRadius: 2,
)
```

### Drag State
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.25),
  blurRadius: 20,
  offset: const Offset(0, 8),
  spreadRadius: 0,
)
```

---

## 🎨 Gradient Specifications

### Background Gradient (Screen)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.grey.shade900,        // #121212
    Colors.grey.shade800,        // #1f1f1f
    Colors.black87,              // #140000
  ],
  stops: [0.0, 0.5, 1.0],
)
```

### Card Gradient (Normal)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(0.12),
    Colors.white.withOpacity(0.08),
  ],
)
```

### Card Gradient (Hover)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(0.18),
    Colors.white.withOpacity(0.12),
  ],
)
```

### AppBar Gradient
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withOpacity(0.1),
    Colors.white.withOpacity(0.05),
  ],
)
```

### Column Gradient (Normal)
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withOpacity(0.10),
    Colors.white.withOpacity(0.06),
  ],
)
```

### Column Gradient (Hover)
```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withOpacity(0.15),
    Colors.white.withOpacity(0.10),
  ],
)
```

### Button Gradient (Primary)
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withOpacity(0.25),
    Colors.white.withOpacity(0.18),
  ],
)
```

---

## 📝 Typography Values

```dart
// Font Sizes
AppBar Title:         18-20px
Section Title:        20-22px
Subtitle:             15-16px
Body Text:            13-15px
Caption:              11-13px
Small Badge:          10-12px

// Font Weights
Regular:              FontWeight.w400
Medium:               FontWeight.w500
Semibold:             FontWeight.w600
Bold:                 FontWeight.w700

// Shadows on Text
Text Shadow:
  color: Colors.black.withOpacity(0.3)
  blurRadius: 2
```

---

## 🎯 Animation Curves

```dart
// Primary Curve
Curves.easeOutCubic   // For all smooth animations

// Alternatives (if customization needed)
Curves.easeOut        // General smoothing
Curves.easeInOutCubic // For complex animations
Curves.linearToEaseOut // For specific cases
```

---

## 📊 Opacity Animation States

```dart
// Card Dragging
Original Card:        0.2 (ChildWhenDragging)
Feedback Widget:      1.0

// List Items Entry
Staggered Entry:      opacity: 1.0 (each item with delay)
Duration:             200ms + (index * 50ms)

// Icon States
Normal Icon:          opacity: 0.5-0.6
Hover Icon:           opacity: 0.7-0.8
Disabled Icon:        opacity: 0.3

// Empty State
Empty Icon:           opacity: 0.3
Empty Text:           opacity: 0.4
```

---

## 🔑 Key Numbers Summary Table

| Element | Size | Color | Animation |
|---------|------|-------|-----------|
| Card Width | 300px | White.opacity(0.08-0.18) | Scale 1.02, 200ms |
| Column Width | 300px | White.opacity(0.10-0.15) | Shadow change, 250ms |
| Border Radius | 16px | White.opacity(0.12-0.25) | N/A |
| Blur Amount | 8-10 | N/A | N/A |
| Hover Scale | 1.02x | N/A | 200ms easeOutCubic |
| Drag Scale | 1.08x | N/A | Instant |
| Shadow Blur | 8→16px | Black.opacity(0.1→0.2) | 200ms |
| Opacity Change | 0.08→0.18 | White | 200ms |
| Dialog Enter | 0.8→1.0 | N/A | 300ms easeOutCubic |

---

## 🎓 How to Use This Reference

1. **Copy exact values** from tables above
2. **Match animation timings** for consistency
3. **Use opacity ranges** for different states
4. **Apply gradients** as specified
5. **Keep blur amounts** consistent
6. **Maintain color scheme** throughout

Example usage:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.15),  // From table
        Colors.white.withOpacity(0.08),
      ],
    ),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),  // From table
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),  // From table
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
)
```

---

✨ **All values are production-tested and optimized for smooth performance!**
