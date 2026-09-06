# 02. Technical Architecture Guide

## Stack

- Frontend: Flutter
- Backend: Go
- Database: MySQL
- API: REST with OpenAPI contract
- Containerization: Docker Compose
- CI: GitHub Actions + Codecov

## Architectural intent

The application is designed to be modular and easy to evolve in the early prototype stage. Each domain is separated by responsibility and backed by a consistent API contract.

## Frontend structure

The Flutter app should map closely to the product flow model:

- App shell and navigation
- Feature modules for learner, instructor, corporate, admin, employer flows
- Core theme and shared components
- Reusable services and state handling

## Backend structure

The Go backend should be organized around business domains and route responsibilities rather than a flat monolith. Keep it modular enough for clear onboarding and future scaling.

## API contract

The OpenAPI document at [05-openapi.yaml](../05-openapi.yaml) is the contract for endpoint naming, routes, payload shapes, and schema expectations. Any backend implementation should be verified against this contract before UI integration.

## Database model

The schema at [04-schema.sql](../04-schema.sql) should be the canonical database definition for the product. Database changes should be reviewed against the ER diagram and the API contract before being merged.

## Delivery constraints

- Maintain API and schema parity
- Keep screen states consistent with UI requirements
- Use shared design tokens across Flutter and web mockups
- Preserve domain boundaries in Go module structure

## Recommendation

Before starting large UI implementation, lock the token set, route names, and screen ownership boundaries. This will reduce rework and keep the backend, frontend, and product design in sync.
