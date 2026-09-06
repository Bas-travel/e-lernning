# 06. Developer Handoff Notes

## Objective

This document translates the approved design into implementation guidance for engineering and product teams.

## Design-to-code alignment

### 1. Tokens first
All colors, radii, spacing, and type attributes should be pulled from the design token source of truth. Avoid hard-coded values in isolated screens.

### 2. Reusable components
Any reusable element should be built once in Flutter and reused across screens. This includes cards, buttons, pills, navigation patterns, and data widgets.

### 3. State handling
Every data-driven screen should handle these states:

- Default
- Loading
- Empty
- Error
- Success

Add additional states when required by real business logic, especially for payment, audit, permissions, and offline behavior.

### 4. Routing and screen structure
The app should follow the same logical flow structure as the approved product blueprint:

- Learn
- Live
- AI tutor
- Community
- Portfolio
- Jobs
- Employer / admin tools

### 5. Responsive behavior
- Mobile: vertical, task-focused, bottom navigation
- Tablet: denser two-column layouts
- Desktop: sidebar + content area + data-heavy tables and drawers

## Acceptance criteria for implementation

- Tokens are centralized and match approved values
- Button hierarchy is clear and consistent
- Card spacing and radii are aligned to design tokens
- Navigation patterns match the product structure
- State screens exist for all critical data views
- Mobile and desktop layouts remain readable and consistent

## Notes for future work

- Keep design review updates in sync with `design-review/02-hifi-feedback.md`
- Reconcile any token changes with the Flutter theme before final UI sign-off
- Update the Handoff pack whenever the approved design changes

---

## Final recommendation

Treat this package as the design execution document for Sprint 1 and early UI implementation. It keeps the design system, Figma structure, and engineering implementation aligned.
