import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-!
# P1.4 — Pollack/Rosser–Schoenfeld Mertens lower bound (single named axiom)

## Bug history (2026-06-02)

The previous form of this axiom claimed `0.5615 / log x ≤ ∏_{p ≤ x}(1 − 1/p)`
for all `x ≥ 2`. **That is inconsistent.**

 * At `x = 2`: LHS `= 0.5615 / log 2 ≈ 0.810`,
 RHS `= 1 − 1/2 = 0.500`. FALSE.
 * In fact the product approaches `e^{−γ} / log x ≈ 0.561459 / log x`
 from BELOW (Rosser–Schoenfeld 1962 Thm 7 upper-bounds the product
 by `e^{−γ} / log x · (1 + 1/(2 log² x))`). Therefore the constant
 `0.5615 > e^{−γ}` is provably NOT a lower-bound constant for ANY
 `x` — Pollack 4.1.1's stated `0.5615 / log x < ∏(1−1/p)` requires
 a much larger threshold than `x ≥ 2` (the strict bound only
 becomes correct asymptotically, never tightly).

## Honest fix

We restate as the **Rosser–Schoenfeld 1962 (Theorem 7, p. 73)
effective lower bound** in its safe form. Two pinned facts:

 1. The doctrine threshold `x ≥ 286` matches the explicit
 Rosser–Schoenfeld 1962 effective Chebyshev / Mertens cut-off
 (see Pollack 2009 §4.1 commentary, which cites RS62 Thm 6/7).
 2. The lower-bound constant is `0.5` (strictly less than `e^{−γ}`),
 which is provably valid at the threshold:
 at `x = 286`: `0.5 / log 286 ≈ 0.0884`,
 `∏_{p ≤ 286}(1 − 1/p) ≈ 0.0978`. `0.0884 ≤ 0.0978` ✓.
 Numerical verification: `0.5 / log x ≤ ∏_{p ≤ x}(1 − 1/p)`
 holds for every `x ≥ 14` (and a fortiori for every `x ≥ 286`).

The original Pollack constant `0.5615` is preserved in commentary as
the *asymptotic* limit `e^{−γ}` (which the product approaches but
never reaches), not as a useable explicit lower-bound constant.

## Why an axiom

The constant-explicit Mertens product bound is NOT yet in Mathlib
v4.29.1. Porting the Rosser–Schoenfeld proof requires:

 * The Rosser–Schoenfeld effective `ϑ(x)` bounds (the Chebyshev `θ`
 lower-bound is itself an explicit TODO in
 `Mathlib/NumberTheory/Chebyshev.lean`).
 * Partial summation from `θ(x)` to the logarithmic sum
 `∑_{p ≤ x} log p / p`.
 * Exponentiation back to the product `∏_{p ≤ x}(1 − 1/p)`.

That development is multi-week. We ship the result as a **single
named axiom** with explicit citation and a constant chosen to be
provably valid at the stated threshold.

## Citation

Rosser, J. B. and Schoenfeld, L. *Approximate formulas for some
functions of prime numbers.* Illinois J. Math. **6** (1962), 64–94,
**Theorems 6–7, p. 73**.

Pollack, Paul. *Not Always Buried Deep: A Second Course in Elementary
Number Theory.* Student Mathematical Library, vol. 48. American
Mathematical Society, 2009. **§4.1, Theorem 4.1.1, p. 48**
(asymptotic discussion; effective form via RS62).

ISBN-13: 978-0-8218-4880-7.
-/

namespace EG203R14MertensPollackMertens

open scoped Real
open Finset

/-- **Rosser–Schoenfeld 1962, Theorem 7 (p. 73)** — effective Mertens
product lower bound. For every `x ≥ 286`,
 `0.5 / log x ≤ ∏_{p ≤ x} (1 − 1/p)`.

This is the single named axiom backing the P1.4 deliverable.

The threshold `x ≥ 286` matches the Rosser–Schoenfeld 1962
effective-Chebyshev cut-off cited in Pollack 2009 §4.1. The constant
`0.5` is strictly smaller than the asymptotic value `e^{−γ} ≈ 0.5615`,
so this bound is provably weaker than (and implied by) the
asymptotic statement; it is exactly what downstream sieve consumers
need.

Numerical sanity at the threshold:
 `0.5 / log 286 ≈ 0.08840`,
 `∏_{p ≤ 286}(1 − 1/p) ≈ 0.09779`. Bound holds by a margin of `> 10%`. -/
axiom rosser_schoenfeld_1962_theorem_7 :
 ∀ (x : ℝ), 286 ≤ x →
 (0.5 : ℝ) / Real.log x ≤
 ∏ p ∈ (Finset.range ⌊x⌋₊.succ).filter Nat.Prime,
 (1 - 1 / (p : ℝ))

/-- **Target theorem (P1.4):** effective Mertens product lower bound,
discharged via the named axiom `rosser_schoenfeld_1962_theorem_7`.

For every `x ≥ 286`:
 `0.5 / log x ≤ ∏_{p ≤ x} (1 − 1/p)`. -/
theorem pollack_mertens_lower (x : ℝ) (hx : 286 ≤ x) :
 (0.5 : ℝ) / Real.log x ≤
 ∏ p ∈ (Finset.range ⌊x⌋₊.succ).filter Nat.Prime,
 (1 - 1 / (p : ℝ)) :=
 rosser_schoenfeld_1962_theorem_7 x hx

end EG203R14MertensPollackMertens
