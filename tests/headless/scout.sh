#!/usr/bin/env bash
# Headless: the scout maps the fixture repository with file paths and says where the idea plugs in.
# Usage: bash tests/headless/scout.sh
set -u
P="$(cd "$(dirname "$0")/../.." && pwd)"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
O="$base/nawah-headless-scout"; rm -rf "${O:?}"; mkdir -p "$O"
repo="$P/tests/fixture/bakery-app"
prompt="Use the nawah:scout agent with the brief below. Then print its report exactly as it returned it, with nothing before or after.

Repository: $repo
Idea: loyalty points for repeat customers, redeemable on their next order
Extra documents: none"
(cd "$base" && claude -p "$prompt" --setting-sources project,local --plugin-dir "$P" --add-dir "$repo" --allowedTools "Agent" "Read" "Grep" "Glob") > "$O/out.txt" 2>&1
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
check "repository heading" 'grep -q "^## Repository:" "$O/out.txt"'
check "names the data model file" 'grep -q "schema.sql" "$O/out.txt"'
check "names a source file" 'grep -Eq "src/(orders|customers)\.js" "$O/out.txt"'
check "says where the idea plugs in" 'grep -q "^### Where the idea plugs in" "$O/out.txt"'
check "names the stack" 'grep -qi "express" "$O/out.txt"'
[ "$failures" -eq 0 ] && echo "headless scout passes" || { echo "see $O/out.txt"; exit 1; }
