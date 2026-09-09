# AB LEARNING — Technical Blueprint Implementation

## Runtime topology

The V1 prototype is a modular Go API (`ab-learning-api`) plus a responsive Flutter application (`ab_learning_app`). Both use the `/api/v1` namespace. Local infrastructure is defined in `deployments/docker/docker-compose.yml` for API, MySQL, and Redis.

## Implemented prototype domains

| Blueprint area | Runtime surface |
| --- | --- |
| Identity | `internal/auth`; login and auth service tests |
| Course / learning | `internal/courses`, `internal/learning`, `internal/quiz`, `internal/certificate` |
| AI / career | `internal/future`: AI tutor, assessment, skill result, career path, portfolio, jobs and applications |
| Organization / admin | `internal/future`: corporate dashboard, employees, learning paths, admin dashboard, users, moderation queue, payment list and audit log |
| Flutter web | `web/` runner, route-per-screen prototype, responsive Home dashboard, course/quiz/certificate and Sprint 7–10 workspaces |

## Contract and data assets

- Full logical schema: `04-schema.sql` (identity, course, enrollment, payments/refunds, live, community, AI, career, portfolio, jobs, corporate, wallet and audit entities).
- OpenAPI contract: `05-openapi.yaml` and `ab-learning-api/api/openapi.yaml`.
- API route ownership follows the Blueprint: catalog is `/courses`; learner state is `/enrollments` and `/me/courses`, so catalog and progress handlers do not overlap.

## Verification baseline

```powershell
cd ab-learning-api
go test ./...
go run ./cmd/api

cd ../ab_learning_app
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Deliberate V1 boundaries

The prototype endpoints return in-memory mock data. Database persistence, JWT refresh/role middleware, payment-provider webhooks, media storage, live streaming, AI-provider calls, and real-time chat require provider credentials and deployment configuration; those integrations must not be represented as production-ready until configured and security-tested.
