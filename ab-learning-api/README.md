# AB Learning API — Go Backend

Real, compiling Go backend implementing screens **03 (Login)**, **04
(Register)**, **08 (Home)**, **09/10 (Explore/Search)** against a real MySQL
database — this is the other half of the Flutter scaffold's `ApiClient`
interface. Verified end-to-end while building this: schema applies cleanly,
seed data loads, and every endpoint below returns real, correct data from
real SQL queries (see "What's been verified" at the bottom).

## Run it

```bash
cp .env.example .env
make up          # docker compose: MySQL + API together
curl http://localhost:8080/health
```

That's it — `db/init/*.sql` runs automatically on MySQL's first boot, so the
seed learner account and two demo courses are there immediately.

Seed login (same credentials as the Flutter app's `MockApiClient`, on
purpose):
```
learner@ablearning.com / password123
```

To run the Go process directly against Docker's MySQL instead (faster
iteration, no image rebuild per change):
```bash
docker compose up -d mysql
make run
```

## What's actually implemented

| Endpoint | Screen | Notes |
|---|---|---|
| `POST /api/v1/auth/login` | 03 | bcrypt-verified, issues a real JWT |
| `POST /api/v1/auth/register` | 04 | creates `users`+`profiles`+`wallets` rows in one transaction |
| `GET /api/v1/me` | 30 | JWT-protected |
| `GET /api/v1/home` | 08 | 4 real queries: continue-learning, recommended, live, career progress |
| `GET /api/v1/courses` | 09 | filters by `category`/`level`, paginated |
| `GET /api/v1/courses/{id}` | 11 | |
| `GET /api/v1/search?q=` | 10 | |

Every other endpoint in `05-openapi.yaml` follows the exact same 4-file
pattern (`model.go` → `repository.go` → `service.go` → `handler.go`) — see
"Adding the next domain" below.

## Architecture

```
cmd/api/main.go          — wires config + DB + JWT + every domain, starts the server
internal/config/         — env loading (.env optional, real env vars always win)
internal/platform/       — DB pool, JSON envelope + AppError, logging/recover/CORS/auth middleware
pkg/jwtx/                — JWT issue/verify, framework-agnostic
internal/auth/           — screens 01–07 (register/login/me implemented; OTP/forgot are stubs)
internal/home/           — screen 08
internal/courses/        — screens 09–11 (catalog, browsing)
db/init/                 — 01_schema.sql (= blueprint's 04-schema.sql) + 02_seed.sql, auto-run by MySQL's docker image
```

No framework (chi/gin/echo) — Go 1.22's `http.ServeMux` already supports
`"POST /api/v1/auth/login"`-style method+path patterns and path parameters
(`r.PathValue("id")`), which covers everything this API needs without an
extra dependency.

### Adding the next domain (e.g. Quizzes, screen 14)

1. `internal/quizzes/{model,dto,repository,service,handler}.go` — copy
   `internal/courses/` as a starting point, it's the simplest existing
   domain.
2. Two lines in `cmd/api/main.go`:
   ```go
   quizzesRepo := quizzes.NewRepository(db)
   quizzesService := quizzes.NewService(quizzesRepo)
   quizzes.NewHandler(quizzesService).RegisterRoutes(mux, requireAuth)
   ```
3. Add the corresponding rows to `05-openapi.yaml` if they're not already
   there (most already are — this backend is catching up to a spec that
   was written first).

## A note on `go.mod`'s replace directives

```
replace filippo.io/edwards25519 => github.com/FiloSottile/edwards25519 v1.1.0
replace golang.org/x/crypto => github.com/golang/crypto v0.31.0
```

These exist because this project was built and verified inside a sandboxed
environment that only allows outbound access to `github.com` and a short
allowlist of other domains — not `proxy.golang.org`, `filippo.io`, or
`golang.org` directly. Both replace targets are the *exact same code*,
just mirrored on GitHub, with matching checksums already in `go.sum`. On a
normal machine with full internet access this isn't needed, but it's also
completely harmless to leave in — delete both lines and run `go mod tidy`
if you'd rather fetch from the canonical source.

## What's been verified (not just "should work")

Built and run against a real MySQL-compatible server as part of producing
this scaffold:
- `db/init/01_schema.sql` applies with zero errors (45 tables, all FKs).
- `db/init/02_seed.sql` loads: roles, 2 instructors, 1 learner (with
  wallet), 2 courses with real curriculum, 1 in-progress enrollment, 1
  upcoming live session.
- `go build ./...` and `go vet ./...` both exit clean.
- Real HTTP round-trips against the running server:
  - Login with seed credentials → 200 + valid JWT.
  - Login with wrong password → 401 `INVALID_CREDENTIALS`.
  - `GET /home` with that JWT → the exact JSON shape
    `lib/features/home/models/home_feed.dart` on the Flutter side expects,
    populated with the real seeded course/live data.
  - `GET /home` with no `Authorization` header → 401 `UNAUTHORIZED`.
  - Register a new user → 201; registering the same email again → 409
    `CONFLICT`; logging in as the new user → 200 + JWT.
  - `GET /courses` (no auth needed) and `GET /search?q=Go` both return the
    seeded courses correctly.

## Wiring the Flutter app to this instead of the mock

One line, in `lib/core/di/providers.dart`:

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  return DioApiClient(baseUrl: 'http://localhost:8080/api/v1');
  // was: return MockApiClient();
});
```

`DioApiClient` already exists in the Flutter scaffold and expects exactly
the response shapes this API returns — no other Flutter code changes.

## Known gaps (by design — keeps this reviewable)

- OTP verification (05) and Forgot Password (07) aren't implemented —
  `auth.Repository`/`Service` has room for them, following the same
  pattern as Login/Register.
- Refresh tokens are a second signed JWT, not a real rotatable
  server-side-tracked token (see the comment in `internal/auth/service.go`)
  — fine for a scaffold, not for production.
- No automated tests yet (`go test ./...` currently has nothing to run) —
  the verification above was done by hand against a live server; a real
  next step is turning those same curl checks into `httptest`-based Go
  tests per domain.
- Structured logging is `log.Printf`, not `log/slog` — trivial upgrade,
  skipped here to keep the middleware short and readable.
