# 03. UI Implementation Guide

## Design system implementation

The Flutter app should consume the approved design tokens as the single source of truth. This includes:

- primary / secondary / accent colors
- background and text colors
- radius values
- spacing scale
- typography styles
- card, button, and pill rules

## Component architecture

### Core components
- `PrimaryButton`
- `SecondaryButton`
- `OutlineButton`
- `CourseCard`
- `LessonCard`
- `KpiCard`
- `FilterChip`
- `StatusPill`
- `BottomNavigationBar`
- `SidebarNav`

### UX patterns
- Use consistent button hierarchy
- Keep card padding and corner radius aligned
- Use high-contrast text states for all actions and pills
- Use consistent empty/error/loading states across the app

## Screen-level rules

### Mobile
- Prefer stacked layouts and thumb-friendly actions
- Use bottom navigation for main journeys
- Keep CTA density moderate and clean

### Tablet
- Use 2-column content blocks where useful
- Preserve consistency in card rhythm and spacing

### Desktop
- Sidebar + content column layout
- Use tables and detail drawers for data-heavy work
- Maintain high clarity for admin tools

## State implementation requirement

Every data screen should support:

- loading
- empty
- error
- success

Additional states such as disabled, permission denied, and offline should be added for the relevant business cases.

## Design-to-code checklist

- [ ] Theme values match approved tokens
- [ ] Button hierarchy is consistent
- [ ] Card radii and padding match specs
- [ ] Roles and screens use consistent navigation
- [ ] Empty/error/loading patterns are implemented
- [ ] Color contrast meets readability expectations
