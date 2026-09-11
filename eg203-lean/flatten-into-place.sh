#!/usr/bin/env bash
# flatten-into-place.sh — produce a ready-to-build EG203Formal/ layout
# from the per-folder organization of this package.
#
# Usage:
#   bash flatten-into-place.sh    # always works, no exec bit needed
#   # or, if the executable bit survived your unzip:
#   chmod +x flatten-into-place.sh && ./flatten-into-place.sh
#   lake update
#   lake build EG203Formal.EG203AtomicCitations
#
# What it does:
#   For each *.lean under closure/, bounded/, scale-ladder/, chain-103/,
#   source-pinned-540/ — copy into EG203Formal/<same-relative-subpath>/
#   (skipping the `deprecated/` subfolder so circular/missing-import
#   files never enter the build).
#
# Idempotent: safe to re-run.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${ROOT}/EG203Formal"

mkdir -p "$DEST"

copied=0
skipped=0

while IFS= read -r -d '' src; do
  # Skip anything under a deprecated/ folder
  case "$src" in
    */deprecated/*) skipped=$((skipped + 1)); continue;;
  esac

  # Compute path relative to ROOT, strip leading folder name to flatten
  # 'closure/foo.lean'         -> 'EG203Formal/foo.lean'
  # 'chain-103/R14/foo.lean'   -> 'EG203Formal/R14/foo.lean'
  rel="${src#${ROOT}/}"
  case "$rel" in
    closure/*)              tgt="${rel#closure/}";;
    bounded/*)              tgt="${rel#bounded/}";;
    scale-ladder/*)         tgt="${rel#scale-ladder/}";;
    # tier-0 files must flatten to EG203Formal/<name>.lean (not tier-0/<name>.lean)
    # because they self-import as `EG203Formal.MomentLaws`, `EG203Formal.Size5`, etc.
    chain-103/tier-0/*)     tgt="${rel#chain-103/tier-0/}";;
    chain-103/*)            tgt="${rel#chain-103/}";;
    source-pinned-540/*)    tgt="${rel#source-pinned-540/}";;
    *)                      tgt="$rel";;
  esac
  out="${DEST}/${tgt}"
  mkdir -p "$(dirname "$out")"
  cp -p "$src" "$out"
  copied=$((copied + 1))
done < <(find "$ROOT" -type f -name '*.lean' ! -path "*/EG203Formal/*" -print0)

echo "[flatten] copied $copied .lean files into EG203Formal/"
echo "[flatten] skipped $skipped files under deprecated/"
echo "[flatten] now run: lake update && lake build EG203Formal.EG203AtomicCitations"
