# 02-States

## Goal

Document every state for data-heavy screens.

## Required states per screen

- Default
- Loading
- Empty
- Error
- Success
- Disabled (when relevant)
- Offline / permission denied (when relevant)

## Naming pattern

`Screen Name / State / Default`

Examples:
- `Course Detail / State / Loading`
- `My Learning / State / Empty`
- `Admin Dashboard / State / Error`
- `Payment Management / State / Success`

## Rule

State variants should be a component set, not ad hoc individual frames.
