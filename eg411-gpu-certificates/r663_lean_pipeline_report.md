# R663 Lean Pipeline Report

## Binary

Run the actual Lean-first pipeline OR keep proof status in prose.

## Pipeline Result

```text
proof_status = BLOCKED_ON_LOWER_JUMP
headline_proof_pct = 63.61%
```

## Clean Layer

Command:

```powershell
python scripts\run_pipeline.py --output ..\results\eg411\r663_lean_pipeline.json
```

Clean build:

```text
lake build
Build completed successfully (837 jobs).
```

Clean file scan:

```text
EG411Formal.lean
EG411Formal/Basic.lean
EG411Formal/Gate.lean
```

Forbidden proof-escape tokens checked:

```text
sorry
admit
axiom
constant
```

Hits:

```text
[]
```

## Axiom Check

```text
'EG411Formal.depth4_ratio_identity' depends on axioms: [propext, Classical.choice, Quot.sound]
'EG411Formal.normalized_depth4_gt_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'EG411Formal.depth4_from_gate' depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`.

## Gap Check

Command:

```powershell
lake env lean -DwarningAsError=true EG411Formal\LowerJumpGap.lean
```

Output:

```text
EG411Formal\LowerJumpGap.lean:24:8: error: declaration uses `sorry`
```

## Verdict

The gate is no longer prose. The clean formal layer passes; the lower-jump invariant is the only named proof blocker.

Next material task:

```text
Replace LowerJumpGap.lean's sorry with concrete strict-underflow definitions
and proved lower-jump lemmas, or demote this route to finite-only.
```
