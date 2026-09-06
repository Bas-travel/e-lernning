# 02. Design System and Tokens

## Design token source of truth

The design tokens should be treated as the single source of truth for color, type, spacing, and radius decisions. Any visual variation should originate from these values and be reflected consistently in mockups and implementation.

## Core palette

| Token | Value | Usage |
|---|---|---|
| `color/primary` | `#4F46E5` | Primary actions, active nav, links |
| `color/secondary` | `#7C3AED` | Secondary emphasis |
| `color/accent` | `#06B6D4` | AI highlights, badges, status accents |
| `color/success` | `#22C55E` | Completed, paid, good status |
| `color/warning` | `#F59E0B` | Pending, low-stock, caution |
| `color/error` | `#EF4444` | Errors and destructive states |
| `color/bg` | `#F8FAFC` | Page background |
| `color/text` | `#0F172A` | Primary text |
| `color/text-secondary` | `#64748B` | Secondary text |

### Updated token direction
The review notes in [design-review/02-hifi-feedback.md](../design-review/02-hifi-feedback.md) recommend the following visual enhancements:

- `primary`: `#4338CA` for stronger contrast on white surfaces
- `accent`: `#0EA5E9` for a softer, more aligned highlight tone
- Additional surface tokens for pill and state backgrounds are recommended

## Radii

| Radius | Value | Usage |
|---|---|---|
| `radius/card` | `16px` | Cards |
| `radius/button` | `12px` | Buttons |
| `radius/input` | `10px` | Inputs |
| `radius/modal` | `20px` | Modals and sheets |
| `radius/badge` | `999px` | Pills and badges |

## Typography

### Type pairing
- Thai: Noto Sans Thai
- English: Inter / Aptos

### Type scale
- Display: 28/36
- H1: 22/28
- H2: 18/24
- Body: 15/22
- Caption: 13/18
- Micro: 11/16

### Type weight system
- Headings: 500
- Body: 400
- Emphasis: 600 only for prices, score values, and highly specific numbers

## Layout rules

- 8px spacing grid is preferred
- Cards should maintain consistent internal padding and rhythm
- Use clean alignment and constrained widths on desktop layouts
- Mobile should prioritize comfortable tap targets and vertical stacking

## Iconography and visuals

- Icons should remain simple and legible
- Avoid excessive emoji use when a compact SVG or icon style is available
- Status indicators and badges should use tokens rather than hard-coded hex values

## Implementation note

The Flutter theme is expected to mirror the design tokens from the approved Figma foundation. Keep tokens centralized and avoid ad hoc color restatements across screens.
