# EG411 R65x Result Index

Canonical folder for the active Erdős #411 / Cambie-tail R65x Python artifacts.

## Core Certificates

- `r646_direct_gate_failure_certificate.json` — direct Cambie gate obstruction arithmetic.
- `r649_q_birth_barrier.json` — depth-2 q-birth barrier and depth-3 obstruction audit.
- `r650_r646_exact_c2_depth4_closure.json` — R646 exact-C2 depth-4 closure.
- `r651_depth4_universal_audit_p100m.json` — natural p <= 100,000,000 audit.

## GPU Runs

- `r652_gpu_10m_top1024_fastfactor.json` — R646-neighborhood RTX pass.
- `r652_gpu_10m_box_top1024_fastfactor.json` — broader exponent-box RTX pass.
- `r652_gpu_20m_box_seed657_top4096_fastfactor.json` — broad exponent-box RTX pass, seed 657, 20M samples, top 4096 exact checks.
- `r652_gpu_10m_box_maxexp8_seed659_top2048_fastfactor.json` — scale-stress broad exponent-box RTX pass, max exponent 8, seed 659.
- `r652_gpu_8m_box_maxexp12_seed660_top2048_fastfactor.json` — scale-stress broad exponent-box RTX pass, max exponent 12, seed 660.
- `r652_gpu_8m_box_maxexp16_seed661_top4096_fastfactor.json` — scale-stress broad exponent-box RTX pass, max exponent 16, seed 661.
- Matching `.log` files contain progress traces.

## Rough-Cofactor Gate

- `r654_rough_cofactor_certificates_10m_top1024.json` — all hard rows from the R646-neighborhood pass forced by depth 4.
- `r654_rough_cofactor_certificates_10m_box_top1024.json` — all hard rows from the broad box pass forced by depth 4.
- `r654_rough_cofactor_certificates_20m_box_seed657_top4096.json` — all 38 hard rows from the 20M seed-657 broad box pass forced by depth 4.
- `r654_rough_cofactor_certificates_10m_box_maxexp8_seed659_top2048.json` — all 14 hard rows from the max-exp 8 scale-stress pass forced by depth 4.
- `r654_rough_cofactor_certificates_8m_box_maxexp12_seed660_top2048.json` — all 9 hard rows from the max-exp 12 scale-stress pass forced by depth 4.
- `r654_rough_cofactor_certificates_8m_box_maxexp16_seed661_top4096.json` — all 8 hard rows from the max-exp 16 scale-stress pass forced by depth 4.

## Promotion Audits

- `r655_r654_promotion_audit.json` — R654 promotion audit on the R646-neighborhood pass.
- `r655_r654_promotion_audit_10m_box_top1024.json` — R654 promotion audit on the broad box pass.
- `r655_r654_promotion_audit_20m_box_seed657_top4096.json` — R654 promotion audit on the 20M seed-657 broad box pass.
- `r655_r654_promotion_audit_10m_box_maxexp8_seed659_top2048.json` — R654 promotion audit on the max-exp 8 scale-stress pass.
- `r655_r654_promotion_audit_8m_box_maxexp12_seed660_top2048.json` — R654 promotion audit on the max-exp 12 scale-stress pass.
- `r655_r654_promotion_audit_8m_box_maxexp16_seed661_top4096.json` — R654 promotion audit on the max-exp 16 scale-stress pass.
- `r656_lower_jump_constants.json` — explicit finite theorem constants extracted from the current R654/R655 certificates.
- `r656_lower_jump_constants_with_20m_seed657.json` — explicit finite theorem constants after adding the 20M seed-657 broad box pass.
- `r656_lower_jump_constants_with_maxexp8_seed659.json` — explicit finite theorem constants after adding the max-exp 8 scale-stress pass.
- `r656_lower_jump_constants_with_maxexp12_seed660.json` — explicit finite theorem constants after adding the max-exp 12 scale-stress pass.
- `r656_lower_jump_constants_with_maxexp16_seed661.json` — explicit finite theorem constants after adding the max-exp 16 scale-stress pass.
- `r658_mattering_audit.json` — finite-evidence audit log for the current route. (Note: this artifact historically reported a numeric "proximity" percentage. Per MATH-MODE doctrine M4 — math progress is event-based, not percentage-graded — the percentage framing is retired. The audit's structural content stands; the score column is not load-bearing.)
- `r662_lean_first_report.md` — Lean-first proof-pressure report for the EG411 formal gate and lower-jump gap.
- `r663_lean_pipeline.json` — machine-readable Lean-first pipeline result.
- `r663_lean_pipeline_report.md` — human-readable Lean-first pipeline report.
- `r664_lean_pipeline.json` — machine-readable Lean recurrence pipeline result.
- `r664_lean_recurrence_report.md` — human-readable Lean recurrence report.

## Lean Formalization

- `UNIVERSAL_LAW/oracle/math/EG411Formal` — Lean 4.29.1 + Mathlib project for EG411.
- `UNIVERSAL_LAW/oracle/math/EG411Formal/scripts/run_pipeline.py` — hard Lean pipeline runner.
- Clean build proves the algebraic depth-4 gate: `depth4_ratio_identity`, `normalized_depth4_gt_one`, `depth4_from_gate`.
- Clean build proves the recurrence reduction: `x3_step_identity`, `lower_jump_from_bounds`.
- Clean build proves the overbroad guardrail: `weak_strict_underflow_not_enough`.
- Clean theorem axiom check shows no `sorryAx`; only standard Mathlib axioms `[propext, Classical.choice, Quot.sound]`.
- `EG411Formal/LowerJumpGap.lean` is deliberately outside the clean build and fails under `warningAsError=true` because construction of `LowerJumpBounds` for every `CambieTailRecord` is still `sorry`.
- Current pipeline status: `BLOCKED_ON_LOWER_JUMP`.

## Latest Round Win

- R652 seed-657 broad box pass: 20,000,000 samples, 10,001,311 strict GPU candidates, 4,096 exact checks, 2 exact depth-4 forced rows, 38 C2-hard rows, no survivor.
- R654 seed-657 closure: all 38 C2-hard rows forced by depth 4 via rough-cofactor certificate.
- R656 combined constant: 59 total R654 certificates, all depth-4 forced. The observed floor remains `x3_lower >= 0.9908274015338756`; the 20M seed-657 pass did not break it.
- R659 scale-stress pass: max exponent 8, 10,000,000 samples, 5,002,158 strict GPU candidates, 2,048 exact checks, 14 C2-hard rows, no survivor.
- R659 closure: all 14 C2-hard rows forced by depth 4. The observed floor dropped to `x3_lower >= 0.9861316945885408`; finite margin factor dropped to `2.6768046211029115`.
- R660 scale-stress pass: max exponent 12, 8,000,000 samples, 4,000,639 strict GPU candidates, 2,048 exact checks, 9 C2-hard rows, no survivor.
- R660 closure: all 9 C2-hard rows forced by depth 4. The observed floor dropped to `x3_lower >= 0.985369284614279`; finite margin factor dropped to `2.5353540310784832`.
- R661 scale-stress pass: max exponent 16, 8,000,000 samples, 4,001,943 strict GPU candidates, 4,096 exact checks, 8 C2-hard rows, no survivor.
- R661 closure: all 8 C2-hard rows forced by depth 4. The observed floor dropped to `x3_lower >= 0.9849996381393205`; finite margin factor dropped to `2.471948897128363`.
- R658/R661 mattering meter: removed. The numeric percentage framing was a doctrine M4 violation (math progress is event-based). The event-level fact preserved: scale-stress passes weaken the lower-jump stability picture without breaking it.
- R662 Lean-first conversion: clean Lean gate builds; missing lower-jump invariant is now a failing Lean gap instead of prose.
- R663 Lean-first pipeline: clean layer builds, clean files contain no `sorry`/`admit`/`axiom`/`constant`, axiom check has no `sorryAx`, and lower-jump gap fails exactly on `sorry`.
- R664 Lean recurrence pass: recurrence identity and conditional lower-jump theorem are Lean-proved; Lean also proves strict underflow alone is not enough. The remaining proof wall is constructing `LowerJumpBounds` uniformly.

## Current Verdict

R654 is a strong finite certificate, not a global proof. The live proof target is the lower-jump invariant:

```text
For every strict-underflow Cambie record, prove
x3_lower >= 1 / (1 + L(4p^3))
before depth 4, or prove a stronger q-birth/roughness condition implying it.
```

Status: `BLOCKED_ON_LOWER_JUMP`. The route cannot be closed until the lower-jump invariant is proved (or replaced by a stronger q-birth / roughness condition that implies it). Per MATH-MODE doctrine M4, no percentage score is reported here — progress is event-based. The blocking event is named precisely above; further raw scale-search is low-yield without a new worst floor or a survivor.
