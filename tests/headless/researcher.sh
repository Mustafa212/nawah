#!/usr/bin/env bash
# Headless: the researcher agent returns cited findings in its exact format. Uses web search; costs tokens.
# Usage: bash tests/headless/researcher.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
O="$base/nawah-headless-researcher"; rm -rf "${O:?}"; mkdir -p "$O"
prompt="Use the nawah:researcher agent with the brief below. Then print its report exactly as it returned it, with nothing before or after.

Topic: pricing-regulation
Target market: Egypt    Currency: EGP    Date: $(date +%Y-%m-%d)
<brief>
$(cat "$P/tests/fixture/idea/brief.md")
</brief>"
(cd "$base" && claude -p "$prompt" --plugin-dir "$P" --allowedTools "Agent" "WebSearch" "WebFetch") > "$O/out.txt" 2>&1
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
check "findings heading" 'grep -q "^## Findings — pricing-regulation" "$O/out.txt"'
check "at least 3 findings with a link and a date" '[ "$(grep -E "^\| *[0-9]+ *\|.*https?://.*\| *20[0-9]{2}-[0-9]{2}-[0-9]{2} *\|" "$O/out.txt" | wc -l)" -ge 3 ]'
check "confidence values" 'grep -Eq "\| *(High|Medium|Low) *\|" "$O/out.txt"'
check "not-found section" 'grep -q "^## Not found" "$O/out.txt"'
[ "$failures" -eq 0 ] && echo "headless researcher passes" || { echo "see $O/out.txt"; exit 1; }
