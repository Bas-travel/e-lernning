# AB LEARNING — 43 Screen Specification (Wireframe → Hi-Fi ready)

Legend: **M** = Mobile (375×812) · **D** = Desktop (1440×900). Priority: **P0** build first, **P1** after core flow passes, **P2** concept only.

---

## A. AUTHENTICATION

### 01 — Splash [P0]
- **Purpose:** Cold-start entry, session check.
- **M:** Full-bleed centered logo lockup, tagline below, thin progress bar pinned 120px from bottom.
- **D:** Same content inside a centered 480px column on `bg` background; rest of viewport is flat brand color.
- **Components:** Logo, ProgressIndicator.
- **States:** Loading, Offline, Maintenance.
- **Nav:** →02 Onboarding (no session) · →08 Home (session found).
- **API:** `GET /api/v1/app/config` · **Entity:** `app_config`

### 02 — Onboarding [P1]
- **Purpose:** 3-slide value prop (Learn / Build Skills / Get Career).
- **M:** Full-screen illustration top 60%, heading+description below, dot indicator, Skip (top-right) / Next (bottom-right), Get Started replaces Next on slide 3.
- **D:** Split screen — illustration left 55%, copy + controls right 45%, max-width 1200px container.
- **States:** Default, Last slide.
- **Nav:** Next → next slide · Get Started/Skip →03 Login.
- **Entity:** `onboarding_settings`

### 03 — Login [P0]
- **Purpose:** Auth entry.
- **M:** Logo top, stacked Email/Phone + Password inputs, Remember Me checkbox + Forgot Password inline, primary Login button, divider "or continue with", 3 social buttons in a row, Register link at bottom (sticky-safe).
- **D:** Centered 420px card on brand-tinted background; identical field order; social buttons in a row of 3 inside the card.
- **Components:** TextInput, PasswordInput, Checkbox, Button/Primary, SocialButton×3.
- **States:** Default, Loading, Error (inline banner above form).
- **Nav:** Success →08 Home · Register →04 · Forgot →07.
- **API:** `POST /api/v1/auth/login` · **Entities:** `users`, `roles`, `profiles`

### 04 — Register [P0]
- **Purpose:** Account creation.
- **M:** Scrollable form — First/Last name (2-up row), Email, Phone, Password, Confirm Password, Terms checkbox, sticky Create Account button above keyboard.
- **D:** Centered 480px card, same field order, no sticky button (inline at form end).
- **Nav:** Success →05 OTP.
- **API:** `POST /api/v1/auth/register` · **Entities:** `users`, `profiles`

### 05 — OTP Verification [P1]
- **M:** Centered 6-box OTP input, countdown text under it, Resend Code link (disabled until countdown ends).
- **D:** Same, inside 400px centered card.
- **Nav:** Success →06 Interests.
- **API:** `POST /api/v1/auth/verify-otp` · **Entity:** `otp_verifications`

### 06 — Interests / Learning Preferences [P0]
- **Purpose:** Personalization intake.
- **M:** 3 stacked steps in one scroll: interest chips (multi-select grid, 2 cols), level radio group, goal chip group; sticky "Start Learning" CTA.
- **D:** 3-column layout — Interests | Level | Goal, side by side inside a 900px card, single CTA below.
- **Components:** FilterChip (multi-select), RadioGroup.
- **Nav:** →08 Home.
- **API:** `POST /api/v1/me/preferences` · **Entities:** `user_preferences`, `skills`

### 07 — Forgot Password [P1]
- **M/D:** Single email field + Send Reset Link button, centered card.
- **Nav:** Success → confirmation state (same frame, success illustration).
- **API:** `POST /api/v1/auth/forgot-password` · **Entity:** `password_resets`

---

## B. HOME / EXPLORE

### 08 — Home [P0]
- **Purpose:** Personalized landing hub.
- **M:** Top bar (greeting, search, bell, avatar) → Hero prompt card ("What do you want to achieve today?" + AI shortcut) → horizontal-scroll "Continue Learning" card → horizontal-scroll Recommended courses → horizontal-scroll Popular Live → Career Path summary card → Community teaser strip.
- **D:** Sidebar left (240px) + 2-column content: main column (Hero, Continue, Recommended grid 3-up, Live 3-up) + right rail (Career Path progress widget, Community teaser, streak widget).
- **Components:** CourseCard, LiveCard, ProgressCard, CareerCard.
- **Nav:** Course→11 · Continue→13 · Live→17 · AI shortcut→21 · Career→24.
- **API:** `GET /api/v1/home` · **Entities:** `courses`, `enrollments`, `live_sessions`, `career_paths`, `notifications`

### 09 — Explore [P0]
- **M:** Search bar sticky top → horizontal category pill row → Trending row → Recommended grid (1 col, full-width cards) → New/Popular sections; Filter opens as bottom sheet.
- **D:** Search + filter bar full width, category pills below, then 4-column course grid; Filter opens as left drawer (280px) instead of sheet.
- **Filters:** Category, Level, Price, Rating, Duration, Instructor, Language.
- **Nav:** Course→11.
- **API:** `GET /api/v1/courses` · **Entities:** `courses`, `categories`

### 10 — Search [P0]
- **M:** Search input auto-focused, Recent Searches chips, Suggested Keywords, results list (1 col) once query entered, Filter/Sort as bottom sheet triggers.
- **D:** Same input pattern top; results in 3-column grid; Filter/Sort inline as dropdowns beside the input.
- **Nav:** Result→11.
- **API:** `GET /api/v1/search?q=` · **Entities:** `courses`, `instructors`, `skills`

---

## C. COURSE

### 11 — Course Detail [P0]
- **M:** Hero video/image (16:9) → Title, rating, student count → Instructor row (avatar+name, tap→profile) → Price/Discount block → sticky bottom CTA (Buy Now / Start Learning) → scroll sections: Description, What You'll Learn (checklist), Curriculum (accordion preview), Reviews, Related courses carousel.
- **D:** 2-column — left 65% (hero, description, curriculum accordion, reviews, related grid), right 35% sticky card (price, discount, CTA, instructor mini-card, includes list).
- **Nav:** Buy→Checkout/Payment · Start→13 · Instructor→Instructor Profile.
- **API:** `GET /api/v1/courses/{id}` · **Entities:** `courses`, `lessons`, `instructors`, `reviews`

### 12 — Curriculum [P0]
- **M:** Header (title + overall progress bar) → accordion sections, each row shows lock/checkmark/play-state icon + duration; tapping a lesson row expands nothing (navigates directly).
- **D:** Left column identical accordion at 60% width; right 40% shows a persistent "up next" card + progress ring.
- **States:** locked, in-progress, completed per lesson row.
- **Nav:** Lesson→13 · Quiz→14.
- **API:** `GET /api/v1/courses/{id}/curriculum` · **Entities:** `courses`, `course_sections`, `lessons`, `lesson_progress`

### 13 — Video Player / Learning [P0]
- **M:** Video player full-width top (16:9) → lesson title/description below → tabs: Resources / Notes / Discussion / AI Ask → sticky "Next Lesson" bar at bottom.
- **D:** Video 65% left with player controls + transcript/notes/discussion tabs beneath; curriculum list 35% right, scrollable, current lesson highlighted, "Ask AI" floating button bottom-right of video.
- **Components:** VideoPlayer, ProgressBar, Bookmark, DownloadResource.
- **Nav:** Complete→next lesson · AI→21 · Quiz trigger→14.
- **API:** `GET /api/v1/lessons/{id}` · `POST /api/v1/lessons/{id}/progress` · **Entities:** `lessons`, `lesson_progress`, `enrollments`

### 14 — Quiz [P0]
- **M:** Progress text ("3/10") + thin progress bar top → question card → 4 answer options (single-select radio cards) → Previous/Next footer, Submit on last question.
- **D:** Same card centered at 640px max-width; question number rail shown as a horizontal stepper above the card instead of just text.
- **Nav:** Success→15.
- **API:** `GET /api/v1/quizzes/{id}` · `POST /api/v1/quizzes/{id}/submit` · **Entities:** `quizzes`, `quiz_questions`, `quiz_attempts`

### 15 — Quiz Result [P0]
- **M:** Score ring (large %) + Pass/Fail badge top, centered → Skill Analysis bar list (skill vs %) → Recommended Lessons cards → stacked buttons: Continue Learning (primary), Review Answers, Retry (ghost).
- **D:** 2-column — left score ring + pass/fail + buttons; right skill analysis bars + recommended lesson list.
- **API:** `GET /api/v1/quiz-attempts/{id}` · **Entities:** `quiz_attempts`, `skills`

### 16 — Certificate [P0]
- **M:** Certificate preview card (portrait-safe crop) with learner name, course, instructor, date, cert ID, QR code → action row: Download PDF / Share / Add to Portfolio (icon buttons).
- **D:** Certificate rendered at true landscape aspect centered, actions as a button row beneath.
- **API:** `GET /api/v1/certificates`, `GET /api/v1/certificates/{id}/download` · **Entities:** `certificates`, `courses`, `users`

---

## D. LIVE LEARNING

### 17 — Live List [P0]
- **M:** Tabs (Live Now / Upcoming / Completed) sticky under top bar → vertical card list: thumbnail, instructor, title, date/time, viewer count, price/free badge, Join/Register CTA on each card.
- **D:** Tabs + a calendar mini-view top-right; cards in 3-column grid below.
- **API:** `GET /api/v1/live` · **Entity:** `live_sessions`

### 18 — Live Room [P0]
- **M:** Video top (fixed aspect) → tabs Chat / Q&A below → bottom action bar: Raise Hand, Like, Ask Question, Leave.
- **D:** Video 70% left with Mic/Camera/Share/Reaction control bar under it; right panel 30% tabs Chat / Q&A / Participants, always visible (no tab-hiding needed at this width).
- **Nav:** After live ends → Replay (same frame, VOD state).
- **API:** `POST /api/v1/live/{id}/join`, `GET .../chat`, `POST .../questions` · **Entities:** `live_sessions`, `live_attendees`, `live_questions`

---

## E. COMMUNITY

### 19 — Community Home [P1]
- **M:** Tabs (Feed / Groups / Trending / Following) → vertical post feed cards (avatar, text, image, like/comment/share row) → floating "+" button →20.
- **D:** 3-column layout: Groups rail left (200px) · Feed center (main) · Trending/Recommended right rail (280px).
- **API:** `GET /api/v1/community/posts` · **Entities:** `communities`, `community_posts`, `comments`, `likes`

### 20 — Create Post [P1]
- **M:** Title input, multiline content textarea, image/attachment picker row, course/skill tag chip picker, group selector dropdown, sticky Publish button; Save Draft as text link top-right.
- **D:** Centered 600px modal instead of full screen, same field order.
- **Nav:** Success→19.
- **API:** `POST /api/v1/community/posts` · **Entities:** `community_posts`, `comments`, `attachments`

---

## F. AI + CAREER

### 21 — AI Tutor [P0]
- **M:** Chat thread full-height, message bubbles (user right/primary, AI left/neutral), suggested-question chips above input, input bar sticky bottom with quick actions (Explain / Give Example / Quiz Me / Create Practice / Career Advice) as a horizontal chip row above keyboard.
- **D:** Chat 70% center, right rail 30% shows current context (course/lesson/skill) card + the same quick-action buttons stacked vertically.
- **States:** AI Thinking (typing dots), Answer, Error, No Context, Usage Limit (banner + upgrade CTA).
- **API:** `POST /api/v1/ai/tutor` · **Entities:** `ai_conversations`, `ai_messages`, `users`, `lessons`

### 22 — Skill Assessment [P0]
- **M:** Same visual pattern as Quiz (14) but grouped by skill category shown as a header chip ("Programming — Q1/20") + progress bar.
- **D:** Same as Quiz desktop, category shown in a left rail listing all categories with per-category progress.
- **Nav:** Submit→23.
- **API:** `GET /api/v1/skills/assessment`, `POST .../submit` · **Entities:** `skills`, `skill_assessments`, `skill_questions`

### 23 — Skill Result [P0]
- **M:** Overall score ring top → stacked skill bars (Backend 80%, Database 65%…) → Skill Gap callouts (red/amber bars) → Recommended Courses carousel → "Build My Learning Path" sticky CTA.
- **D:** Left column: overall ring + radar chart of skill categories; right column: skill gap list + recommended courses grid.
- **Nav:** →24.
- **API:** `GET /api/v1/skills/result` · **Entities:** `skills`, `skill_results`, `career_paths`

### 24 — Career Path [P0]
- **M:** Career goal header + overall progress bar → vertical timeline of required skills (checked/unchecked icon rows) → Recommended Courses carousel → Projects list → Jobs teaser card.
- **D:** Left 30% vertical timeline (sticky), right 70% content columns: Skills grid, Courses grid, Projects grid, Jobs teaser — matching the timeline stage in view.
- **Nav:** Start Learning→11 · Find Jobs→26.
- **API:** `GET /api/v1/career-paths/{id}` · **Entities:** `career_paths`, `career_path_skills`, `skills`, `courses`

### 25 — Portfolio [P0]
- **M:** Profile header (cover + avatar + name/title) → horizontal Skills chip row → Certificates grid (2 col) → Projects list (card per project) → Experience/Education timeline → Social links row; Edit Profile as top-right icon.
- **D:** Left 30% sticky profile header + social links + Download Resume button; right 70% Skills / Certificates / Projects / Experience sections stacked.
- **API:** `GET /api/v1/portfolio`, `PUT /api/v1/portfolio` · **Entities:** `portfolios`, `portfolio_projects`, `certificates`, `skills`

### 26 — Jobs [P0]
- **M:** Search bar → horizontal filter chip row (Location, Remote, Salary, Skill…) → vertical job card list: title, salary range, location badge, skill tags, match-score pill.
- **D:** Left filter panel (280px, always visible) + job list 2-column card grid.
- **Nav:** Card→27.
- **API:** `GET /api/v1/jobs` · **Entity:** `jobs`

### 27 — Job Detail / Apply [P0]
- **M:** Company header (logo, name, title, salary) → Match Score badge (large %) → Description → Requirements checklist → sticky Apply Now CTA.
- **D:** Left 65% description/requirements, right 35% sticky card: match score, salary, Apply button, company mini-card.
- **Nav:** Success → Application Submitted state (same frame) → Track Application.
- **API:** `GET /api/v1/jobs/{id}`, `POST /api/v1/jobs/{id}/apply` · **Entities:** `jobs`, `job_applications`, `users`, `portfolios`

---

## G. WALLET / PROFILE

### 28 — Wallet [P1]
- **M:** Two balance cards (AB Coin, Cash Wallet) side by side → Top Up / Withdraw buttons → Transaction list (grouped by date) → Coupons section.
- **D:** Balance cards + actions in a top row (3-up incl. payment methods card); transaction table below, full width.
- **API:** `GET /api/v1/wallet`, `GET /api/v1/wallet/transactions` · **Entities:** `wallets`, `wallet_transactions`, `payments`

### 29 — Gamification [P1]
- **M:** Level + XP bar header → Streak flame counter → Badge grid (3 col) → Leaderboard list.
- **D:** Left column Level/XP/Streak card sticky; right column Badges grid + Leaderboard table.
- **API:** `GET /api/v1/gamification` · **Entities:** `user_points`, `badges`, `achievements`, `leaderboards`

### 30 — Profile [P0]
- **M:** Avatar + name + bio header → learning progress ring → menu list (Edit Profile, My Courses, Wallet, Certificates, Portfolio, Settings, Help Center, Logout).
- **D:** Left 30% profile summary card (avatar, bio, progress, skills), right 70% tabbed content mirroring the menu items as sections instead of a list.
- **API:** `GET /api/v1/me` · **Entities:** `users`, `profiles`

---

## H. INSTRUCTOR

### 31 — Instructor Dashboard [P0]
- **M:** KPI cards horizontal scroll (Revenue, Students, Courses, Rating, Completion) → Quick Actions row (Create Course, Go Live, View Revenue) → Revenue chart → Enrollment chart.
- **D:** Sidebar (240px) + KPI cards 5-up top row + 2-column charts (Revenue line, Enrollment bar) + Course Performance table below.
- **API:** `GET /api/v1/instructor/dashboard` · **Entities:** `instructors`, `courses`, `enrollments`, `orders`, `creator_payouts`

### 32 — My Courses [P1]
- **M:** Tabs (Published/Draft/Pending/Rejected) → vertical course cards with status badge + Edit/Duplicate/Analytics/Submit actions in a kebab menu.
- **D:** Tabs + table view (thumbnail, title, students, revenue, rating, status, actions inline).
- **API:** `GET /api/v1/instructor/courses` · **Entity:** `courses`

### 33 — Create Course [P0]
- **Purpose:** 4-step wizard.
- **M:** Stepper header (1 Basic · 2 Pricing · 3 Curriculum · 4 Publish), one step per screen, sticky Continue/Save Draft footer.
- **D:** Left vertical stepper rail (fixed), right content panel per step, same footer pattern.
- **API:** `POST /api/v1/instructor/courses` · **Entity:** `courses`

### 34 — Course Builder [P0]
- **M:** Section/Lesson tree as an accordion list (Add Section/Lesson/Quiz buttons inline) with a "Preview" and "Save" sticky footer; tapping a lesson opens the editor full-screen.
- **D:** 3-pane: left sidebar (sections/lessons/quiz/project tree, 260px), center lesson editor, right settings panel (280px) — classic authoring-tool layout.
- **API:** `POST /api/v1/course-sections`, `POST /api/v1/lessons`, `PUT /api/v1/lessons/{id}` · **Entities:** `courses`, `course_sections`, `lessons`, `quizzes`

### 35 — Instructor Revenue [P1]
- **M:** KPI cards (Gross, Fee, Net, Pending, Paid) stacked 2-up → Monthly revenue bar chart → payout history list.
- **D:** KPI row 5-up + large revenue chart + payout table.
- **API:** `GET /api/v1/instructor/revenue` · **Entities:** `orders`, `payments`, `creator_payouts`

---

## I. CORPORATE

### 36 — Corporate Dashboard [P0]
- **M:** KPI cards scroll (Employees, Active Learners, Completion Rate, Training Hours, Budget) → Learning Progress chart → Department Performance list → Skill Gap chart → "Create Learning Path" CTA.
- **D:** Sidebar + KPI 5-up row + 2-column charts (Progress line, Department bar) + Skill Gap heatmap table.
- **API:** `GET /api/v1/corporate/dashboard` · **Entities:** `organizations`, `organization_users`, `enrollments`, `learning_paths`

### 37 — Employee Management [P0]
- **M:** Search + filter row → employee list (card per employee: name, dept, role, progress bar, status) → floating Add Employee button; row tap opens detail bottom sheet.
- **D:** Full data table (Name, Dept, Role, Courses, Progress, Status, Actions) with bulk-select checkboxes + Import CSV / Add Employee / Assign Course buttons in the table header.
- **API:** `GET/POST /api/v1/corporate/employees` · **Entities:** `organization_users`, `users`, `departments`

### 38 — Learning Path [P0]
- **M:** Path card list (name, goal, course count, employee count, progress bar) → tap opens detail with course list + assigned employees; Create Path floating button.
- **D:** Table/grid of path cards 3-up + a detail drawer (right, 420px) on selection instead of navigating away.
- **API:** `GET/POST /api/v1/corporate/learning-paths` · **Entities:** `learning_paths`, `learning_path_courses`, `organization_users`, `courses`

---

## J. EMPLOYER / ADMIN

### 39 — Employer Dashboard [P1]
- **M:** KPI scroll (Candidates, Applications, Open Jobs, Shortlisted, Hired) → Recommended Talent cards → Skill Trends chart.
- **D:** Sidebar + KPI 5-up + Recommended Talent grid (3-up) + Job Performance chart + Skill Trends chart side by side.
- **API:** `GET /api/v1/employer/dashboard` · **Entities:** `employers`, `jobs`, `job_applications`, `portfolios`

### 40 — Admin Dashboard [P0]
- **M:** KPI scroll (Users, Learners, Instructors, Revenue, GMV, Courses, Live, Reports) → charts stacked (Revenue, User Growth, Course Sales, Active Users) → Quick Menu grid (2 col: User Mgmt, Course Moderation, Payments, Reports, Content, Settings).
- **D:** Sidebar 260px + KPI 8-up (2 rows of 4) + 2×2 chart grid + Quick Menu as a sidebar sub-section instead of a grid.
- **API:** `GET /api/v1/admin/dashboard` · **Entities:** nearly all core entities

### 41 — Course Moderation [P0]
- **M:** Tabs (Pending/Approved/Rejected/Reported) → card list (course, instructor, category, date, status, Preview/Approve/Reject actions) → Reject opens a reason modal.
- **D:** Tabs + data table, row actions inline, Reject opens a right-side drawer with the reason field instead of a modal.
- **API:** `GET /api/v1/admin/courses/pending`, `POST .../approve`, `POST .../reject` · **Entities:** `courses`, `instructors`, `reports`, `audit_logs`

### 42 — Payment Management [P0]
- **M:** KPI scroll (Total, Successful, Failed, Refund, Pending) → filter row (Date/Status/Method) → transaction card list; row tap → detail bottom sheet with Refund/Export actions.
- **D:** KPI 5-up + filter bar + full transaction table (Txn ID, User, Course, Amount, Method, Status, Date) with inline View/Refund/Export actions.
- **API:** `GET /api/v1/admin/payments`, `POST /api/v1/admin/payments/{id}/refund` · **Entities:** `orders`, `order_items`, `payments`, `refunds`

### 43 — User Management [P0]
- **M:** Search + filter → user list (avatar, name, role badge, status) → tap opens detail bottom sheet (Profile/Activity/Orders/Courses/Payments/Reports/Audit tabs).
- **D:** Full data table (Avatar, Name, Email, Role, Status, Joined, Last Login, Actions) + a right-side detail drawer (480px) with the same tab set, opened without leaving the table.
- **API:** `GET /api/v1/admin/users`, `GET/PUT /api/v1/admin/users/{id}`, `POST .../suspend` · **Entities:** `users`, `profiles`, `roles`, `orders`, `payments`, `audit_logs`

---

## Build order recommendation (Figma pages)

1. Build `Components` + `States` libraries first (§03 in overview) — every screen above references them, so build once.
2. Wireframe all **P0** screens (33 screens) in grayscale using the layout notes above — get flow sign-off before any color.
3. Apply hi-fi styling using the design tokens — start with the 12 flagship screens already built out in `02-hifi-mockups.html` as the visual reference, then extend the same components to the rest.
4. P1 screens last, P2 stays as a one-page concept board (no components needed yet).
