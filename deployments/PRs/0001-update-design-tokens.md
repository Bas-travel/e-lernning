---
title: "Update design tokens and sync Flutter theme"
labels: design, frontend, flutter
---

## Summary

This PR updates the design tokens and synchronizes the Flutter app theme and hi‑fi mockups.

What I changed:

- `design-tokens.json`: Adjusted `primary` to `#4338CA`, `accent` to `#0EA5E9`, added `pill-*`, `btn-*`, and `card-border` tokens.
- `ab_learning_app/lib/core/theme/colors.dart`: Synced colors with updated tokens and added pill/button/card constants.
- `02-hifi-mockups.html`: Updated CSS `:root` tokens to match the new design tokens (used for handoff previews).

## Before / After (visual)

Replace the placeholders below with screenshots or asset previews when creating the PR:

- Before: `design/visuals/before-tokens.png`  (placeholder)
- After:  `design/visuals/after-tokens.png`   (placeholder)

If you want, run these quick previews locally:

Preview HTML mockups (open in browser):

```bash
# from repo root
open 02-hifi-mockups.html   # macOS
start 02-hifi-mockups.html  # Windows
xdg-open 02-hifi-mockups.html # Linux
```

Preview Flutter theme (hot reload):

```bash
cd ab_learning_app
flutter pub get
flutter run -d chrome   # or your simulator/device
```

## Files changed

- design-tokens.json
- ab_learning_app/lib/core/theme/colors.dart
- 02-hifi-mockups.html

## Testing notes

- Verify primary/secondary/accents across key screens in the browser preview and in the Flutter app.
- Check pill backgrounds (`pill-success-bg`, `pill-warn-bg`, `pill-error-bg`) in course badges and notifications.
- Validate cards render with `--card-border` and check contrast ratios for `--primary` on white backgrounds.

## How to create the PR from this branch (local)

```bash
# create branch and commit
git checkout -b design/tokens-update
git add design-tokens.json ab_learning_app/lib/core/theme/colors.dart 02-hifi-mockups.html
git commit -m "chore(design): update design tokens and sync theme"
git push -u origin design/tokens-update

# create PR using GitHub CLI (recommended)
gh pr create --title "Update design tokens and sync Flutter theme" \
  --body-file deployments/PRs/0001-update-design-tokens.md --base main
```

Or use the UI: push branch and open a PR targeting `main` with the above description.

## Rollback

If anything is incorrect, revert the branch or restore previous token values and create a fixup PR.

---
Drafted by automation — please attach before/after screenshots before merging.
