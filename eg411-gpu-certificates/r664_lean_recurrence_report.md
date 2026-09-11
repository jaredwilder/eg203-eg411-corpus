# R664 Lean Recurrence Report

## Binary

Prove the lower-jump step in Lean OR expose exactly why it cannot be claimed.

## Clean Lean Additions

Added:

```text
EG411Formal/Recurrence.lean
EG411Formal/Counterexamples.lean
```

New Lean-checked theorems:

```text
x3_step_identity
lower_jump_from_bounds
weak_strict_underflow_not_enough
```

## What Lean Proved

`x3_step_identity` proves the normalized recurrence identity:

```text
x3 = x2 * (1 + ((p - 1) / p) * phi(C2) / C2)
```

`lower_jump_from_bounds` proves the exact reduction:

```text
If we can produce valid lower bounds for x2 and phi(C2)/C2,
then the lower-jump bound follows.
```

`weak_strict_underflow_not_enough` proves the overbroad claim is false:

```text
Strict underflow alone does not imply the observed lower-jump floor.
```

That is not a hedge. It is Lean proving that the old abstract gap statement was too weak/false unless the arithmetic constraints are added.

## Pipeline Result

```text
proof_status = BLOCKED_ON_LOWER_JUMP
headline_proof_pct = 63.61%
clean build = passed
clean file scan = passed
no sorryAx = true
gap file = fails exactly on sorry
```

Gap check:

```text
EG411Formal\LowerJumpGap.lean:31:8: error: declaration uses `sorry`
```

## Exact Remaining Target

Replace:

```text
cambie_tail_records_have_lower_jump_bounds_gap
```

with a proof constructing:

```text
LowerJumpBounds p c2 phic2 x2Lower rhoLower R661Threshold
```

for every concrete `CambieTailRecord`.

Until that exists, this route is not a proof.
