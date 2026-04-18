# FoodLens Design System Documentation

## Overview

This design system provides a comprehensive, professional frontend architecture following Apple's Human Interface Guidelines (HIG). It implements design tokens, reusable components, and consistent patterns across the application.

## Architecture Principles

### 1. **Design Tokens**
Centralized design values that ensure consistency across the app:
- **Typography**: Type scale following Apple's SF Pro text styles
- **Spacing**: 4pt grid system for consistent layout
- **Colors**: Semantic color tokens with system color support
- **Corner Radius**: Standard radius values for rounded elements
- **Animation**: Predefined spring animations matching iOS feel

### 2. **Component-Based Design**
Reusable, self-contained UI components:
- **CaloriesPillView**: Summary pill with progress indication
- **MacroGaugeView**: Progress gauge for macronutrients
- **MealRowView**: Consistent meal entry display
- **EmptyStateView**: Standardized empty states
- **SectionHeaderView**: List section headers

### 3. **Accessibility First**
- Proper accessibility labels and values
- Minimum 44pt touch targets
- Dynamic Type support
- VoiceOver optimized
- Semantic colors for light/dark mode

## Design Tokens Reference

### Typography Scale

```swift
// Large titles and headers
DesignTokens.Typography.largeTitle  // 34pt Bold
DesignTokens.Typography.title1      // 28pt Regular
DesignTokens.Typography.title2      // 22pt Regular
DesignTokens.Typography.title3      // 20pt Semibold

// Body text
DesignTokens.Typography.body        // 17pt Regular
DesignTokens.Typography.bodyEmphasized  // 17pt Semibold
DesignTokens.Typography.callout     // 16pt Regular

// Secondary text
DesignTokens.Typography.caption1    // 12pt Regular
DesignTokens.Typography.caption2    // 11pt Regular
```

### Spacing Scale

```swift
DesignTokens.Spacing.xxSmall   // 4pt
DesignTokens.Spacing.xSmall    // 8pt
DesignTokens.Spacing.small     // 12pt
DesignTokens.Spacing.medium    // 16pt
DesignTokens.Spacing.large     // 20pt
DesignTokens.Spacing.xLarge    // 24pt
DesignTokens.Spacing.xxLarge   // 32pt
```

### Color Tokens

```swift
// Primary colors
DesignTokens.Colors.accent
DesignTokens.Colors.primary
DesignTokens.Colors.secondary

// Macro colors
DesignTokens.Colors.protein    // Green
DesignTokens.Colors.carbs      // Blue
DesignTokens.Colors.fat        // Orange
DesignTokens.Colors.calories   // Orange

// Background colors (system adaptive)
DesignTokens.Colors.background
DesignTokens.Colors.secondaryBackground
DesignTokens.Colors.groupedBackground
DesignTokens.Colors.secondaryGroupedBackground
```

## Component Usage Examples

### CaloriesPillView

```swift
CaloriesPillView(
    current: 850,
    target: 2000
)
```

**Features:**
- Full-width responsive layout
- Progress color indication (green/orange/red)
- Monospaced digit display
- Accessibility support

### MacroGaugeView

```swift
MacroGaugeView(
    label: "Protein",
    value: 85,
    target: 150,
    color: DesignTokens.Colors.protein
)
```

**Features:**
- Animated progress bar
- Percentage calculation
- Target comparison
- Semantic colors

### EmptyStateView

```swift
EmptyStateView(
    systemImage: "fork.knife",
    title: "No Meals Logged",
    description: "Tap the add button to log your first meal today.",
    action: { /* action */ },
    actionLabel: "Add Meal"
)
```

**Features:**
- Optional action button
- SF Symbols integration
- Center-aligned layout
- Clear hierarchy

### MealRowView

```swift
MealRowView(meal: mealEntry) {
    // Delete action
}
```

**Features:**
- Macro chips with color coding
- Time and serving display
- Swipe actions support
- Accessibility labels

## Best Practices

### 1. **Use Design Tokens**
❌ Don't use magic numbers:
```swift
.padding(16)
.font(.system(size: 17))
```

✅ Use tokens:
```swift
.padding(DesignTokens.Spacing.medium)
.font(DesignTokens.Typography.body)
```

### 2. **Component Composition**
❌ Don't duplicate UI code:
```swift
// Repeated gauge code in multiple places
```

✅ Use reusable components:
```swift
MacroGaugeView(label: "Protein", value: 85, target: 150, color: .green)
```

### 3. **Semantic Colors**
❌ Don't use fixed colors:
```swift
.foregroundColor(.black)
```

✅ Use semantic tokens:
```swift
.foregroundStyle(DesignTokens.Colors.primary)
```

### 4. **Accessibility**
✅ Always include:
```swift
.accessibilityLabel("Descriptive label")
.accessibilityValue("Current value")
```

### 5. **Animation**
✅ Use standard timing:
```swift
.animation(DesignTokens.Animation.springStandard, value: progress)
```

## File Structure

```
FoodLens/
├── DesignSystem/
│   ├── DesignTokens.swift           // Centralized tokens
│   └── Components/
│       ├── CaloriesPillView.swift
│       ├── MacroGaugeView.swift
│       ├── MealRowView.swift
│       ├── EmptyStateView.swift
│       └── SectionHeaderView.swift
├── Presentation/
│   └── TodayViewRefactored.swift    // Component-based views
└── ...
```

## Migration Guide

### Step 1: Import Design Tokens
```swift
import SwiftUI

// Use tokens in your views
.padding(DesignTokens.Spacing.medium)
.font(DesignTokens.Typography.body)
```

### Step 2: Replace Custom UI with Components
```swift
// Before:
HStack {
    Text("Calories")
    Spacer()
    Text("\(calories)")
}
.padding()
.background(Color.gray)

// After:
CaloriesPillView(current: calories, target: targetCalories)
```

### Step 3: Update Color Usage
```swift
// Before:
.foregroundColor(.black)
.background(.gray)

// After:
.foregroundStyle(DesignTokens.Colors.primary)
.background(DesignTokens.Colors.secondaryGroupedBackground)
```

## Benefits

1. **Consistency**: Single source of truth for design values
2. **Maintainability**: Change once, update everywhere
3. **Scalability**: Easy to add new components
4. **Accessibility**: Built-in WCAG compliance
5. **Performance**: Optimized, reusable views
6. **HIG Compliance**: Follows Apple's guidelines

## References

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Version**: 1.0.0  
**Last Updated**: April 2026  
**Maintained By**: FoodLens Engineering Team
