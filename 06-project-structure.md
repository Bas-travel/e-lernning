# AB LEARNING — Flutter + Go Project Structure

Structured to map 1:1 onto the 43 screens and the schema/API above — every feature folder corresponds to a section in `01-screens-spec.md` and a tag in `05-openapi.yaml`.

## Flutter app (`ab_learning_app/`)

```
ab_learning_app/
├── lib/
│   ├── main.dart
│   ├── app.dart                      # MaterialApp, theme, router
│   ├── core/
│   │   ├── theme/                    # colors.dart, typography.dart, radius.dart — tokens from §2
│   │   ├── network/                  # dio_client.dart, api_endpoints.dart, interceptors/
│   │   ├── router/                   # go_router config, one route per screen ID
│   │   ├── storage/                  # secure_storage.dart (tokens), local_cache.dart
│   │   ├── di/                       # get_it / riverpod providers
│   │   ├── widgets/                  # shared: CourseCard, LiveCard, JobCard, Badge, ProgressBar...
│   │   └── utils/
│   ├── features/
│   │   ├── auth/                     # 01–07
│   │   │   ├── data/ (models, repositories)
│   │   │   ├── domain/ (entities, use_cases)
│   │   │   └── presentation/ (splash, onboarding, login, register, otp, interests, forgot_password) screens + state
│   │   ├── home/                     # 08
│   │   ├── explore/                  # 09–10
│   │   ├── course/                   # 11–16 (detail, curriculum, player, quiz, quiz_result, certificate)
│   │   ├── live/                     # 17–18
│   │   ├── community/                # 19–20
│   │   ├── ai_tutor/                 # 21
│   │   ├── career/                   # 22–24 (assessment, skill_result, career_path)
│   │   ├── portfolio/                # 25
│   │   ├── jobs/                     # 26–27
│   │   ├── wallet/                   # 28
│   │   ├── gamification/             # 29
│   │   ├── profile/                  # 30
│   │   ├── instructor/               # 31–35
│   │   ├── corporate/                # 36–38
│   │   ├── employer/                 # 39
│   │   └── admin/                    # 40–43
│   └── l10n/                         # app_th.arb, app_en.arb
├── test/                             # unit + widget tests mirroring lib/features
├── integration_test/                 # golden flow tests: purchase, certificate, apply
├── assets/
│   ├── icons/  ├── illustrations/  └── fonts/ (Inter, Noto Sans Thai)
├── pubspec.yaml
└── analysis_options.yaml
```

**State management:** Riverpod (or Bloc if the team prefers explicit event/state) — one `*_provider.dart` / `*_bloc.dart` per screen, injected via `core/di`. **Responsive:** a single `ResponsiveLayout` widget switches between `MobileScaffold` (bottom nav) and `DesktopScaffold` (sidebar) per the breakpoints in §5 of the overview — screens are written once and composed into both.

**Package suggestions:** `go_router`, `flutter_riverpod` (or `flutter_bloc`), `dio`, `freezed` + `json_serializable` for models, `flutter_secure_storage`, `cached_network_image`, `video_player` / `chewie` (screen 13), `webrtc`/`agora_rtc_engine` (screen 18 live), `fl_chart` (dashboards 31/36/40), `flutter_svg`.

---

## Go backend (`ab-learning-api/`)

```
ab-learning-api/
├── cmd/
│   └── api/
│       └── main.go                   # entrypoint: load config, wire deps, start server
├── internal/
│   ├── config/                       # env loading (viper)
│   ├── server/                       # http server bootstrap, middleware chain, graceful shutdown
│   ├── middleware/                   # auth (JWT), logging, recover, rbac, rate_limit, cors
│   ├── auth/                         # handlers, service, repository — /auth/*, /me
│   ├── users/                        # admin user mgmt — /admin/users/*
│   ├── courses/                      # catalog, curriculum — /courses/*, /search
│   ├── learning/                     # enrollments, lessons, progress — /me/courses, /lessons/*
│   ├── quiz/                         # /quizzes/*
│   ├── certificates/                 # /certificates/*
│   ├── commerce/                     # orders, payments, coupons, refunds — /orders, /payments, /admin/payments/*
│   ├── live/                         # /live/*
│   ├── community/                    # /community/*
│   ├── ai/                           # /ai/tutor — wraps LLM provider client
│   ├── career/                       # skills, assessments, career paths — /skills/*, /career-paths/*
│   ├── portfolio/                    # /portfolio
│   ├── jobs/                         # /jobs/*
│   ├── wallet/                       # /wallet/*
│   ├── gamification/                 # points, badges, leaderboard
│   ├── instructor/                   # /instructor/*, /course-sections, /lessons (author-side)
│   ├── corporate/                    # /corporate/*
│   ├── employer/                     # /employer/*
│   ├── admin/                        # /admin/dashboard, /admin/courses/*
│   ├── notification/                 # push/email dispatch, in-app notifications
│   └── platform/                     # audit_logs, reports — cross-cutting
├── pkg/
│   ├── httpx/                        # response envelope, error mapping (matches Error schema)
│   ├── validator/
│   ├── jwtx/
│   └── mysqlx/                       # connection pool, migrations runner
├── db/
│   ├── migrations/                   # numbered .sql files generated from 04-schema.sql
│   └── seed/                         # mock data loader (matches §09 Mock Data Set V1)
├── api/
│   └── openapi.yaml                  # = 05-openapi.yaml, served at /docs via swagger-ui
├── deployments/
│   ├── docker/                       # Dockerfile, docker-compose.yml (api + mysql + redis)
│   └── k8s/                          # base manifests (optional, later phase)
├── go.mod
└── go.sum
```

**Package-per-domain rule:** each `internal/<domain>/` folder is self-contained — `handler.go` (HTTP), `service.go` (business logic), `repository.go` (MySQL via `sqlx` or `gorm`), `model.go` (structs matching `04-schema.sql` tables), `dto.go` (request/response, matching `05-openapi.yaml` schemas). No domain imports another domain's `repository.go` directly — cross-domain reads go through the other domain's `service.go` to keep boundaries enforceable as the team grows.

**Suggested stack:** `chi` or `gin` for routing, `sqlx` + raw SQL (matches the hand-written schema better than a heavy ORM), `golang-migrate` for migrations, `zap` for logging, `viper` for config, `redis` for session/rate-limit cache, JWT (access + refresh) for auth matching the Flutter `secure_storage` token pair.

**Mapping check:** every `internal/<domain>` package name matches an OpenAPI tag, and every handler's request/response struct matches a schema in `05-openapi.yaml` — keeps API drift from Figma/DB to code close to zero as the prototype moves into Sprint 1 (`Authentication`) per the source spec's development order.

---

## Run & Development Guide (Local)

This section contains the minimal commands and env variables to get the prototype running locally (backend + frontend) using the provided schema and seed data.

Prerequisites:
- Install Go >= 1.20, MySQL 8+, Redis (optional), Docker (optional), Flutter SDK (stable channel)
- Ensure `mysql` cli is available and a local `ablearning` database can be created by your MySQL user

1) Prepare database & run migrations

```bash
# create database (if not using docker-compose)
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS ablearning CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# run migrations (if using golang-migrate locally)
# example: migrate -path db/migrations -database "mysql://root:password@tcp(127.0.0.1:3306)/ablearning" up
```

2) Load seed data (mock data)

```bash
# load core seeds
mysql -u root -p ablearning < d:/Project/Ablearnningonline/db/seed/seed.sql
# load lessons & quizzes
mysql -u root -p ablearning < d:/Project/Ablearnningonline/db/seed/lessons_and_quizzes.sql
```

3) Run the Go API (development)

Environment variables (example `.env` / export):
- `AB_ENV=development`
- `DB_DSN=root:password@tcp(127.0.0.1:3306)/ablearning?parseTime=true&charset=utf8mb4`
- `JWT_SECRET=replace_with_random_secret`
- `REDIS_URL=redis://127.0.0.1:6379/0` (optional)
- `PORT=8080`

Run:
```bash
cd ab-learning-api/cmd/api
go run .
# or with Docker: docker compose -f deployments/docker/docker-compose.yml up --build
```

4) Run the Flutter app (development)

Install deps and run on device/emulator:
```bash
cd ab_learning_app
flutter pub get
flutter run -d chrome   # web quick preview
flutter run -d <device> # mobile
```

5) Useful commands

- Run backend tests:
```bash
cd ab-learning-api
go test ./... 
```
- Run Flutter tests:
```bash
cd ab_learning_app
flutter test
```
- Format code:
```bash
gofmt -w ./...    # backend
flutter format .   # frontend
```

## Environment & Configuration

Keep environment-specific overrides in `config/` for the backend and use `.env.example` in both services. Key configs:
- `DB_DSN` — MySQL DSN
- `JWT_SECRET` — JWT signing secret
- `STORAGE_BUCKET` — optional for assets
- `LLM_PROVIDER_API_KEY` — for AI tutor
- `STRIPE_API_KEY` / `PAYMENT_PROVIDER` — for payments staging

## Developer workflow & conventions

- Branching: `feature/<ticket-number>-short-desc`, PRs into `develop` then `main` for release.
- Commit messages: Use conventional commits (feat/fix/docs/chore) for easy changelog generation.
- API changes: Update `05-openapi.yaml` first, then backend handler signatures and tests.
- DB schema changes: Add new numbered migration in `ab-learning-api/db/migrations/` and document the migration in the PR description.
- Seeds: Keep `db/seed/*.sql` idempotent (use INSERT ... ON DUPLICATE KEY UPDATE). Do not store production secrets in seed files.

## Developer handoff checklist (for designers → devs)

- Finalize `02-hifi-mockups.html` tokens or export approved Figma tokens.
- Confirm `design-tokens.json` values and push token sync PR that updates `ab_learning_app/lib/core/theme/colors.dart`.
- Verify OpenAPI contract: run Swagger UI locally at `/docs` and confirm example responses for key flows (login, get course, enroll, purchase).

## Next steps (recommended)

- Add CI: run linters and tests for backend & frontend (GitHub Actions).
- Add small Docker Compose for local dev (api + mysql + redis) in `deployments/docker`.
- Create Postman collection from `05-openapi.yaml` and attach example auth token for quick demos.

---

If you want, I'll: (pick one) generate Docker Compose for local dev, create `.env.example` files, or scaffold a basic GitHub Actions CI workflow. Which should I do next? 
