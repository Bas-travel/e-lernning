# 03. Component Library

## Purpose

The component library should be built in Figma before screen design begins. This reduces rework and keeps the visual language consistent across all product areas.

## Core components

### Buttons
- Primary
- Secondary
- Ghost
- Outline
- Destructive
- Icon button

### Inputs
- Text input
- Search field
- Dropdown
- Select
- Filter chips

### Cards
- Course card
- Lesson card
- Learning path card
- Employee card
- Job card
- KPI card

### Navigation
- Top bar
- Bottom navigation
- Sidebar
- Tabs
- Role switcher

### Feedback
- Toast
- Banner
- Alert
- Empty state
- Success state
- Error state

### Data widgets
- Progress bar
- Rating
- Avatars
- Pill / tag
- Charts and summary tiles

## Figma naming pattern

Use clear naming conventions like:

- `Components / Buttons / Primary`
- `Components / Cards / Course Card`
- `Components / Navigation / Bottom Nav`
- `States / Course Detail / Loading`

## Standard component behavior

### Buttons
- Primary actions should use the brand blue/purple family
- Secondary actions should be visually lower emphasis
- Disabled states must remain legible and distinct

### Cards
- Maintain consistent border radius, spacing, and shadow treatment
- Cards should avoid overloaded information at mobile size

### Pills and status
- Use token-based background colors instead of hard-coded values
- Status labels should be highly readable and consistent across screens

## Implementation guidance

Use the same naming logic and state variations in Flutter component design so the visual language stays consistent between Figma and app code.
