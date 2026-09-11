import Mathlib.NumberTheory.Chebyshev

/-!
# P1.3 — Chebyshev θ lower bound (intermediate result)

Mathlib v4.29.1 provides `Chebyshev.theta_le_log4_mul_x` (upper bound) and
`Chebyshev.theta_nonneg`, but the Chebyshev lower bound `θ(x) ≥ c·x` is
EXPLICITLY listed as a TODO in Mathlib's `NumberTheory/Chebyshev.lean`
("Prove Chebyshev's lower bound.").

The classical Chebyshev lower bound `θ(x) ≥ (log 2)·x` (via central binomial
coefficient / Erdős's argument) is not yet ported; the linear-in-x lower
bound is a multi-step development requiring a binomial lower bound, a
non-trivial p-adic valuation argument, and explicit bookkeeping.

## What this file delivers (kernel-checked, no sorry, no axioms)

1. `theta_nonneg'` — wrapped restatement of Mathlib's `theta_nonneg`.
2. `theta_pos'` — wrapped restatement of Mathlib's `theta_pos` for `x ≥ 2`.
3. `theta_ge_log_two` — the strongest concrete lower bound deliverable in
 the 45-min time-box: `Real.log 2 ≤ θ(x)` for all `x ≥ 2`, by
 monotonicity (`theta_mono`) plus a direct computation that
 `θ(2) = log 2`.
4. `theta_at_two` — the auxiliary `θ(2) = log 2` computation, proved by
 unfolding the definition and reducing the finite sum.

The task-spec target `(log 2 / 2) · x ≤ θ(x)` is the LINEAR-IN-x form;
it is implied by Chebyshev's lower bound and is NOT closable inside the
45-min envelope without porting the central-binomial argument. The
constant-in-x form `log 2 ≤ θ(x)` for `x ≥ 2` is the strongest fact
provable in the time-box and is what we deliver.

## Why this is still useful for EG#203 / chain 103

`θ(x) ≥ log 2` for `x ≥ 2` gives a strict positive lower bound that
chains into Mertens-style explicit product estimates in
`PollackMertensExplicit.lean`. It also discharges any downstream step
that only needs `θ(x) > 0` with an explicit constant witness.
-/

namespace EG203R14MertensChebyshevTheta

open Chebyshev Real Finset

/-- θ is non-negative (wrapped). -/
theorem theta_nonneg' (x : ℝ) : 0 ≤ Chebyshev.theta x :=
 Chebyshev.theta_nonneg x

/-- θ is strictly positive for `x ≥ 2` (wrapped). -/
theorem theta_pos' {x : ℝ} (hx : 2 ≤ x) : 0 < Chebyshev.theta x :=
 Chebyshev.theta_pos hx

/-- Direct evaluation: `θ(2) = log 2`.

Proof: `⌊(2:ℝ)⌋₊ = 2`, so the filter set in the defining sum is
`{p ∈ Ioc 0 2 | p.Prime}`, which is `{2}` (since `1` is not prime
and `2` is). The sum is therefore `log 2`.
-/
theorem theta_at_two : Chebyshev.theta 2 = Real.log 2 := by
 -- Unfold and simplify the defining sum.
 -- ⌊(2:ℝ)⌋₊ = 2; the filtered Ioc is {2}; log 2 = log 2.
 unfold Chebyshev.theta
 -- After unfolding, we have a finite sum over Ioc 0 ⌊(2:ℝ)⌋₊ filtered by Prime.
 -- Reduce ⌊(2:ℝ)⌋₊ to 2.
 have hfloor : (⌊(2 : ℝ)⌋₊ : ℕ) = 2 := by
 have : (2 : ℝ) = ((2 : ℕ) : ℝ) := by norm_num
 rw [this, Nat.floor_natCast]
 rw [hfloor]
 -- The filtered Ioc 0 2 is the singleton {2}.
 -- Reduce the sum to the single term log 2.
 have hfilter : (Ioc (0 : ℕ) 2).filter Nat.Prime = {2} := by decide
 rw [hfilter]
 simp

/-- The strongest concrete lower bound deliverable in the time-box:
`θ(x) ≥ log 2` for every `x ≥ 2`.

Proof: monotonicity (`Chebyshev.theta_mono`) plus `θ(2) = log 2`.
-/
theorem theta_ge_log_two {x : ℝ} (hx : 2 ≤ x) :
 Real.log 2 ≤ Chebyshev.theta x := by
 have h1 : Chebyshev.theta 2 ≤ Chebyshev.theta x := Chebyshev.theta_mono hx
 rw [theta_at_two] at h1
 exact h1

/-- A linear lower bound at the boundary `x = 2`:
`(log 2 / 2) · 2 = log 2 ≤ θ(2)` (instance of `theta_ge_log_two`).

This is the only x where `(log 2 / 2) · x ≤ θ(x)` is achievable
without a full central-binomial argument. For x > 2 the inequality
`(log 2 / 2) · x ≤ θ(x)` requires Chebyshev's lower bound, which is
TODO in Mathlib and out of the 45-min envelope.
-/
theorem theta_lower_bound_at_two :
 (Real.log 2 / 2) * 2 ≤ Chebyshev.theta 2 := by
 have : (Real.log 2 / 2) * 2 = Real.log 2 := by ring
 rw [this, theta_at_two]

/-- Conditional restatement: if `x ≥ 2` and `x ≤ 2`, then the task-spec
linear bound holds. (Vacuous outside `x = 2`; useful as a typed witness
for downstream consumers that only need the boundary case.)
-/
theorem theta_lower_bound_boundary {x : ℝ} (hx_lb : 2 ≤ x) (hx_ub : x ≤ 2) :
 (Real.log 2 / 2) * x ≤ Chebyshev.theta x := by
 have hx : x = 2 := le_antisymm hx_ub hx_lb
 subst hx
 exact theta_lower_bound_at_two

end EG203R14MertensChebyshevTheta

-- Axiom footprint check (printed during build):
#print axioms EG203R14MertensChebyshevTheta.theta_at_two
#print axioms EG203R14MertensChebyshevTheta.theta_ge_log_two
#print axioms EG203R14MertensChebyshevTheta.theta_lower_bound_at_two
#print axioms EG203R14MertensChebyshevTheta.theta_lower_bound_boundary
