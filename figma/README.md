# Figma File Structure

This folder defines the recommended Figma file organization for AB LEARNING Prototype V1.

## Page order

1. `00-Foundations`
2. `01-Components`
3. `02-States`
4. `03-P0 Screens`
5. `04-P1 Screens`
6. `05-Flows`
7. `06-Prototype`

## Purpose

Use this structure to keep the design system, screen library, and flows aligned with the product blueprint and the implementation work already defined in:

- `00-blueprint-overview.md`
- `01-screens-spec.md`
- `02-hifi-mockups.html`
- `05-openapi.yaml`
- `04-schema.sql`

## Design conventions

- Keep design tokens in a single foundation page; do not duplicate them across screens.
- Build reusable components first, then create screens from those components.
- Use a consistent `State/*` pattern for every data-driven screen.
- Use prototype flows instead of duplicated screens for journeys.
- Name all frames using this pattern: `Page / Screen Name` or `Component / Button / Primary`.

## Recommended frame naming

- `Components / Buttons / Primary`
- `Components / Cards / Course Card`
- `Components / Navigation / Bottom Nav`
- `States / Loading / Course Detail`
- `Screens / 01-Home / Default`
- `Flows / 01-Purchase / Screen 01`

## File handoff checklist

- [ ] Tokens approved
- [ ] Foundation page signed off
- [ ] Component library complete
- [ ] P0 screens built
- [ ] P1 screens added after sign off
- [ ] Prototype links ready
- [ ] Dev handoff notes exported
