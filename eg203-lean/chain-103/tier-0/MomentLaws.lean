/-
 EG203Formal/MomentLaws.lean -- Erdős–Graham #203 corpus, R701 moment laws.

 Formalizes equations (4), (5), (6) of the companion R701 worksheet.

 STATUS: DRAFT. This counts as verified ONLY once `lake build` reports no
 errors and the `#print axioms` lines below show no `sorryAx`.
 The statement itself was numerically pre-checked (exact rationals) in
 a companion `moment_laws_numeric_check.py` driver.

 Abstract setting -- no group structure, pure counting:
 a finite type `α`, a finite subset `S : Finset α`, a bijection `f : α ≃ α`.
 rho f S m := if f m ∈ S then (|S| : ℚ)⁻¹ else 0
 delta f S m := rho f S m - (|α| : ℚ)⁻¹
 Then
 (4) ∑ m, delta f S m = 0
 (5) ∑ m, (delta f S m)^2 = (|S|)⁻¹ - (|α|)⁻¹
 (6) (|α|)⁻¹ * ∑ m, (delta f S m)^2 = (|α|)⁻¹ * ((|S|)⁻¹ - (|α|)⁻¹)

 The EG203 instance is `α = (ZMod d)ˣ`, `S = ⟨2,3⟩`, `f = (m ↦ -m⁻¹)`;
 that instantiation belongs in a separate file.
-/
import Mathlib

open Finset

namespace EG203Formal.MomentLaws

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Local-density indicator: `(|S|)⁻¹` on the `f`-preimage of `S`, else `0`. -/
def rho (f : α ≃ α) (S : Finset α) (m : α) : ℚ :=
 if f m ∈ S then (S.card : ℚ)⁻¹ else 0

/-- The Kummer-type discrepancy `Δ = ρ − (|α|)⁻¹`. -/
def delta (f : α ≃ α) (S : Finset α) (m : α) : ℚ :=
 rho f S m - (Fintype.card α : ℚ)⁻¹

/-- Reindexing a constant-weight indicator by the bijection `f`:
 `∑ m, (if f m ∈ S then c else 0) = c * |S|`. -/
lemma sum_const_indicator (f : α ≃ α) (S : Finset α) (c : ℚ) :
 ∑ m, (if f m ∈ S then c else 0) = c * S.card := by
 have hreindex : (∑ m, (if f m ∈ S then c else 0))
 = ∑ x, (if x ∈ S then c else 0) :=
 Equiv.sum_comp f (fun x => if x ∈ S then c else 0)
 rw [hreindex, Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const,
 nsmul_eq_mul]
 ring

/-- `∑ ρ = 1`. -/
lemma sum_rho (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, rho f S m = 1 := by
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 simp only [rho]
 rw [sum_const_indicator, inv_mul_cancel₀ hc]

/-- **Moment law (4)** — the discrepancy has mean zero: `∑ Δ = 0`. -/
theorem sum_delta_eq_zero (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, delta f S m = 0 := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 simp only [delta]
 rw [Finset.sum_sub_distrib, sum_rho f S hS, Finset.sum_const,
 Finset.card_univ, nsmul_eq_mul, mul_inv_cancel₀ hn, sub_self]

omit [Fintype α] in
/-- Pointwise square: `ρ² = (|S|)⁻¹ · ρ`. (`Fintype α` is not needed here.) -/
lemma rho_sq (f : α ≃ α) (S : Finset α) (m : α) :
 (rho f S m) ^ 2 = (S.card : ℚ)⁻¹ * rho f S m := by
 simp only [rho]
 split_ifs <;> ring

/-- `∑ ρ² = (|S|)⁻¹`. -/
lemma sum_rho_sq (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (rho f S m) ^ 2 = (S.card : ℚ)⁻¹ := by
 simp only [rho_sq]
 rw [← Finset.mul_sum, sum_rho f S hS, mul_one]

/-- **Moment law (5)** — the exact second moment: `∑ Δ² = (|S|)⁻¹ − (|α|)⁻¹`. -/
theorem sum_delta_sq (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 ∑ m, (delta f S m) ^ 2 = (S.card : ℚ)⁻¹ - (Fintype.card α : ℚ)⁻¹ := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 have hterm : ∀ m, (delta f S m) ^ 2
 = (rho f S m) ^ 2
 - 2 * (Fintype.card α : ℚ)⁻¹ * rho f S m
 + ((Fintype.card α : ℚ)⁻¹) ^ 2 := by
 intro m; simp only [delta]; ring
 simp only [hterm]
 rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, sum_rho_sq f S hS,
 ← Finset.mul_sum, sum_rho f S hS, Finset.sum_const, Finset.card_univ,
 nsmul_eq_mul]
 field_simp
 ring

/-- **Moment law (6)** — the averaged second moment. -/
theorem mean_delta_sq (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) :
 (Fintype.card α : ℚ)⁻¹ * ∑ m, (delta f S m) ^ 2
 = (Fintype.card α : ℚ)⁻¹ * ((S.card : ℚ)⁻¹ - (Fintype.card α : ℚ)⁻¹) := by
 rw [sum_delta_sq f S hS]

/-- **Moment law (7)** — cross-moment vanishing. When the two discrepancies
 live on independent coordinates `α × β` (the CRT factorisation of
 `(ℤ/q₁q₂)ˣ` as `(ℤ/q₁)ˣ × (ℤ/q₂)ˣ`), the cross term sums to zero. -/
theorem sum_delta_mul_delta_eq_zero
 {β : Type*} [Fintype β] [DecidableEq β]
 (f : α ≃ α) (S : Finset α) (g : β ≃ β) (T : Finset β) (hT : T.Nonempty) :
 ∑ p : α × β, delta f S p.1 * delta g T p.2 = 0 := by
 have hfactor : ∑ p : α × β, delta f S p.1 * delta g T p.2
 = (∑ x, delta f S x) * (∑ y, delta g T y) := by
 rw [Finset.sum_mul_sum, Fintype.sum_prod_type]
 rw [hfactor, sum_delta_eq_zero g T hT, mul_zero]

-- Verification gate: when `lake build` runs, these must print `[propext,
-- Classical.choice, Quot.sound]` and NOT `sorryAx`.
#print axioms sum_delta_eq_zero
#print axioms sum_delta_sq
#print axioms mean_delta_sq
#print axioms sum_delta_mul_delta_eq_zero

end EG203Formal.MomentLaws
