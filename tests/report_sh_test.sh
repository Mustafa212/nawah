#!/usr/bin/env bash
# report.sh on small pages, in a folder whose name has a space, parentheses and Arabic characters.
# Needs Edge, Chrome or Chromium. Usage: bash tests/report_sh_test.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
r="$here/scripts/report.sh"
base="${TMPDIR:-${TEMP:-/tmp}}"
command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
top="$base/nawah report (test)"; d="$top/تقرير"
rm -rf "${top:?}"; mkdir -p "$d"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
page() { printf '<!doctype html><html><head><meta charset="utf-8"></head><body><pre id="nawah-error"></pre><p>مرحبا</p><script>%s</script></body></html>\n' "$2" > "$d/$1"; }

page ok.html "document.documentElement.setAttribute('data-nawah','ok');var s=document.createElement('script');s.type='application/json';s.id='nawah-values';s.textContent=JSON.stringify({values:{a:'1'}});document.body.appendChild(s);"
page err.html "document.documentElement.setAttribute('data-nawah','error');document.getElementById('nawah-error').textContent='Report error:\n- boom one\n- boom two';"
page none.html ""

check "a good page passes" '[ "$(bash "$r" check "$d/ok.html")" = ok ]'
check "values prints the page's JSON" '[ "$(bash "$r" values "$d/ok.html")" = "{\"values\":{\"a\":\"1\"}}" ]'
check "an error page fails with every message" 'out="$(bash "$r" check "$d/err.html" 2>&1)"; [ $? -eq 1 ] && grep -q "boom one" <<< "$out" && grep -q "boom two" <<< "$out"'
check "a page that never reports fails" 'bash "$r" check "$d/none.html" 2>&1 | grep -q "didn.t finish computing"'
check "pdf writes a PDF" 'bash "$r" pdf "$d/ok.html" "$d/out file.pdf" >/dev/null && [ "$(head -c 4 "$d/out file.pdf")" = "%PDF" ]'
check "pdf refuses an error page" '! bash "$r" pdf "$d/err.html" "$d/err.pdf" 2>/dev/null && [ ! -e "$d/err.pdf" ]'
check "a missing browser exits 2" 'NAWAH_BROWSER=/nonexistent bash "$r" check "$d/ok.html" 2>/dev/null; [ $? -eq 2 ]'
check "the missing-browser message says what to do" 'NAWAH_BROWSER=/nonexistent bash "$r" check "$d/ok.html" 2>&1 | grep -q "NAWAH_BROWSER"'
check "no arguments exits 2" 'bash "$r" 2>/dev/null; [ $? -eq 2 ]'
check "a missing file exits 2" 'bash "$r" check "$d/nope.html" 2>/dev/null; [ $? -eq 2 ]'
check "an output folder that doesn't exist exits 2" 'bash "$r" pdf "$d/ok.html" "$d/no/such/out.pdf" 2>/dev/null; [ $? -eq 2 ]'

rm -rf "${top:?}"
if [ "$failures" -eq 0 ]; then echo "report.sh tests pass"; else echo "$failures report.sh test(s) failed"; exit 1; fi
