# AB LEARNING — Prototype V1 (scaffold)

[![CI](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml/badge.svg)](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml) [![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg)](https://codecov.io/gh/ablearning/ab-learning)

This workspace contains scaffolding + Phase 1 (learning foundation) screens for
the AB LEARNING prototype described in `01-screens-spec.md` and
`developer-handoff/01-implementation-overview.md`.

## What's in this workspace
- `ab_learning_app/` — Flutter app: auth flow, Home, Explore, Course Detail,
  Curriculum, Lesson Player, Quiz + Quiz Result, My Learning, and an AI Tutor
  chat shell. Currently backed by in-memory mock data
  (`lib/data/mock/mock_repository.dart`) so the full flow can be demoed
  without the backend running.
- `ab-learning-api/` — Go API scaffold (`auth`, `courses` modules so far).

## Phase status
- **Phase 1 — learning foundation:** UI complete on mock data (Home, Explore,
  Course Detail, Curriculum, Lesson flow, Quiz/Result, My Learning, AI Tutor
  shell). Not yet wired to the Go API.
- **Phase 2 — business & operations:** not started (Instructor dashboard,
  Course management, Corporate dashboards, User management, Payment views).
- **Phase 3 — scale & reporting:** not started.


## Backend status (Phase 3)
Go API (`ab-learning-api/`) now runs on MySQL with JWT auth + role-based access:
- **Instructor:** courses CRUD, sections/lessons, image/video upload (MIME-sniffed, local storage), submit for review, dashboard, revenue
- **Admin:** course moderation (approve/reject), user management (edit/suspend), payments + refunds, dashboard
- **Corporate:** dashboard, employee management (admin-only writes), learning paths
- **Employer:** dashboard

Run locally:
```bash
cd ab-learning-api
cp .env.example .env            # then export the vars (or set them in your shell)
SEED_DEV=true JWT_SECRET=$(openssl rand -hex 32) go run ./cmd/api
```
Demo logins (dev seed, password `Password123!`): `learner@`, `instructor@`, `corpadmin@`, `corpmanager@`, `employer@`, `admin@` + `ablearning.co`.

**Not yet done in Phase 3:** the Flutter app still uses `MockRepository` — screens are not wired to this API yet.

## Next steps
- Wire Phase 1 screens to real `ab-learning-api` endpoints (see `api/openapi.yaml`)
  in place of `MockRepository`.
- Expand Go API with the endpoints Phase 1 screens expect (courses curriculum,
  lesson progress, quiz submission, AI tutor).
- Begin Phase 2 screens once Phase 1 is API-backed.

## Run notes
- Flutter: `cd ab_learning_app && flutter pub get && flutter run`
- Go API: `cd ab-learning-api && go run ./cmd/api`

## Codecov token (CI)

ถ้าต้องการให้ CI อัปโหลดผล coverage ไปที่ Codecov ให้ตั้งค่าสำหรับ `CODECOV_TOKEN` ดังนี้:

1. สมัคร/ล็อกอินที่ https://codecov.io และเพิ่ม repository ของคุณ (หรือเลือก repo ที่มีอยู่)
2. ในหน้า Settings ของโปรเจคบน Codecov หา **Repository Upload Token** (หรือ token ที่ Codecov ให้สำหรับ repo นั้น) แล้วคัดลอกค่า
3. ใน GitHub repo ให้ไปที่ `Settings` → `Secrets and variables` → `Actions` → `New repository secret`
	- ใส่ `Name`: `CODECOV_TOKEN`
	- ใส่ `Value`: (paste) token ที่ได้จาก Codecov

ตัวอย่างการตั้งค่าด้วย `gh` CLI:

```bash
gh secret set CODECOV_TOKEN --body "<your-codecov-token>" --repo ablearning/ab-learning
```

โปรดอย่าเผยแพร่ token นี้ในโค้ด — เก็บเป็น secret ใน GitHub เท่านั้น.

## Codecov badge

ตัวอย่าง badge สำหรับ Codecov (เปลี่ยน `ablearning/ab-learning` และ `main` เป็น repo/branch ของคุณ):

- Public repo (no token required):

	```md
	[![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg)](https://codecov.io/gh/ablearning/ab-learning)
	```

- Private repo (if Codecov requires a token in the badge URL):

	```md
	[![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg?token=<CODECOV_TOKEN>)](https://codecov.io/gh/ablearning/ab-learning)
	```

วางบรรทัดที่ต้องการใน `README.md` และอย่าใส่ token แบบสาธารณะในไฟล์ — ใช้ GitHub secrets/Codecov settings แทน.
