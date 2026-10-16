#!/usr/bin/env bash
# The backlog lint passes the good fixture and names exactly the problems in the bad one.
# Usage: bash tests/lint_backlog_test.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
l="$here/tests/lint_backlog.js"; f="$here/tests/fixture"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }
expected='S1.1.1: needs at least 3 acceptance criteria (has 2)
S1.1.2: Points must be 1, 2, 3, 5 or 8
S1.1.2: AC 1 is not "Given … When … Then …"
S1.2.1: depends on unknown S9.9.9
S1.2.1: MVP story depends on v2 story S2.1.1
S1.2.1: duplicate id
S2.1.2: missing "NFR:"
S2.1.2: MVP story depends on v2 story S2.1.1
S2.1.2: Story must read "As a <role>, I want <capability>, so that <benefit>"
S3.1.1: id doesn'"'"'t match its parent F2.1
F2.1: Release is v2, but its earliest story is MVP
dependency cycle: S2.1.1 → S2.1.2 → S2.1.1
Traceability: unknown story S7.7.7'
check "the good backlog passes" 'node "$l" "$f/backlog-good.md"'
check "the bad backlog fails" '! node "$l" "$f/backlog-bad.md" >/dev/null'
actual="$(node "$l" "$f/backlog-bad.md" | sort)"
check "the bad backlog's problems are named, and only those" '[ "$actual" = "$(printf "%s\n" "$expected" | sort)" ]'
[ "$failures" -eq 0 ] && echo "backlog lint tests pass" || { printf 'actual:\n%s\n' "$actual"; exit 1; }
