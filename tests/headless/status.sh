#!/usr/bin/env bash
# Headless: /nawah status lists every idea in NAWAH_HOME with its step. Costs a few cents of tokens.
# Usage: bash tests/headless/status.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
H="$base/nawah-headless-status"; rm -rf "${H:?}"; mkdir -p "$H/ideas/qahwa-points" "$H/ideas/clinic-booking"
cat > "$H/ideas/qahwa-points/state.md" <<'EOF'
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
Gates: brief 2026-10-10, report -, backlog -
Stale: none
Next: Review report version 1
Last updated: 2026-10-12T10:00Z
EOF
cat > "$H/ideas/clinic-booking/state.md" <<'EOF'
Idea: Online booking for small clinics
Slug: clinic-booking
Mode: existing
Project: clinic
Repos: C:/work/clinic
Audience: management
Language: ar
Backlog language: en
Market: Saudi Arabia
Currency: SAR
Team: 3 developers
Prepared by: IT department
Step: done
Gates: brief 2026-09-01, report v2 2026-09-03, backlog 2026-09-05
Stale: none
Next: none
Last updated: 2026-09-05T16:20Z
EOF
# The prompt goes right after -p: --allowedTools and --add-dir take several values and would swallow it.
out="$(cd "$base" && NAWAH_HOME="$H" claude -p "/nawah:nawah status" --plugin-dir "$P" --add-dir "$H" \
  --allowedTools "Read" "Glob" "Grep" "Bash(printenv *)" "Bash(ls *)" 2>&1)"
printf '%s\n' "$out" > "$H/out.txt"
failures=0
for s in "Qahwa Points" "Online booking for small clinics" "investor" "management" "done"; do
  if grep -qi -- "$s" "$H/out.txt"; then echo "ok   output names: $s"; else echo "FAIL output lacks: $s"; failures=$((failures + 1)); fi
done
grep -Eq '\| *5[ |(]' "$H/out.txt" && echo "ok   step 5 shown in a table cell" || { echo "FAIL step 5 not in a table cell"; failures=$((failures + 1)); }
[ "$failures" -eq 0 ] && echo "headless status passes" || { echo "see $H/out.txt"; exit 1; }
