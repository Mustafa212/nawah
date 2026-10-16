#!/usr/bin/env bash
# nawah report tool: runs a report page in a headless Edge, Chrome or Chromium.
#   report.sh check  <report.html>            prints "ok", or the page's errors on stderr (exit 1)
#   report.sh values <report.html>            prints the page's computed values as JSON (exit 1 if the check fails)
#   report.sh pdf    <report.html> <out.pdf>  prints a page that passes the check to an A4 PDF; never overwrites out.pdf
# Browser: $NAWAH_BROWSER when set, else the first one found. Extra browser flags: $NAWAH_BROWSER_FLAGS.
# Exit: 0 ok; 1 the page has errors or no PDF was written; 2 bad usage, a missing file, an existing out.pdf or no browser.
set -u

die() { code="$1"; shift; printf 'report.sh: %s\n' "$*" >&2; exit "$code"; }
usage() { die 2 "usage: report.sh check|values <report.html>   or   report.sh pdf <report.html> <out.pdf>"; }
native() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s\n' "$1"; fi; }
absolute() {
  local dir; dir="$(cd "$(dirname "$1")" 2>/dev/null && pwd)" || die 2 "no such folder: $(dirname "$1")"
  printf '%s/%s\n' "$dir" "$(basename "$1")"
}

find_browser() {
  if [ -n "${NAWAH_BROWSER:-}" ]; then
    [ -x "$NAWAH_BROWSER" ] || die 2 "NAWAH_BROWSER is not an executable file: $NAWAH_BROWSER"
    printf '%s\n' "$NAWAH_BROWSER"; return
  fi
  local c
  for c in \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium"; do
    if [ -x "$c" ]; then printf '%s\n' "$c"; return; fi
  done
  for c in microsoft-edge google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
  done
  die 2 "no Edge, Chrome or Chromium found. Open the HTML in a browser and print it to PDF (A4, no headers), or set NAWAH_BROWSER to the browser's path"
}

run() {
  # NAWAH_BROWSER_FLAGS is split on spaces on purpose.
  # shellcheck disable=SC2086
  "$browser" --headless=new --disable-gpu --no-first-run --no-default-browser-check \
    --user-data-dir="$(native "$profile")" --virtual-time-budget=15000 ${NAWAH_BROWSER_FLAGS:-} "$@" 2>/dev/null
}

# The status is read from the <html> tag only; the page's CSS also contains the attribute's text.
status_of() { printf '%s\n' "$1" | grep -o '<html[^>]*>' | head -1 | grep -o 'data-nawah="[a-z]*"'; }
errors_of() {
  printf '%s\n' "$1" | awk '/<pre id="nawah-error"/ { on = 1 } on { print } on && /<\/pre>/ { exit }' \
    | sed 's/<[^>]*>//g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&amp;/\&/g'
}

cmd="${1:-}"
case "$cmd" in
  check|values) [ $# -eq 2 ] || usage ;;
  pdf) [ $# -eq 3 ] || usage ;;
  *) usage ;;
esac
[ -f "$2" ] || die 2 "no such file: $2"
in="$(absolute "$2")" || exit 2
if [ "$cmd" = pdf ]; then
  out="$(absolute "$3")" || exit 2
  [ -e "$out" ] && die 2 "$out exists; an approved PDF is never overwritten (raise meta.version)"
fi
browser="$(find_browser)" || exit 2
profile="$(mktemp -d)"
trap 'rm -rf "$profile" 2>/dev/null' EXIT

page="$(run --dump-dom "$(native "$in")")"
case "$(status_of "$page")" in
  'data-nawah="ok"') ;;
  'data-nawah="error"') errors_of "$page" >&2; exit 1 ;;
  *) die 1 "the page didn't finish computing (no data-nawah status on <html>); open it in a browser to see why (snap-packaged Chromium can't open files in hidden folders; set NAWAH_BROWSER to another browser or NAWAH_HOME to a visible folder)" ;;
esac

case "$cmd" in
  check) echo ok ;;
  values)
    printf '%s\n' "$page" | sed -n 's/.*<script type="application\/json" id="nawah-values">\(.*\)<\/script>.*/\1/p' ;;
  pdf)
    run --no-pdf-header-footer --print-to-pdf-no-header --print-to-pdf="$(native "$out")" "$(native "$in")" >/dev/null
    { [ -s "$out" ] && [ "$(head -c 4 "$out")" = "%PDF" ]; } || { rm -f "$out"; die 1 "no PDF was written to $out"; }
    printf '%s\n' "$out" ;;
esac
