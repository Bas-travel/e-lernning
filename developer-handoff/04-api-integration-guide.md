# 04. API Integration Guide

## API source of truth

The API contract in [05-openapi.yaml](../05-openapi.yaml) is the authoritative source for routes, payloads, and data contracts.

## Integration principles

- Use the OpenAPI schema for endpoint naming and response structure
- Align frontend state models with backend response payloads
- Keep request/response validation in place during UI wiring
- Avoid hidden contract assumptions between screens and backend modules

## Core integration areas

### Learner flows
- course listing
- course detail
- my learning
- lesson tracking
- quiz result submission
- AI tutor interaction

### Instructor flows
- course creation and publishing
- lesson configuration
- learner analytics

### Corporate/admin flows
- employee management
- learning path assignment
- payment and moderation audits

## Validation steps

Before finalizing screen UI:

- confirm the endpoint path and HTTP method
- validate mocked data against response schema
- check loading + error scenarios
- verify success states after actions such as payment and course approval

## Handoff note

Do not build screens with assumptions that differ from the contract in [05-openapi.yaml](../05-openapi.yaml). Contract changes must be reviewed with both product and design before implementation continues.
