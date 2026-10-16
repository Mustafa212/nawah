#!/usr/bin/env bash
# The template, filled as fixtures in English and Arabic, passes report.sh check and prints to PDF;
# broken variants are refused with the right message and get no PDF. Needs node and Edge/Chrome/Chromium.
# Usage: bash tests/template_test.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
r="$here/scripts/report.sh"
fill="$here/tests/fixture/fill.js"
base="${TMPDIR:-${TEMP:-/tmp}}"
command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
top="$base/nawah template (test)"; d="$top/تقرير"
rm -rf "${top:?}"; mkdir -p "$d"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }

node "$fill" "$d/en.html"
node "$fill" "$d/ar.html" "$here/tests/fixture/data-ar.json"
check "the English report checks ok" '[ "$(bash "$r" check "$d/en.html")" = ok ]'
check "the Arabic report checks ok" '[ "$(bash "$r" check "$d/ar.html")" = ok ]'
check "the Arabic report is right-to-left" 'bash "$r" values "$d/ar.html" | grep -q "\"dir\":\"rtl\""'
check "values carry the base break-even and the version" 'v="$(bash "$r" values "$d/en.html")"; grep -q "\"base.breakEvenMonth\"" <<< "$v" && grep -q "\"version\":1" <<< "$v"'
check "the English PDF is written" 'bash "$r" pdf "$d/en.html" "$d/report v1.pdf" >/dev/null && [ "$(head -c 4 "$d/report v1.pdf")" = "%PDF" ]'
check "the Arabic PDF is written" 'bash "$r" pdf "$d/ar.html" "$d/تقرير v1.pdf" >/dev/null && [ "$(head -c 4 "$d/تقرير v1.pdf")" = "%PDF" ]'
check "the unfilled template is refused" 'bash "$r" check "$here/skills/nawah/assets/report-template.html" 2>&1 | grep -q "has no content yet"'

for k in slot key source xl level; do node "$fill" "$d/bad-$k.html" --break "$k"; done
check "an empty section is named" 'bash "$r" check "$d/bad-slot.html" 2>&1 | grep -qF "section \"risks\" has no content yet"'
check "an unknown figure is named" 'bash "$r" check "$d/bad-key.html" 2>&1 | grep -qF "unknown figure data-k=\"base.revenueY9\""'
check "a missing source is named" 'bash "$r" check "$d/bad-source.html" 2>&1 | grep -qF "citation data-src=\"99\" names a source that is not in sources"'
check "an XL capability is named" 'bash "$r" check "$d/bad-xl.html" 2>&1 | grep -qF "is XL: split it"'
check "a bad confidence level is named" 'bash "$r" check "$d/bad-level.html" 2>&1 | grep -qF "needs its confidence set"'
check "a broken report gets no PDF" '! bash "$r" pdf "$d/bad-key.html" "$d/bad.pdf" 2>/dev/null && [ ! -e "$d/bad.pdf" ]'

rm -rf "${top:?}"
if [ "$failures" -eq 0 ]; then echo "template tests pass"; else echo "$failures template test(s) failed"; exit 1; fi
