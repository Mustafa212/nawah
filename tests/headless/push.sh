#!/usr/bin/env bash
# Headless: a push to the file tracker that was interrupted after two items is resumed: the rest is
# created once, nothing twice; a second resume says "Nothing to push". Costs tokens.
# Usage: bash tests/headless/push.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
H="$base/nawah-headless-push"; I="$H/ideas/qahwa-points"; T="$H/tracker file.md"
rm -rf "${H:?}"; mkdir -p "$I" "$H/projects"
cp "$P/tests/fixture/backlog-good.md" "$I/backlog.md"
hash() { bash "$P/scripts/item-hash.sh" "$I/backlog.md" "$1"; }
cat > "$H/projects/demo.md" <<EOF
Project: demo
Repos: none
Tracker: file
URL: $T
Tracker project: demo
Connection: none
Detected: file
Defaults: tags nawah
EOF
cat > "$T" <<'EOF'
# Tracker file

## FILE-1 — Epic: Shop onboarding and stamping
Parent: none
Release: MVP
Priority: -
Points: -
Tags: nawah, nawah:qahwa-points
Depends on: none
Body:
Goal: A shop joins and stamps its first visit in under ten minutes.

## FILE-2 — Feature: Shop sign-up
Parent: FILE-1
Release: MVP
Priority: -
Points: -
Tags: nawah, nawah:qahwa-points
Depends on: none
Body:
Description: A shop owner creates an account and the shop's profile.
EOF
cat > "$I/push-log.md" <<EOF
# Push log — qahwa-points
Target: file $T demo
Approved: 2 epics, 4 features, 5 stories, 2026-10-16

| Local id | Tracker id | URL | Created at | Hash | Pending |
|---|---|---|---|---|---|
| E1 | FILE-1 | $T#FILE-1 | 2026-10-16T19:40Z | $(hash E1) | none |
| F1.1 | FILE-2 | $T#FILE-2 | 2026-10-16T19:40Z | $(hash F1.1) | none |
EOF
cat > "$I/state.md" <<'EOF'
Idea: Qahwa Points: shared loyalty for independent coffee shops
Slug: qahwa-points
Mode: new
Project: demo
Repos: none
Audience: investor
Language: en
Backlog language: en
Stories: mvp
Market: Egypt
Currency: EGP
Team: 2 developers, EGP 160,000 per month
Prepared by: Example Ventures
Step: 7
Gates: brief 2026-10-16, report v2 2026-10-16, backlog 2026-10-16
Stale: none
Next: /nawah resume qahwa-points continues the push
Last updated: 2026-10-16T19:41Z
EOF
run() {
  (cd "$base" && NAWAH_HOME="$H" NAWAH_NO_OPEN=1 claude -p "/nawah:nawah resume qahwa-points" --setting-sources project,local --plugin-dir "$P" --add-dir "$H" \
    --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Bash(bash *)" "Bash(cat *)" "Bash(mkdir *)" "Bash(printenv *)" "Bash(ls *)" "Bash(date *)") > "$H/$1" 2>&1
}
items="$(grep -cE '^#{2,4} [EFS][0-9]' "$I/backlog.md")"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
run out1.txt
check "every item is in the tracker once" '[ "$(grep -c "^## FILE-" "$T")" -eq "$items" ]'
check "tracker ids are unique" '[ "$(grep -o "^## FILE-[0-9]*" "$T" | sort | uniq -d | wc -l)" -eq 0 ]'
check "every item is logged once" '[ "$(grep -cE "^\| (E|F|S)[0-9]" "$I/push-log.md")" -eq "$items" ] && [ "$(grep -oE "^\| (E|F|S)[0-9.]+ " "$I/push-log.md" | sort | uniq -d | wc -l)" -eq 0 ]'
check "the first two items kept their ids" 'grep -qE "^\| E1 \| FILE-1 \|" "$I/push-log.md" && grep -qE "^\| F1.1 \| FILE-2 \|" "$I/push-log.md"'
check "nothing is pending" '! grep -E "^\| (E|F|S)[0-9]" "$I/push-log.md" | grep -qvE "\| none \|$"'
check "every dependency was linked" '[ "$(grep -c "^Depends on: FILE-" "$T")" -eq "$(grep -c "^Depends on: S" "$I/backlog.md")" ]'
check "features and stories have a parent" '! grep -A1 -E "^## FILE-[0-9]+ — (Feature|Story):" "$T" | grep -E "^Parent:" | grep -qv "^Parent: FILE-"'
check "the first two items are kept once" '[ "$(grep -c "^## FILE-1 — Epic: Shop onboarding and stamping$" "$T")" -eq 1 ] && [ "$(grep -c "^## FILE-2 — Feature: Shop sign-up$" "$T")" -eq 1 ]'
check "the idea is done" 'grep -q "^Step: done" "$I/state.md"'
run out2.txt
check "a second resume creates nothing" '[ "$(grep -c "^## FILE-" "$T")" -eq "$items" ]'
check "and says so" 'grep -qi "nothing to push" "$H/out2.txt"'
[ "$failures" -eq 0 ] && echo "headless push passes" || { echo "see $H/out1.txt, $H/out2.txt, $T"; exit 1; }
