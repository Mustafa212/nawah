#!/usr/bin/env bash
# Headless: /nawah resume at step 5 builds a report that passes report.sh check, uses bindings and
# citations, and stops at Gate 2 without a PDF. Costs tokens (a full report).
# Usage: bash tests/headless/report.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
H="$base/nawah-headless-report"; I="$H/ideas/qahwa-points"; rm -rf "${H:?}"; mkdir -p "$I"
cp "$P/tests/fixture/idea/brief.md" "$P/tests/fixture/idea/research.md" "$I/"
cat > "$I/state.md" <<'EOF'
Idea: Qahwa Points: shared loyalty for independent coffee shops
Slug: qahwa-points
Mode: new
Project: none
Repos: none
Audience: investor
Language: en
Backlog language: en
Market: Egypt
Currency: EGP
Team: 2 developers, EGP 160,000 per month
Prepared by: Example Ventures
Step: 5
Gates: brief 2026-10-16, report -, backlog -
Stale: none
Next: Write the report
Last updated: 2026-10-16T12:00Z
EOF
(cd "$base" && NAWAH_HOME="$H" NAWAH_NO_OPEN=1 claude -p "/nawah:nawah resume qahwa-points" --setting-sources project,local --plugin-dir "$P" --add-dir "$H" \
  --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Bash(bash *)" "Bash(cp *)" "Bash(printenv *)" "Bash(ls *)") > "$H/out.txt" 2>&1
r="$P/scripts/report.sh"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
check "report.html exists" '[ -f "$I/report.html" ]'
check "the report checks ok" '[ "$(bash "$r" check "$I/report.html")" = ok ]'
check "at least 8 bindings" '[ "$(grep -o "data-k=" "$I/report.html" | wc -l)" -ge 8 ]'
check "at least 8 citations" '[ "$(grep -o "data-src=" "$I/report.html" | wc -l)" -ge 8 ]'
check "investor closing is in the data" 'grep -q "\"audience\": *\"investor\"" "$I/report.html"'
check "no PDF before Gate 2" '! ls "$I"/report-v*.pdf >/dev/null 2>&1'
check "state still at step 5" 'grep -q "^Step: 5" "$I/state.md"'
check "asks for approval" 'grep -qi "approve" "$H/out.txt"'
[ "$failures" -eq 0 ] && echo "headless report passes" || { echo "see $H/out.txt and $I/report.html"; exit 1; }
