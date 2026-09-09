<!-- # e-lernning
new06092569

>>>>>>> 86d2ddaa793f5184fd815a859db90057726a8c50
# AB LEARNING — Prototype V1 (scaffold)

[![CI](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml/badge.svg)](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml) [![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg)](https://codecov.io/gh/ablearning/ab-learning)

This workspace contains initial scaffolding for the AB LEARNING prototype described in `01-screens-spec.md`.

What I added in this step:
- `ab_learning_app/` Flutter app scaffold (minimal `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, theme tokens)
- `ab-learning-api/` Go API scaffold (minimal `go.mod`, `cmd/api/main.go`)
- Top-level `README.md` and `.gitignore`

Next steps:
- Scaffold the Flutter app screens and routing (Step 2)
- Scaffold the Go backend modules and basic handlers (Step 3)

Run notes:
- Flutter files are starter templates; run `flutter pub get` inside `ab_learning_app` to fetch deps.
- Go server is a minimal stub; run `go run ./cmd/api` inside `ab-learning-api` to start the stub server.

Badge: CI status badge updated for `ablearning/ab-learning`.

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
<<<<<<< HEAD
<!-- >>>>>>> 320bc5e (chore(design): update design tokens and sync theme) -->
=======
>>>>>>> 86d2ddaa793f5184fd815a859db90057726a8c50 -->

diff --git a/README.md b/README.md
index 2381150..1912822 100644
--- a/README.md
+++ b/README.md
@@ -1,13 +1,6 @@
-<<<<<<< HEAD
-<!-- <<<<<<< HEAD -->
-# e-lernning
-new06092569
-<!-- ======= -->
-=======
->>>>>>> 86d2ddaa793f5184fd815a859db90057726a8c50
 # AB LEARNING — Prototype V1 (scaffold)
 
-[![CI](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml/badge.svg)](https://github.com/ablearning/ab-learning/actions/workflows/ci.yml) [![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg)](https://codecov.io/gh/ablearning/ab-learning)
+[![CI](https://github.com/Bas-travel/e-lernning/actions/workflows/ci.yml/badge.svg)](https://github.com/Bas-travel/e-lernning/actions/workflows/ci.yml) [![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg)](https://codecov.io/gh/Bas-travel/e-lernning)
 
 This workspace contains initial scaffolding for the AB LEARNING prototype described in `01-screens-spec.md`.
 
@@ -24,8 +17,6 @@ Run notes:
 - Flutter files are starter templates; run `flutter pub get` inside `ab_learning_app` to fetch deps.
 - Go server is a minimal stub; run `go run ./cmd/api` inside `ab-learning-api` to start the stub server.
 
-Badge: CI status badge updated for `ablearning/ab-learning`.
-
 ## Codecov token (CI)
 
 ถ้าต้องการให้ CI อัปโหลดผล coverage ไปที่ Codecov ให้ตั้งค่าสำหรับ `CODECOV_TOKEN` ดังนี้:
@@ -39,29 +30,25 @@ Badge: CI status badge updated for `ablearning/ab-learning`.
 ตัวอย่างการตั้งค่าด้วย `gh` CLI:
 
 ```bash
-gh secret set CODECOV_TOKEN --body "<your-codecov-token>" --repo ablearning/ab-learning
+gh secret set CODECOV_TOKEN --body "<your-codecov-token>" --repo Bas-travel/e-lernning
 ```
 
-โปรดอย่าเผยแพร่ token นี้ในโค้ด — เก็บเป็น secret ใน GitHub เท่านั้น.
+โปรดอย่าเผยแพร่ token นี้ในโค้ด — เก็บเป็น secret ใน GitHub เท่านั้น
 
 ## Codecov badge
 
-ตัวอย่าง badge สำหรับ Codecov (เปลี่ยน `ablearning/ab-learning` และ `main` เป็น repo/branch ของคุณ):
+ตัวอย่าง badge สำหรับ Codecov (เปลี่ยน `Bas-travel/e-lernning` และ `main` เป็น repo/branch ของคุณ หากย้ายไปคนละที่ในอนาคต):
 
 - Public repo (no token required):
 
 	```md
-	[![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg)](https://codecov.io/gh/ablearning/ab-learning)
+	[![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg)](https://codecov.io/gh/Bas-travel/e-lernning)
 	```
 
 - Private repo (if Codecov requires a token in the badge URL):
 
 	```md
-	[![Codecov](https://codecov.io/gh/ablearning/ab-learning/branch/main/graph/badge.svg?token=<CODECOV_TOKEN>)](https://codecov.io/gh/ablearning/ab-learning)
+	[![Codecov](https://codecov.io/gh/Bas-travel/e-lernning/branch/main/graph/badge.svg?token=<CODECOV_TOKEN>)](https://codecov.io/gh/Bas-travel/e-lernning)
 	```
 
-วางบรรทัดที่ต้องการใน `README.md` และอย่าใส่ token แบบสาธารณะในไฟล์ — ใช้ GitHub secrets/Codecov settings แทน.
-<<<<<<< HEAD
-<!-- >>>>>>> 320bc5e (chore(design): update design tokens and sync theme) -->
-=======
->>>>>>> 86d2ddaa793f5184fd815a859db90057726a8c50
+วางบรรทัดที่ต้องการใน `README.md` และอย่าใส่ token แบบสาธารณะในไฟล์ — ใช้ GitHub secrets/Codecov settings แทน