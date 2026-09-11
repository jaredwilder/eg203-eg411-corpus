# omega7_tree.json — moved to B2 (2026-07-28)

The 272,676-terminal Omega-7 witness tree is **no longer in git**. At 70,817,203 bytes (67.5 MB) it
triggered GitHub's `GH001` large-file warning; at 100 MB GitHub hard-blocks *every* push to the repo,
so it was moved before it could wedge the remote.

| | |
|---|---|
| **Location** | `s3://oracle-data-corpus/datasets/eg411-omega7-tree/omega7_tree.json` |
| **Size** | 70,817,203 bytes |
| **sha256** | `ad6a119475ae10577a70aa86d18c53a8968edb7c620580cc7db6278393403a0f` |
| **Manifest** | `s3://oracle-data-corpus/datasets/eg411-omega7-tree/manifest.json` |

## This does not affect the proof

`OmegaTreeSupport.lean` references this file only in a **provenance comment** — the arities needed for
ω=7 were extracted once (2026-07-14, via `oracle/data_engine/omega_ladder/support_gen.py` →
`scan_needed_arities`) and are baked into `cap_kill_7` and its siblings. The Lean build does **not**
read this JSON. Nothing regresses by its absence.

## Fetching it

Load B2 credentials per `oracle/RUNBOOK.md` §7, then pull the object at the path above and confirm the
sha256 matches before using it. The hash is the citation: a third party re-deriving the ω=7 support
lemmas should verify they received these exact bytes.

## Why a hash and not a copy

A proof whose witness cannot be re-fetched and re-verified is an anecdote. Pinning the bytes by hash is
what makes the ω=7 arity extraction independently checkable without carrying 67.5 MB in every clone —
same contract as the dependency locks committed in `2efbf814`.
