#!/usr/bin/env bash

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must be run inside a git repository."
  exit 1
fi

branch="$(git branch --show-current)"

if [[ -z "${branch}" ]]; then
  echo "Unable to detect the current git branch."
  exit 1
fi

remote="$(git config "branch.${branch}.remote" || true)"
remote="${remote:-origin}"

message="${*:-chore: auto push $(date '+%Y-%m-%d %H:%M:%S')}"

git add -A

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "${message}"

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  git push "${remote}" "${branch}"
else
  git push -u "${remote}" "${branch}"
fi

echo "Pushed ${branch} to ${remote}."
