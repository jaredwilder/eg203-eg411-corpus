import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.NumberTheory.Harmonic.EulerMascheroni
import Mathlib.Tactic

/-!
# Iwaniec linear sieve F(s) weight function — closed-form region

P2.3 — define the Iwaniec linear-sieve **upper-bound** weight `F : ℝ → ℝ`
(dual of the `f` defined in `FSieveWeight.lean`) on the closed-form region
`(−∞, 3]` and prove positivity there.

## Definition (Iwaniec 1980, Theorem 1)

The Iwaniec linear sieve upper-bound weight on the closed-form region:

 F(s) = 2 · e^γ for s ≤ 1 (boundary value)
 F(s) = (2 · e^γ) / s for 1 ≤ s ≤ 3

where γ is the Euler-Mascheroni constant. For `s > 3` the recursion
`(s · F(s))' = f(s − 1)` extends `F`, but that extension is NOT in scope
here; this file ships only the kernel-verified closed-form region.

## Positivity (the load-bearing fact)

On `[1, 3]`, `F(s) = 2 · e^γ / s > 0` because both numerator and denominator
are strictly positive (`e^γ > 0`, `s ≥ 1 > 0`).

For `s ≤ 1`, `F(s) = 2 · e^γ > 0` (positive constant).

NO MATHEMATICAL AXIOMS. All statements in this file are proved from Mathlib.
-/

namespace EG203R14IwaniecFFunction

open Real

/-- The Iwaniec linear-sieve upper-bound weight on the closed-form region
 `(−∞, 3]`.

 On `s ≤ 1`: the boundary value `2 · e^γ`.
 On `1 < s ≤ 3`: the closed-form `F(s) = 2 · e^γ / s`.

 For `s > 3` we set `F s = 0` as a placeholder; the real Iwaniec
 extension by the dual recursion `(s F(s))' = f(s−1)` is NOT in scope
 here, and no theorem in this file claims positivity outside `(−∞, 3]`. -/
noncomputable def F (s : ℝ) : ℝ :=
 if s ≤ 1 then 2 * Real.exp eulerMascheroniConstant
 else if s ≤ 3 then 2 * Real.exp eulerMascheroniConstant / s
 else 0 -- out-of-scope placeholder for s > 3 (no positivity claim made)

/-- On `s ≤ 1`, `F(s) = 2 · e^γ`. -/
theorem F_eq_boundary_of_le_one {s : ℝ} (hs : s ≤ 1) :
 F s = 2 * Real.exp eulerMascheroniConstant := by
 unfold F
 rw [if_pos hs]

/-- Closed-form on the working interval `(1, 3]`. -/
theorem F_explicit_one_three {s : ℝ} (h1 : 1 < s) (h3 : s ≤ 3) :
 F s = 2 * Real.exp eulerMascheroniConstant / s := by
 unfold F
 rw [if_neg (not_le.mpr h1), if_pos h3]

/-- **The key positivity lemma**: `F(s) > 0` on `[1, 3]`. -/
theorem F_pos_on_one_three (s : ℝ) (h1 : 1 ≤ s) (h3 : s ≤ 3) : 0 < F s := by
 rcases eq_or_lt_of_le h1 with heq | hlt
 · -- Case s = 1: F(1) = 2 · e^γ > 0 (boundary branch fires).
 have hs_eq : s = 1 := heq.symm
 have hs_le_one : s ≤ 1 := le_of_eq hs_eq
 rw [F_eq_boundary_of_le_one hs_le_one]
 have hexp : 0 < Real.exp eulerMascheroniConstant := Real.exp_pos _
 positivity
 · -- Case 1 < s ≤ 3: closed form 2 e^γ / s > 0.
 rw [F_explicit_one_three hlt h3]
 have hexp : 0 < Real.exp eulerMascheroniConstant := Real.exp_pos _
 have hs_pos : 0 < s := by linarith
 have h2exp_pos : 0 < 2 * Real.exp eulerMascheroniConstant := by positivity
 exact div_pos h2exp_pos hs_pos

/-- Positivity at the boundary value `s ≤ 1` (closed under the constant branch). -/
theorem F_pos_of_le_one {s : ℝ} (hs : s ≤ 1) : 0 < F s := by
 rw [F_eq_boundary_of_le_one hs]
 have hexp : 0 < Real.exp eulerMascheroniConstant := Real.exp_pos _
 positivity

/-! ## Out-of-scope: the Iwaniec delay-differential recursion for `s > 3`

The full ODE-theoretic existence and uniqueness of the Iwaniec f/F pair on
`s > 3` is a deep classical result (Iwaniec 1980, Theorem 1). It is NOT
reconstructed here, and no theorem in this file makes any claim about `F`
outside the closed-form region `(−∞, 3]`. Any downstream module that needs
positivity of an Iwaniec-style F on `s > 3` must introduce its own
abstract extension witness (e.g. `∃ F_ext, agrees on [1,3] ∧ positive on
[1,∞)`) — that abstract bridge is the right place for the single named
axiom; this file stays kernel-verified.
-/

/-- The Euler-Mascheroni constant lies in `(1/2, 2/3)` — recorded for sales /
 numerical purposes; mirror of the same lemma in `FSieveWeight`. -/
theorem eulerMascheroni_bounds :
 (1 : ℝ) / 2 < eulerMascheroniConstant ∧
 eulerMascheroniConstant < (2 : ℝ) / 3 :=
 ⟨Real.one_half_lt_eulerMascheroniConstant, Real.eulerMascheroniConstant_lt_two_thirds⟩

end EG203R14IwaniecFFunction
