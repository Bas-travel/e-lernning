# AB LEARNING — Figma Blueprint Package V1

**Type:** AI Career Learning Platform
**Scope:** 43 core screens, Mobile + Desktop Web
**Stack target:** Flutter / Go / MySQL / REST (OpenAPI)
**Status:** Prototype blueprint — ready for Figma build + backend scaffolding

---

## 1. How this package is organized

| # | File | Purpose |
|---|------|---------|
| 1 | `00-blueprint-overview.md` | This file — sitemap, IA, flows, design tokens |
| 2 | `01-screens-spec.md` | All 43 screens: layout, components, states, API, entities, mobile vs desktop rules |
| 3 | `02-hifi-mockups.html` | Clickable high-fidelity mockup set (mobile + desktop toggle) for the 12 flagship P0 screens |
| 4 | `03-er-diagram.md` | Full ER diagram (Mermaid) + relationship notes for all 43 entities |
| 5 | `04-schema.sql` | MySQL 8 DDL matching the ER diagram, ready to run |
| 6 | `05-openapi.yaml` | OpenAPI 3.0 spec for the endpoints listed in the source spec |
| 7 | `06-project-structure.md` | Flutter app structure + Go backend structure, matching the prototype 1:1 |

Recommended order of use: **01 → 02 → 03/04 → 05 → 06.** Lock the screens first (01+02), then generate schema/API/code scaffolding from what was approved — not the other way around.

---

## 2. Design tokens (source of truth — do not restate ad hoc in Figma layers)

| Token | Value | Usage |
|---|---|---|
| `color/primary` | `#4F46E5` | Primary actions, active nav, links |
| `color/secondary` | `#7C3AED` | Secondary emphasis, AI-related surfaces |
| `color/accent` | `#06B6D4` | Live, highlights, badges |
| `color/success` | `#22C55E` | Paid, passed, completed |
| `color/warning` | `#F59E0B` | Pending, low stock, streak |
| `color/error` | `#EF4444` | Failed, rejected, destructive |
| `color/bg` | `#F8FAFC` | Page background |
| `color/text` | `#0F172A` | Primary text |
| `color/text-secondary` | `#64748B` | Secondary text |
| `type/thai` | Noto Sans Thai | All Thai copy |
| `type/en` | Inter / Aptos | All English copy, numerals |
| `radius/card` | 16px | Cards |
| `radius/button` | 12px | Buttons |
| `radius/input` | 10px | Inputs |
| `radius/modal` | 20px | Modals, sheets |
| `radius/badge` | 999px | Pills, badges |

**Type scale (Inter):** Display 28/36 · H1 22/28 · H2 18/24 · Body 15/22 · Caption 13/18 · Micro 11/16 — all weight 500 for headings, 400 for body, one bold weight (600) reserved for prices and score numbers only.

---

## 3. Sitemap / product architecture

```
                     AB LEARNING
                          |
      ┌───────────────────┼───────────────────┐
      |                    |                   |
    LEARN                LIVE                  AI
      |                    |                   |
   Courses              Classes              Tutor
   Quiz                 Q&A                  Skill Assessment
   Project              Replay               Career Path
      |                    |                   |
      └───────────────────┼───────────────────┘
                          |
                     COMMUNITY
                          |
                     PORTFOLIO
                          |
                        JOBS
                          |
                     EMPLOYMENT
```

**Core promise:** Learn → Practice → Prove → Get Opportunity. Every screen must trace back to one node in this tree — screens that don't (e.g. Wallet) are support screens, not core value screens, and are styled with lower visual weight accordingly.

## 4. Global navigation contract

| Surface | Pattern | Items |
|---|---|---|
| Mobile (Learner) | Bottom nav, 5 items, icon+label, active = primary color fill | Home · Explore · Learn · Community · Profile |
| Mobile top bar | Fixed, 56px | Search icon, Notification (badge), Coin balance, Avatar |
| Desktop (Learner) | Left sidebar, 240px, fixed | Home, Explore, My Learning, Live, Community, AI Tutor, Career, Portfolio, Jobs, Wallet, Settings |
| Desktop (Admin/Corp/Instructor) | Left sidebar, 260px + right drawer for detail/edit | Role-specific menu (see §7 screens 31, 36, 40) |

Role switch (Learner ⇄ Instructor ⇄ Corp Admin ⇄ Employer ⇄ Admin) is a single account-level switcher in the avatar menu — never a separate login.

## 5. Responsive contract

| Breakpoint | Frame | Rule |
|---|---|---|
| Mobile | 375×812 | Bottom nav, 1 column, full-width cards, bottom sheets for filters/actions, sticky CTA above bottom nav |
| Tablet | 768×1024 | 2-column card grids, sidebar collapses to icon rail |
| Desktop | 1440×900 | Sidebar 240px (260px admin) + content max-width 1200px, modals instead of bottom sheets, right drawer for detail views (esp. Admin screens 41–43) |

## 6. State contract

Every data screen ships 5 states minimum: **Default, Loading (skeleton), Empty (with CTA), Error (with retry), Success (post-action confirmation).** Payment, permission, and connectivity screens add: Disabled, Offline, Permission Denied, Payment Failed, Not Found. State variants live as a `State/*` component set per screen in Figma — never a one-off frame.

## 7. Primary flows (already validated against the 43 screens — use as Figma prototype connections)

1. **Purchase:** Home → Explore → Search → Course Detail → Buy Now → Order → Payment → Success → My Learning → Video Player
2. **Learn-to-certificate:** My Learning → Course → Lesson → Video → Quiz → Result → Next Lesson → Course Complete → Certificate → Portfolio
3. **Instructor authoring:** Instructor Dashboard → Create Course → Basic Info → Course Builder → Sections/Lessons/Quiz → Pricing → Preview → Submit → Admin Moderation → Approved → Published
4. **AI career:** Home → Skill Assessment → Skill Result → Skill Gap → Career Path → Recommended Courses → Learning → Project → Certificate → Portfolio → Jobs → Apply
5. **Corporate:** Corp Dashboard → Employee Management → Create Learning Path → Select Courses → Assign Employees → Track Progress → Skill Gap Report → Management Report

Each is built as a single Figma prototype flow (`Flow/01-Purchase` etc.) with the same frame reused across flows rather than duplicated.
