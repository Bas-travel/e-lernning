# AB LEARNING — Prototype V1

[![CI](https://github.com/Bas-travel/e-lernning/actions/workflows/ci.yml/badge.svg)](https://github.com/Bas-travel/e-lernning/actions/workflows/ci.yml) [![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg)](https://codecov.io/gh/Bas-travel/e-lernning)

AB LEARNING is an online learning platform prototype. This repository contains a Flutter learner application and a Go backend API. The learner application currently uses mock data, while the backend provides API modules for authentication, courses, learning, assessments, certificates, and business operations.

## What's in this workspace

- `ab_learning_app/` — Flutter application containing authentication flows, Home, Explore, Course Detail, Curriculum, Lesson Player, Quiz and Quiz Result, My Learning, and an AI Tutor chat shell. The learner experience currently uses in-memory mock data through `MockRepository`.
- `ab-learning-api/` — Go API backed by MySQL, with JWT authentication, role-protected routes, and modules for learner and business workflows.

## Phase status

- **Phase 1 — Learning foundation:** The main Flutter learner UI and learning flows are implemented using mock data. Integration with the Go API is still pending.
- **Phase 2 — Business and operations:** Backend modules for instructor tools, administration, corporate learning, and employer workflows are implemented and registered. Corresponding Flutter screens and end-to-end integration remain pending.
- **Phase 3 — Scale and reporting:** Further reporting, infrastructure improvements, production integrations, and deployment work remain to be completed.

## Backend status

The Go API (`ab-learning-api/`) uses MySQL and JWT-based authentication with role-protected routes.

Registered backend capabilities include:

- **Authentication:** Registration, login, token refresh, and user profile endpoints.
- **Courses:** Course catalog, search, course details, categories, and curriculum.
- **Learner:** Home data, course enrollment, lesson access, learning progress, and course learning flows.
- **Assessments:** Quiz retrieval, quiz submission, and attempt records.
- **Certificates:** Certificate endpoints and certificate downloads.
- **Instructor:** Course CRUD, section and lesson management, image/video uploads, course submission for review, dashboard, and revenue.
- **Admin:** Course moderation, user management, dashboard, payment records, and refund records.
- **Corporate:** Dashboard, employee management, and learning paths.
- **Employer:** Dashboard, job management, and job applications.

### Current backend limitations

- The Flutter application still uses `MockRepository`; it is not yet connected to the Go API.
- Uploaded media is stored locally on the API server. CDN integration is not implemented.
- Refund operations update application/database records but do not perform actual payment gateway refunds.
- Additional handlers under `internal/future` are not registered by the current API server and should not be considered active API endpoints.

### Run the Go API locally

From the repository root:

```bash
cd ab-learning-api
cp .env.example .env
```

Configure the required database and application environment variables in `.env`, then start the API:

```bash
SEED_DEV=true JWT_SECRET=$(openssl rand -hex 32) go run ./cmd/api
```

The API runs with development seeding only when `SEED_DEV=true` is enabled and the environment is not production. Development seed data is inserted only when the `users` table is empty.

### Development demo accounts

The Go development seed creates the following demo accounts:

| Role | Email |
|---|---|
| Learner | `learner@ablearning.co` |
| Instructor | `instructor@ablearning.co` |
| Corporate Admin | `corpadmin@ablearning.co` |
| Corporate Manager | `corpmanager@ablearning.co` |
| Employer | `employer@ablearning.co` |
| Admin | `admin@ablearning.co` |

**Development password for all accounts:** `Password123!`

These credentials are for local development only. Never enable development seeding or use these credentials in production.

## Next steps

- Connect the Flutter learner flows to the existing Go API endpoints, replacing `MockRepository` where appropriate.
- Complete end-to-end integration for authentication, course enrollment, curriculum, lesson progress, quizzes, and certificates.
- Build and integrate Flutter screens for instructor, admin, corporate, and employer workflows.
- Complete AI Tutor backend integration.
- Improve reporting, media storage, payment gateway integration, and production deployment.

## Run notes

### Flutter application

```bash
cd ab_learning_app
flutter pub get
flutter run
```

### Go API

```bash
cd ab-learning-api
go run ./cmd/api
```

Configure `.env` and ensure MySQL is available before starting the API.

## Codecov token (CI)

หากต้องการให้ CI อัปโหลดผล coverage ไปยัง Codecov ให้ตั้งค่า `CODECOV_TOKEN` ดังนี้:

1. สมัครหรือล็อกอินที่ https://codecov.io และเพิ่ม repository `Bas-travel/e-lernning`
2. เปิดหน้า repository settings บน Codecov แล้วคัดลอก Repository Upload Token
3. ไปที่ GitHub repository → `Settings` → `Secrets and variables` → `Actions`
4. เลือก `New repository secret`
   - **Name:** `CODECOV_TOKEN`
   - **Value:** วาง token ที่คัดลอกจาก Codecov

ตัวอย่างการตั้งค่าด้วย GitHub CLI:

```bash
gh secret set CODECOV_TOKEN --body "<your-codecov-token>" --repo Bas-travel/e-lernning
```

อย่าใส่ token จริงลงใน source code หรือ commit ลง repository ให้เก็บไว้ใน GitHub Secrets เท่านั้น

## Codecov badge

ตัวอย่าง Codecov badge สำหรับ repository นี้:

**Public repository:**

```markdown
[![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg)](https://codecov.io/gh/Bas-travel/e-lernning)
```

**Private repository (if a token is required):**

```markdown
[![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg?token=<CODECOV_TOKEN>)](https://codecov.io/gh/Bas-travel/e-lernning)
```

เลือกใช้ badge ให้ตรงกับการตั้งค่า repository บน Codecov และอย่าเผยแพร่ token จริงในไฟล์ README หรือ source code.
