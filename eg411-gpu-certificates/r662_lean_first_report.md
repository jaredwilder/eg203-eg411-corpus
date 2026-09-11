# R662 Lean-First Report

## Binary

Move EG411 from Python evidence to Lean proof pressure OR keep drifting in prose/computation.

## Result

Lean project created:

```text
UNIVERSAL_LAW/oracle/math/EG411Formal
```

Clean build:

```text
lake build
Build completed successfully (750 jobs).
```

## Proved In Lean

Clean library files:

```text
EG411Formal/Basic.lean
EG411Formal/Gate.lean
```

Lean-checked theorem layer:

```text
depth4_ratio_identity
normalized_depth4_gt_one
depth4_from_gate
```

Axiom check:

```text
'EG411Formal.depth4_ratio_identity' depends on axioms: [propext, Classical.choice, Quot.sound]
'EG411Formal.normalized_depth4_gt_one' depends on axioms: [propext, Classical.choice, Quot.sound]
'EG411Formal.depth4_from_gate' depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx` in the clean gate layer.

## Exposed Gap

Gap file:

```text
EG411Formal/LowerJumpGap.lean
```

Command:

```text
lake env lean -DwarningAsError=true EG411Formal\LowerJumpGap.lean
```

Output:

```text
EG411Formal\LowerJumpGap.lean:24:8: error: declaration uses `sorry`
```

That is the current proof wall:

```text
lower_jump_invariant_gap:
  every strict-underflow record must have enough normalized depth-3 mass
  to beat the primorial depth-4 threshold.
```

## Mattering Percent

This does not prove EG411. It raises discipline, not headline proximity.

Headline-proof proximity remains:

```text
63.61%
```

But the next round is no longer allowed to hide in Python-only evidence. The only material path is:

```text
Replace LowerJumpGap.lean's `sorry` with real Lean lemmas,
or demote the Cambie-tail route to finite-only.
```
