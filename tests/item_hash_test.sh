#!/usr/bin/env bash
# item-hash.sh: same block, same hash; a changed line changes only that item's hash; line endings
# don't matter; an unknown id fails. Usage: bash tests/item_hash_test.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
h="$here/scripts/item-hash.sh"; src="$here/tests/fixture/backlog-good.md"
base="${TMPDIR:-${TEMP:-/tmp}}"; command -v cygpath >/dev/null 2>&1 && base="$(cygpath -u "$base")"
d="$base/nawah item hash (test)"; rm -rf "${d:?}"; mkdir -p "$d"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
a="$(bash "$h" "$src" S1.1.1)"; b="$(bash "$h" "$src" S1.1.2)"
check "a hash is a number" 'printf "%s" "$a" | grep -Eq "^[0-9]+$"'
check "the same block gives the same hash" '[ "$(bash "$h" "$src" S1.1.1)" = "$a" ]'
check "different items differ" '[ "$a" != "$b" ]'
sed 's/within 60 seconds/within 90 seconds/' "$src" > "$d/changed.md"
check "a changed criterion changes that item" '[ "$(bash "$h" "$d/changed.md" S1.1.1)" != "$a" ]'
check "and not the next item" '[ "$(bash "$h" "$d/changed.md" S1.1.2)" = "$b" ]'
sed 's/$/\r/' "$src" > "$d/crlf.md"
check "CRLF line endings give the same hash" '[ "$(bash "$h" "$d/crlf.md" S1.1.1)" = "$a" ]'
check "an epic hashes only its own fields" '[ -n "$(bash "$h" "$src" E1)" ] && [ "$(bash "$h" "$src" E1)" != "$a" ]'
check "an unknown id exits 1" 'bash "$h" "$src" S9.9.9 2>/dev/null; [ $? -eq 1 ]'
check "bad usage exits 2" 'bash "$h" "$src" 2>/dev/null; [ $? -eq 2 ]'
rm -rf "${d:?}"
[ "$failures" -eq 0 ] && echo "item-hash tests pass" || exit 1
