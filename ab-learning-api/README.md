# AB Learning API

Go API backed by MySQL for the AB Learning Flutter application. It provides
JWT authentication, role protected dashboards, course management and the
Instructor, Corporate, Employer, and Administration MVP workflows.

## Run locally

```bash
cp .env.example .env
docker compose up --build -d
curl http://localhost:8080/api/v1/health
```

The MySQL initialization scripts create schema and development seed accounts
on first startup. Seed accounts use `password123`:

| Role | Email |
|---|---|
| Learner | `learner@ablearning.com` |
| Instructor | `krit@ablearning.com` |
| Corporate Admin | `corp@ablearning.com` |
| Corporate Manager | `manager@ablearning.com` |
| Employer | `employer@ablearning.com` |
| Administration | `admin@ablearning.com` |

These accounts and credentials are for local development only. Change or
remove them before deploying a shared or production environment.

## Connect Flutter

By default, Flutter uses the real API at `http://localhost:8080/api/v1`.
Override it for a device or deployed backend with:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Mock mode is opt-in with `--dart-define=USE_MOCK_API=true`.

## Validation

```bash
go test ./...
go vet ./...
```

Role access is checked by the API middleware and domain handlers. The API
does not treat hidden Flutter navigation as an authorization boundary.
