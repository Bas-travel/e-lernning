# 05. Data Model Guide

## Primary data source

The canonical schema is in [04-schema.sql](../04-schema.sql), and its relationships are documented in [03-er-diagram.md](../03-er-diagram.md).

## Core domains

- users
- profiles
- courses
- lessons
- quizzes
- orders and payments
- instructors
- organizations
- learning paths
- employer and admin structures

## Design assumptions

- One user may have multiple roles or access contexts
- Learning content should be connected to tracked progress and assessments
- Orders and payments should be auditable and reviewable
- Admin and corporate structures need explicit organization ownership and assignment logic

## Data consistency rules

- Use schema names consistently across DB and API models
- Keep aggregate fields aligned with UI summary cards
- Track status transitions in a predictable way
- Ensure permission and role fields are explicit in the database model

## Validation checklist

- [ ] All DB objects are mapped to the ER diagram
- [ ] Core API responses match the schema
- [ ] State transitions are represented in schema logic where needed
- [ ] Admin and audit fields are represented for moderation actions

## Implementation note

If the UI requires business logic beyond the current schema, add it through a reviewable change rather than by bypassing the canonical model definitions.
