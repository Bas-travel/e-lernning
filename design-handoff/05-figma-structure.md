# 05. Figma Structure and Page Setup

## Recommended page order

1. `00-Foundations`
2. `01-Components`
3. `02-States`
4. `03-P0 Screens`
5. `04-P1 Screens`
6. `05-Flows`
7. `06-Prototype`

## Foundation page

This page contains:

- Brand tokens
- Design palette
- Typography scale
- Spacing and layout system
- Radius values
- Border and elevation rules

## Component page

This page contains reusable building blocks, such as:

- Buttons
- Inputs
- Cards
- Navigation
- Data widgets
- Feedback states

## States page

This page contains the full state library for each screen type, including:

- Default
- Loading
- Empty
- Error
- Success
- Disabled
- Offline / permission denied

## P0 screens page

This page is reserved for highest-value screens. These should be designed in grayscale first, then refined.

## Flow page

This page is for prototype wiring and audience journeys. Use screen reuse instead of duplicated screens where possible.

## Prototype page

This page is for click logic, transitions, and delegation to stakeholder review. It should read as a product demo, not a raw design board.

## Naming rules

Use a consistent naming style across frames and components.

Examples:

- `Components / Buttons / Primary`
- `Screens / 01-Home / Default`
- `States / My Learning / Empty`
- `Flows / 01-Purchase / Screen 01`

## Delivery note

The Figma file should be organized so developers can map each visual element back to a reusable token or component without ambiguity.
