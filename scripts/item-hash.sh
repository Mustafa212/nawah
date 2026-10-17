#!/usr/bin/env bash
# Prints a checksum of one item of a nawah backlog.md: its heading line through the line before the
# next heading. Line endings don't matter.
# Usage: item-hash.sh <backlog.md> <id>     exit 1: no such item; exit 2: bad usage
set -u
[ $# -eq 2 ] || { echo "usage: item-hash.sh <backlog.md> <id>" >&2; exit 2; }
[ -f "$1" ] || { echo "item-hash.sh: no such file: $1" >&2; exit 2; }
block="$(awk -v id="$2" '
  { sub(/\r$/, "") }
  /^#+ / { if (on) exit; if ($2 == id) on = 1 }
  on { print }
' "$1")"
[ -n "$block" ] || { echo "item-hash.sh: no item $2 in $1" >&2; exit 1; }
printf '%s\n' "$block" | cksum | cut -d' ' -f1
