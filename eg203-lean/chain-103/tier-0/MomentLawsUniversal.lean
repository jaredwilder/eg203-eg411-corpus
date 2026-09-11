/-
 EG203Formal/MomentLawsUniversal.lean -- Universal k-th moment of the
 discrepancy, in one closed form parametric in `k`. Subsumes
 MomentLaws.lean theorems for k = 1, 2 and MomentLawsExtended.lean for k = 3, 4.

 STATUS: DRAFT. Counts as verified once `lake build` reports no errors and
 `#print axioms` shows only `[propext, Classical.choice, Quot.sound]`.

 Approach (membership-split): the discrepancy `delta` takes exactly two values
 across the universe `α`:
 on `{m : f m ∈ S}` (size |S|): delta = 1/|S| - 1/|α|
 on the complement (size |α|-|S|): delta = -1/|α|
 Summing `delta^k` is therefore a 2-term identity in `k`:
 ∑ delta^k = |S| · (1/|S| - 1/|α|)^k + (|α|-|S|) · (-1/|α|)^k
 Factoring out gives the closed form below.
-/

import EG203Formal.MomentLaws

open Finset

namespace EG203Formal.MomentLaws

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- For `m` with `f m ∈ S`, the discrepancy `delta f S m` takes the constant
 value `(|S|)⁻¹ - (|α|)⁻¹`. -/
lemma delta_eq_pos_value
 (f : α ≃ α) (S : Finset α) {m : α} (h : f m ∈ S) :
 delta f S m = (S.card : ℚ)⁻¹ - (Fintype.card α : ℚ)⁻¹ := by
 simp only [delta, rho, if_pos h]

/-- For `m` with `f m ∉ S`, the discrepancy `delta f S m` equals `-(|α|)⁻¹`. -/
lemma delta_eq_neg_value
 (f : α ≃ α) (S : Finset α) {m : α} (h : f m ∉ S) :
 delta f S m = -((Fintype.card α : ℚ)⁻¹) := by
 simp only [delta, rho, if_neg h, zero_sub]

/-- The cardinality of `{m : f m ∈ S}` equals `|S|` since `f` is a bijection. -/
lemma card_filter_preimage (f : α ≃ α) (S : Finset α) :
 ((Finset.univ : Finset α).filter (fun m => f m ∈ S)).card = S.card := by
 classical
 have hset :
 ((Finset.univ : Finset α).filter (fun m => f m ∈ S))
 = S.image f.symm := by
 ext m
 simp only [Finset.mem_filter, Finset.mem_univ, true_and,
 Finset.mem_image]
 refine ⟨?_, ?_⟩
 · intro h
 refine ⟨f m, h, ?_⟩
 simp
 · rintro ⟨x, hx, rfl⟩
 simp [hx]
 rw [hset, Finset.card_image_of_injective _ f.symm.injective]

/-- The complement: cardinality of `{m : f m ∉ S}` equals `|α| - |S|`. -/
lemma card_filter_preimage_compl (f : α ≃ α) (S : Finset α) :
 ((Finset.univ : Finset α).filter (fun m => f m ∉ S)).card
 = Fintype.card α - S.card := by
 classical
 have hsum :=
 Finset.card_filter_add_card_filter_not
 (s := (Finset.univ : Finset α)) (p := fun m => f m ∈ S)
 rw [Finset.card_univ, card_filter_preimage f S] at hsum
 omega

/-- Cast: `(|α| - |S| : ℕ) : ℚ = (|α| : ℚ) - (|S| : ℚ)`. -/
lemma cast_card_compl (S : Finset α) :
 ((Fintype.card α - S.card : ℕ) : ℚ)
 = (Fintype.card α : ℚ) - (S.card : ℚ) := by
 have hle : S.card ≤ Fintype.card α := S.card_le_univ
 rw [Nat.cast_sub hle]

/-- **Universal k-th moment** — for every `k ≥ 1`, the k-th moment of the
 discrepancy is a closed rational depending only on `|S|`, `|α|`, and `k`:

 ∑ δ^k = (n − s) · ((n − s)^(k−1) + (−1)^k · s^(k−1))
 / (s^(k−1) · n^k)

 where `s := |S|`, `n := |α|`. Specialisations:
 k = 1 → 0 (moment law (4))
 k = 2 → 1/s − 1/n (moment law (5))
 k = 3 → (n − s)(n − 2s) / (s² · n²) (sum_delta_cubed)
 k = 4 → (n − s)(n² − 3sn + 3s²) / (s³ · n³) (sum_delta_fourth)
 and so on for every higher `k`. -/
theorem sum_delta_pow_general
 (f : α ≃ α) (S : Finset α) (hS : S.Nonempty) (k : ℕ) (hk : 1 ≤ k) :
 ∑ m, (delta f S m) ^ k
 = ((Fintype.card α : ℚ) - S.card)
 * (((Fintype.card α : ℚ) - S.card) ^ (k - 1)
 + (-1) ^ k * (S.card : ℚ) ^ (k - 1))
 / ((S.card : ℚ) ^ (k - 1) * (Fintype.card α : ℚ) ^ k) := by
 haveI : Nonempty α := ⟨hS.choose⟩
 have hc : (S.card : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hS).ne'
 have hn : (Fintype.card α : ℚ) ≠ 0 :=
 Nat.cast_ne_zero.mpr Fintype.card_ne_zero
 -- Split the universe sum on the membership predicate.
 rw [← Finset.sum_filter_add_sum_filter_not
 (Finset.univ : Finset α) (fun m => f m ∈ S)]
 -- Constant-value substitution on each side.
 have h_yes :
 ∀ m ∈ (Finset.univ : Finset α).filter (fun m => f m ∈ S),
 (delta f S m) ^ k
 = ((S.card : ℚ)⁻¹ - (Fintype.card α : ℚ)⁻¹) ^ k := by
 intros m hm
 rw [delta_eq_pos_value f S (Finset.mem_filter.mp hm).2]
 have h_no :
 ∀ m ∈ (Finset.univ : Finset α).filter (fun m => f m ∉ S),
 (delta f S m) ^ k
 = (-((Fintype.card α : ℚ)⁻¹)) ^ k := by
 intros m hm
 rw [delta_eq_neg_value f S (Finset.mem_filter.mp hm).2]
 rw [Finset.sum_congr rfl h_yes, Finset.sum_congr rfl h_no]
 -- Constant sums.
 rw [Finset.sum_const, Finset.sum_const,
 card_filter_preimage f S, card_filter_preimage_compl f S,
 nsmul_eq_mul, nsmul_eq_mul, cast_card_compl]
 -- Reduce `k = k' + 1` so that `k - 1` becomes `k'` definitionally.
 rcases Nat.exists_eq_succ_of_ne_zero (Nat.one_le_iff_ne_zero.mp hk)
 with ⟨k', rfl⟩
 -- The LHS contains `((s)⁻¹ - (n)⁻¹)^(k'+1)`. Variable exponent blocks
 -- `field_simp` from expanding. Rewrite the sum-of-inverses as a single
 -- fraction first, then distribute the power via `div_pow`. Same for the
 -- `(-(n)⁻¹)^(k'+1)` term via `neg_pow`.
 have heq_inv :
 (S.card : ℚ)⁻¹ - (Fintype.card α : ℚ)⁻¹
 = ((Fintype.card α : ℚ) - S.card)
 / ((S.card : ℚ) * (Fintype.card α : ℚ)) := by
 field_simp
 rw [heq_inv, div_pow, neg_pow, inv_pow]
 -- Normalize `k'.succ - 1 = k'` syntactically (it's defeq but the
 -- pretty-printer keeps `k'.succ - 1`, which `ring` then treats as a
 -- distinct atom from `k'`). Then expand `x^(k'+1) = x^k' * x` so all
 -- exponents reduce to the common atom `^ k'`. After this, the residual
 -- equation is pure polynomial arithmetic that `ring` closes.
 simp only [Nat.succ_sub_one, pow_succ]
 field_simp
 ring

-- Verification gate
#print axioms sum_delta_pow_general

end EG203Formal.MomentLaws
