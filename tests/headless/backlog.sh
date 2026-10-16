#!/usr/bin/env bash
# Headless: /nawah resume at step 6 writes a backlog that passes the lint, the CSV, and the report's
# backlog update, then stops at Gate 3 with nothing pushed. Costs tokens (backlog plus reviewer).
# Usage: bash tests/headless/backlog.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
H="$base/nawah-headless-backlog"; I="$H/ideas/qahwa-points"; rm -rf "${H:?}"; mkdir -p "$I" "$H/projects"
cp "$P/tests/fixture/idea/brief.md" "$P/tests/fixture/idea/research.md" "$I/"
node "$P/tests/fixture/fill.js" "$I/report.html"
cat > "$H/projects/demo.md" <<EOF
Project: demo
Repos: none
Tracker: file
URL: $H/tracker.md
Tracker project: demo
Connection: none
Detected: file
Defaults: tags nawah
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
Market: Egypt
Currency: EGP
Team: 2 developers, EGP 160,000 per month
Prepared by: Example Ventures
Step: 6
Gates: brief 2026-10-16, report v1 2026-10-16, backlog -
Stale: none
Next: Break the idea into a backlog
Last updated: 2026-10-16T13:00Z
EOF
(cd "$base" && NAWAH_HOME="$H" NAWAH_NO_OPEN=1 claude -p "/nawah:nawah resume qahwa-points" --plugin-dir "$P" --add-dir "$H" \
  --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Agent" "Bash(bash *)" "Bash(node *)" "Bash(printenv *)" "Bash(ls *)") > "$H/out.txt" 2>&1
r="$P/scripts/report.sh"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
check "backlog.md passes the lint" 'node "$P/tests/lint_backlog.js" "$I/backlog.md"'
check "backlog.csv has the generic header" '[ "$(head -1 "$I/backlog.csv" | tr -d "\r\357\273\277")" = "ID,Parent ID,Type,Title,Description,Acceptance Criteria,Priority,Points,Release,Tags" ]'
check "the report has the backlog points" 'grep -q "pointsByRelease" "$I/report.html"'
check "the report is version 2 and checks ok" '[ "$(bash "$r" check "$I/report.html")" = ok ] && bash "$r" values "$I/report.html" | grep -q "\"version\":2"'
check "nothing pushed before Gate 3" '[ ! -s "$H/tracker.md" ] || ! grep -q "^## FILE-" "$H/tracker.md"'
check "no new PDF before Gate 3" '! ls "$I"/report-v2.pdf >/dev/null 2>&1'
# a Stop hook can replace the final message, so the pending Gate 3 is also read from state.md
check "asks for Gate 3" 'grep -qi "approve" "$H/out.txt" "$I/state.md"'
[ "$failures" -eq 0 ] && echo "headless backlog passes" || { echo "see $H/out.txt and $I/backlog.md"; exit 1; }
