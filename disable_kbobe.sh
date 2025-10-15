#!/usr/bin/env bash
# ksu-disable-kprobes.sh
# Replace lines starting with "#ifdef CONFIG_KPROBES"
# -> "#if defined(CONFIG_KPROBES) && 0" across a KernelSU dir.

set -euo pipefail

DIR="KernelSU"
DRY=false
INCLUDE_HIDDEN=false   # set true to scan .git/.repo/out, etc.

# Parse args: [-n|--dry-run] [-d|--dir DIR] [DIR] [--include-hidden]
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY=true; shift ;;
    -d|--dir)     DIR="${2:-}"; [[ -n "$DIR" ]] || { echo "missing --dir value" >&2; exit 1; }; shift 2 ;;
    --include-hidden) INCLUDE_HIDDEN=true; shift ;;
    --) shift; break ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *)  DIR="$1"; shift ;;
  esac
done

[[ -d "$DIR" ]] || { echo "error: '$DIR' is not a directory" >&2; exit 1; }

# Build the find command (skip common junk unless --include-hidden)
if $INCLUDE_HIDDEN; then
  FIND_CMD=(find "$DIR" -type f -print0)
else
  FIND_CMD=(find "$DIR" -type f ! -path '*/.git/*' ! -path '*/.repo/*' ! -path '*/out/*' -print0)
fi

changed=0
scanned=0

while IFS= read -r -d '' f; do
  ((scanned++)) || true
  if grep -qE '^[[:space:]]*#ifdef[[:space:]]+CONFIG_KPROBES([[:space:]]|$)' "$f"; then
    if $DRY; then
      echo "[DRY] would edit: $f"
    else
      perl -0777 -i -pe 's/^(\s*)#ifdef\s+CONFIG_KPROBES\b/\1#if defined(CONFIG_KPROBES) && 0/mg' "$f"
      echo "edited: $f"
    fi
    ((changed++)) || true
  fi
done < <("${FIND_CMD[@]}")

if $DRY; then
  echo "dry-run complete: scanned $scanned files, would change $changed file(s)."
else
  echo "done: scanned $scanned files, changed $changed file(s)."
fi
