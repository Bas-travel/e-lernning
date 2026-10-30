# AB Learning — Flutter App Scaffold

Real, runnable Flutter project scaffold implementing screens **03 (Login)**
and **08 (Home)** end-to-end against a **mock API** — no backend required to
try it. Structure follows `06-project-structure.md` from the blueprint
package exactly, so every later feature slots into the same pattern.

## Run it

This scaffold ships `lib/`, `test/`, and `pubspec.yaml` only — no
`android/`/`ios/`/`web/` platform folders, so they don't go stale sitting
in a chat download. Generate them once, in place, before the first run:

```bash
flutter create . --project-name ab_learning_app --platforms=ios,android,web
flutter pub get
flutter run -d chrome     # or an emulator / connected device
```

Seed logins (see `lib/core/network/mock_api_client.dart` — same 5 accounts
as the Go backend's `db/init/02_seed.sql`, so nothing changes when you
switch from mock to real):

| Role | Email | Password | Lands on |
|---|---|---|---|
| Learner | `learner@ablearning.com` | `password123` | `/home` |
| Instructor | `krit@ablearning.com` | `password123` | `/instructor` |
| Corporate Admin | `corp@ablearning.com` | `password123` | `/corporate` |
| Employer | `employer@ablearning.com` | `password123` | `/employer` |
| Admin | `admin@ablearning.com` | `password123` | `/admin` |

Any other credentials show the "Invalid credentials" error state, so you
can exercise both the success and error paths without touching a backend.

## Role shell (Instructor / Corporate / Employer / Admin)

One Flutter app, one login screen, five roles — `AuthState.role` (derived
from the JWT's `role` claim) decides everything downstream:

- **`RoleScaffold`** (`lib/core/widgets/role_scaffold.dart`) wraps every
  authenticated screen. Learner gets the 5-item bottom nav (mobile) / 11-item
  sidebar (desktop) from `01-screens-spec.md`; the four business roles get
  a horizontal chip nav (mobile) / role-specific sidebar (desktop) — the
  direct Flutter port of the `render()`-time chrome wrapping in
  `02-hifi-mockups.html`'s navigation engine.
- **`app_router.dart`**'s `redirect` enforces role ownership on every
  navigation attempt (including deep links and browser back/forward on
  web): no session → `/login`; wrong role for the route you're requesting
  → bounced to *your own* home, not an error page. A Learner typing
  `/admin` into the address bar lands back on `/home`.
- Each role's dashboard (`features/{instructor,corporate,employer,admin}/`)
  follows the exact same 4-layer pattern as `features/home/` — copy any of
  them as a starting point for the next screen in that role's section.

## What's actually wired up

- **Design tokens** (`lib/core/theme/`) — colors, radii, and type scale
  copied 1:1 from `00-blueprint-overview.md` §2. Nothing in the UI
  hardcodes a hex value outside these files.
- **Responsive shell** (`lib/core/utils/responsive.dart`) — one
  `ResponsiveBuilder` switches between the mobile (bottom-nav-style) and
  desktop (sidebar) layouts at the 1024px breakpoint from §5, matching the
  Mobile/Desktop toggle in `02-hifi-mockups.html`.
- **State contract** (`home_screen.dart`) — Loading / Empty / Error /
  Success are all implemented for screen 08, per §6 of the blueprint.
- **Mock API layer** (`lib/core/network/mock_api_client.dart`) — returns
  the exact JSON shapes defined in `05-openapi.yaml`'s `AuthTokenResponse`
  and `/home` response schemas, with a simulated 700ms latency so loading
  states are visible.
- **Auth flow** — `AuthController` (Riverpod `StateNotifier`) → `go_router`
  redirect → `HomeScreen`. Tokens persist via `flutter_secure_storage`.

## Switching from mock to the real Go backend

Everything depends on the `ApiClient` interface
(`lib/core/network/api_client.dart`), never on `MockApiClient` directly.
Once the backend in `06-project-structure.md` is deployed, change exactly
one line in `lib/core/di/providers.dart`:

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  return DioApiClient(baseUrl: 'https://api.ablearning.co/api/v1');
  // was: return MockApiClient();
});
```

`DioApiClient` (already written, in the same folder) implements the same
interface and maps errors to the same `ApiException` shape, so no feature,
repository, or screen code needs to change.

## Adding the next screen

Every feature folder follows the same 4-layer shape. To add, say, screen 11
(Course Detail):

```
lib/features/course/
├── models/course_detail.dart        # mirrors the Course schema in 05-openapi.yaml
├── data/course_repository.dart      # wraps ApiClient.getCourse(id)
├── application/course_controller.dart  # FutureProvider<CourseDetail>
└── presentation/
    ├── course_detail_screen.dart
    └── widgets/
        ├── mobile_course_layout.dart
        └── desktop_course_layout.dart
```

Then add one line to `lib/core/router/app_router.dart` and one mock fixture
method to `MockApiClient`. This is the same pattern `auth/` and `home/`
already follow — copy either one as a starting point.

## Known gaps in this scaffold (by design — keeps it reviewable)

- 6 of 43 screens are built (Login, Home, + 4 role dashboards). The rest
  follow the same pattern — see `01-screens-spec.md` for each screen's spec.
- `Home` (screen 08) doesn't use `RoleScaffold` yet — see the note atop
  `home_screen.dart`. Cosmetic, not functional; worth fixing before
  screens 09+ so there's only one chrome pattern to extend.
- `go_router`'s `redirect` reads auth state once per navigation rather than
  reactively; see the note in `app_router.dart` for the one-line upgrade
  path (`GoRouterRefreshStream`).
- Fonts (Inter / Noto Sans Thai) are not bundled — the app falls back to
  the system font until real font files are added under `assets/fonts/`
  and the commented-out block in `pubspec.yaml` is enabled.
- No widget golden tests yet — `test/login_screen_test.dart` covers the
  interactive flow only.
