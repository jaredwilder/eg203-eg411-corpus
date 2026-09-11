/-
 EG203Formal/MomentLawsExtended.lean -- Higher-order moment laws for the
 discrepancy `delta`, extending MomentLaws.lean (eqs 4-7) to the third
 and fourth moments + a half-cover symmetry corollary.

 STATUS: DRAFT. Counts as verified ONLY once `lake build` reports no errors
 and `#print axioms` shows only `[propext, Classical.choice, Quot.sound]`.

 Approach: extend the existing `sum_rho`, `sum_rho_sq` pattern from MomentLaws
 by proving `sum_rho_cubed` and `sum_rho_fourth`. Then binomial-expand
 `δ^k = (ρ - 1/n)^k` and sum each piece using the established ρ-moment lemmas.
 Same idiom as the existing `sum_delta_sq` proof.

 Setup (reused from MomentLaws.lean, same namespace):
 rho f S m := if f m ∈ S then (|S| : ℚ)⁻¹ else 0
 delta f S m := rho f S m - (|α| : ℚ)⁻¹
 And we already have:
 sum_rho : ∑ m, ρ = 1
 sum_rho_sq : ∑ m, ρ² = (|S|)⁻¹
 sum_delta_sq : ∑ m, δ² = (|S|)⁻¹ − (|α|)⁻¹
-/

import EG203Formal.MomentLaws

open Finset

namespace EG203Formal.MomentLaws

variable {α : Type*} [Fintype α] [DecidableEq α]

omit [Fintype α] in
/-- Pointwise cube: `ρ³ = (|S|)⁻² · ρ`. Indicator squared is itself, so the
 coefficient only multiplies through. (`Fintype α` not needed here.) -/
lemma rho_cubed (f : α ≃ α) (S : Finset α) (m : α) :
 (rho f S m) ^ 3 = ((S.card : ℚ)⁻¹) ^ 2 * rho f S m := by
 simp only [rho]
 split_ifs <;> ring

omit [Fintype α] in
/-- Pointwise fourth power: `ρ⁴ = (|S|)⁻³ · ρ`. -/
lemma rho_fourth (f : α ≃ α) (S : Finset α) (m : α) :
 (rho f S m) ^ 4 = ((S.card : ℚ)⁻¹) ^ 3 * rho f S m := by
 simp only [rho]
 split_ifs <;> ring

/-- `∑ ρ³ = (|S|)⁻²`. -/
lemma sum_rho_cubed (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (rho f S m) ^ 3 = ((S.card : ℚ)⁻¹) ^ 2 := by
 simp only [rho_cubed]
 rw [← Finset.mul_sum, sum_rho f S hS, mul_one]

/-- `∑ ρ⁴ = (|S|)⁻³`. -/
lemma sum_rho_fourth (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (rho f S m) ^ 4 = ((S.card : ℚ)⁻¹) ^ 3 := by
 simp only [rho_fourth]
 rw [← Finset.mul_sum, sum_rho f S hS, mul_one]

/-- **Moment law (8)** — third moment of the discrepancy, closed form.
 `∑ δ³ = (n − s)(n − 2s) / (s²·n²)` with `s := |S|`, `n := |α|`. -/
theorem sum_delta_cubed
 (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (delta f S m) ^ 3
 = ((Fintype.card α : ℚ) - S.card)
 * ((Fintype.card α : ℚ) - 2 * S.card)
 / ((S.card : ℚ) ^ 2 * (Fintype.card α : ℚ) ^ 2) := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 -- Binomial expansion: δ³ = ρ³ − 3·ρ²/n + 3·ρ/n² − 1/n³
 have hexp : ∀ m, (delta f S m) ^ 3
 = (rho f S m) ^ 3
 - 3 * (Fintype.card α : ℚ)⁻¹ * (rho f S m) ^ 2
 + 3 * ((Fintype.card α : ℚ)⁻¹) ^ 2 * rho f S m
 - ((Fintype.card α : ℚ)⁻¹) ^ 3 := by
 intro m
 simp only [delta]
 ring
 simp only [hexp]
 rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_sub_distrib,
 sum_rho_cubed f S hS,
 ← Finset.mul_sum, sum_rho_sq f S hS,
 ← Finset.mul_sum, sum_rho f S hS,
 Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
 field_simp
 ring

/-- **Moment law (9)** — fourth moment of the discrepancy, closed form.
 `∑ δ⁴ = (n − s)(n² − 3sn + 3s²) / (s³·n³)`. -/
theorem sum_delta_fourth
 (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (delta f S m) ^ 4
 = ((Fintype.card α : ℚ) - S.card)
 * ((Fintype.card α : ℚ) ^ 2
 - 3 * (S.card : ℚ) * (Fintype.card α : ℚ)
 + 3 * (S.card : ℚ) ^ 2)
 / ((S.card : ℚ) ^ 3 * (Fintype.card α : ℚ) ^ 3) := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 -- δ⁴ = ρ⁴ − 4ρ³/n + 6ρ²/n² − 4ρ/n³ + 1/n⁴
 have hexp : ∀ m, (delta f S m) ^ 4
 = (rho f S m) ^ 4
 - 4 * (Fintype.card α : ℚ)⁻¹ * (rho f S m) ^ 3
 + 6 * ((Fintype.card α : ℚ)⁻¹) ^ 2 * (rho f S m) ^ 2
 - 4 * ((Fintype.card α : ℚ)⁻¹) ^ 3 * rho f S m
 + ((Fintype.card α : ℚ)⁻¹) ^ 4 := by
 intro m
 simp only [delta]
 ring
 simp only [hexp]
 rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_add_distrib,
 Finset.sum_sub_distrib,
 sum_rho_fourth f S hS,
 ← Finset.mul_sum, sum_rho_cubed f S hS,
 ← Finset.mul_sum, sum_rho_sq f S hS,
 ← Finset.mul_sum, sum_rho f S hS,
 Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
 field_simp
 ring

/-- **Half-cover symmetry** — under the proper-subset hypothesis `|S| < |α|`,
 the third moment of the discrepancy vanishes if and only if `|S|` is
 exactly half of `|α|`. (Without the proper-subset hypothesis the iff
 fails: `S = univ` gives `δ ≡ 0`, so the third moment is zero, but
 `|α| = 2|S|` would require `|α| = 0`.) -/
theorem third_moment_vanishes_iff_half_cover
 (f : α ≃ α) (S : Finset α) (hS : S.Nonempty)
 (hProp : S.card < Fintype.card α) :
 (∑ m, (delta f S m) ^ 3 = 0)
 ↔ (Fintype.card α : ℚ) = 2 * S.card := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 -- `(|α| : ℚ) − (|S| : ℚ) > 0` from the proper-subset hypothesis
 have hgap : (Fintype.card α : ℚ) - (S.card : ℚ) ≠ 0 := by
 have : (S.card : ℚ) < (Fintype.card α : ℚ) := by exact_mod_cast hProp
 linarith
 -- denominator non-zero
 have hden : (S.card : ℚ) ^ 2 * (Fintype.card α : ℚ) ^ 2 ≠ 0 := by
 positivity
 rw [sum_delta_cubed f S hS, div_eq_zero_iff]
 constructor
 · rintro (h | h)
 · -- numerator zero: (n - s)(n - 2s) = 0. By hgap, the (n - s) factor is non-zero.
 rcases mul_eq_zero.mp h with h1 | h2
 · exact absurd h1 hgap
 · linarith
 · -- denominator zero — impossible
 exact absurd h hden
 · intro h
 left
 have : (Fintype.card α : ℚ) - 2 * S.card = 0 := by linarith
 rw [this, mul_zero]

-- Verification gate: when `lake build` runs, these must print `[propext,
-- Classical.choice, Quot.sound]` and NOT `sorryAx`.
#print axioms sum_delta_cubed
#print axioms sum_delta_fourth
#print axioms third_moment_vanishes_iff_half_cover

end EG203Formal.MomentLaws
