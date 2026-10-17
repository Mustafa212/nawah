#!/usr/bin/env bash
# Contracts between nawah's files:
#  - every tracker adapter defines the six operations;
#  - the template's section ids are exactly the ones report.md describes, each with a SLOT marker;
#  - every backlog label of the format is linted and reviewed;
#  - every reference SKILL.md names exists, long references have a Contents line, SKILL.md's size
#    and layout, and each agent's name matches its file.
# Usage: bash tests/check.sh
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"; s="$here/skills/nawah"
failures=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi; }

for a in "$s"/references/trackers/*.md; do
  for op in connect detect read_backlog create link csv_format; do
    check "$(basename "$a") defines $op" "grep -qE '^\| $op \|' '$a'"
  done
done

tpl="$s/assets/report-template.html"
tpl_ids="$(grep -oE '<section id="[a-z-]+"' "$tpl" | sed 's/.*id="//; s/"$//' | sort)"
ref_ids="$(sed -n '/^## Sections/,/^## /p' "$s/references/report.md" | grep -oE '^\| `[a-z-]+` \|' | sed 's/^| `//; s/` |$//' | sort)"
check "template sections = report.md sections" '[ -n "$tpl_ids" ] && [ "$tpl_ids" = "$ref_ids" ]'
for id in $tpl_ids; do check "section $id has a SLOT marker" "grep -qF '<!-- SLOT $id -->' '$tpl'"; done

labels="$(sed -n '/^## backlog.md format/,/^## Writing stories/p' "$s/references/backlog.md" | sed -n '/^## E1/,/^```$/p' \
  | grep -oE '^[A-Z][A-Za-z ]+:' | sed 's/:$//' | sort -u)"
check "backlog labels found" '[ "$(printf "%s\n" "$labels" | wc -l)" -ge 14 ]'
while IFS= read -r l; do
  [ -n "$l" ] || continue
  check "label '$l' is linted" "grep -qF \"'$l'\" '$here/tests/lint_backlog.js'"
  check "label '$l' is reviewed" "grep -qF '$l' '$here/agents/backlog-reviewer.md'"
done <<< "$labels"

for r in $(grep -oE 'references/[a-z/-]+\.md' "$s/SKILL.md" | sort -u); do
  check "SKILL.md names $r, which exists" "[ -f '$s/$r' ]"
done
for f in "$s"/references/*.md "$s"/references/trackers/*.md; do
  n="$(wc -l < "$f")"
  [ "$n" -gt 100 ] && check "$(basename "$f") ($n lines) has a Contents line" "grep -q '^Contents:' '$f'"
done
check "SKILL.md is under 3,000 words" '[ "$(wc -w < "$s/SKILL.md")" -lt 3000 ]'
check "hard gates and excuses in SKILL.md's first 100 lines" 'head -100 "$s/SKILL.md" | grep -q "^## Hard gates" && head -100 "$s/SKILL.md" | grep -q "^## Excuses"'
for a in "$here"/agents/*.md; do
  check "agent $(basename "$a") is named after its file" "grep -q '^name: $(basename "$a" .md)$' '$a'"
done

if [ "$failures" -eq 0 ]; then echo "contracts hold"; else echo "$failures contract check(s) failed"; exit 1; fi
