import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.NumberTheory.Harmonic.EulerMascheroni
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.FSieveWeight

/-!
# f(s) positivity in the truthful (closed-form) range

P2.8 — restate the positivity of `f` strictly on the range where the
**concrete piecewise definition** in `FSieveWeight` is non-zero,
namely `s ∈ (2, 3]`.

## Why this file no longer carries an axiom

The previous version of this file stated

 `axiom iwaniec_f_monotonicity_lower_bound :
 ∀ s : ℝ, 3 ≤ s →
 2 * exp γ * log 2 / s ≤ f s`

and derived a corollary `f_pos_for_all_s_gt_two`. That axiom was
**INCONSISTENT** with the concrete definition

 `f s := if s ≤ 2 then 0 else if s ≤ 3 then (2 e^γ / s) · log (s − 1) else 0`

because for any `s > 3` the definition gives `f s = 0`, while the axiom
asserts a strictly positive lower bound at the same `s`. Together they
prove `False` (and so prove anything).

The fix taken here: **remove the bad axiom entirely**, and rename the
corollary to its truthful range `(2, 3]`. Downstream theorems that
previously relied on `f_pos_for_all_s_gt_two` are updated to carry the
matching `s ≤ 3` hypothesis (see
`AbstractSieveLowerBound.abstract_iwaniec_lower_with_count_axiom`).

The full Iwaniec extension of `f` beyond `s = 3` (defined via the
delay-differential recursion `(s · f(s))' = F(s − 1)`) is a separate
analysis project: it would introduce a NEW function `f_ext : ℝ → ℝ`
that agrees with `f` on `[0, 3]` and is positive everywhere on `(2, ∞)`,
**not** the same `f` that this development uses. When that extension
is formalized it should live in a new file (`FIwaniecExtended.lean`) so
that the concrete-`f` consumers in this file remain sound.

## What this file provides

A single restatement (`f_pos_on_two_three`) of the closed-form positivity
lemma from `FSieveWeight`, namespaced under
`EG203R14IwaniecFMonotonicityExtension` so existing `open` directives in
`AbstractSieveLowerBound.lean` continue to resolve.

NO MATHEMATICAL AXIOMS IN THIS FILE.
-/

namespace EG203R14IwaniecFMonotonicityExtension

open Real

/-- `f(s) > 0` on the truthful closed-form range `(2, 3]`.

 This is a thin restatement of
 `EG203R14IwaniecFSieveWeight.f_pos_of_two_lt`, exposed here under the
 `FMonotonicityExtension` namespace so that downstream consumers
 (e.g. `AbstractSieveLowerBound`) can continue to `open` this namespace
 without code churn.

 Range: `s ∈ (2, 3]` — i.e. exactly the interval on which the concrete
 piecewise definition of `f` in `FSieveWeight` evaluates to a strictly
 positive number `(2 e^γ / s) · log (s − 1) > 0`. Outside this
 interval the concrete `f` is identically zero, so no positivity
 statement is available without first replacing `f` with a true
 Iwaniec extension. -/
theorem f_pos_on_two_three (s : ℝ) (h₁ : 2 < s) (h₂ : s ≤ 3) :
 0 < EG203R14IwaniecFSieveWeight.f s :=
 EG203R14IwaniecFSieveWeight.f_pos_of_two_lt h₁ h₂

end EG203R14IwaniecFMonotonicityExtension
