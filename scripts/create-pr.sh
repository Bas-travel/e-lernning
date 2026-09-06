#!/usr/bin/env bash
# Helper: create branch, commit changes and open PR using GitHub CLI
set -euo pipefail

BRANCH=${1:-design/tokens-update}
TITLE=${2:-"Update design tokens and sync Flutter theme"}
BODY_FILE="deployments/PRs/0001-update-design-tokens.md"

echo "Creating branch $BRANCH"
git checkout -b "$BRANCH"

echo "Staging token and theme files"
git add design-tokens.json ab_learning_app/lib/core/theme/colors.dart 02-hifi-mockups.html

git commit -m "chore(design): update design tokens and sync theme" || true

echo "Pushing branch"
git push -u origin "$BRANCH"

if command -v gh >/dev/null 2>&1; then
  echo "Opening PR with gh"
  gh pr create --title "$TITLE" --body-file "$BODY_FILE" --base main
else
  echo "gh CLI not found; please open a PR manually or install gh: https://cli.github.com/"
  echo "PR body available at $BODY_FILE"
fi
