/-
 EG203Formal/Size5.lean -- Erdős–Graham #203 corpus, Size-5 lower bound.

 Formalizes the combinatorial core of `Erdos203_Size5_Bound.lean`:
 why any covering of the k = 0 row of Erdős #203 needs at least 5 primes.

 STATUS: DRAFT. Verified only once `lake build` is clean and the
 `#print axioms` line shows no `sorryAx`. Arithmetic numerically
 pre-checked in UNIVERSAL_LAW/oracle/math/size5_numeric_check.py

 `size5_abstract` is the abstract kernel. Index set `P`, an "order"
 `o : ι → ℕ` with `o p ≥ 3` for `p ∈ P`, and each of the values `3,4,5`
 attained at most once on `P`; if the order-densities `1/o p` sum to
 at least `1`, then `|P| ≥ 5`. (`1/3+1/4+1/5+1/6 = 19/20 < 1`.)

 EG203 instance: `ι = ℕ`, `o p = orderOf (3 : ZMod p)`. Proving that this
 `o` satisfies the hypotheses (orders ≥ 3; the order-3/4/5 primes are
 exactly 13/5/11) and that a row-covering forces `∑ 1/o ≥ 1` is the
 number-theoretic instantiation step — separate from this kernel.
-/
import Mathlib

open Finset

namespace EG203Formal.Size5

/-- **Size-5 kernel.** If each `p ∈ P` carries an "order" `o p ≥ 3`, the
values `3, 4, 5` are each attained at most once, and the order-densities
`1/o p` sum to at least `1`, then `P` has at least `5` elements. -/
theorem size5_abstract {ι : Type*} (P : Finset ι) (o : ι → ℕ)
 (hpos : ∀ p ∈ P, 3 ≤ o p)
 (huniq3 : ∀ p ∈ P, ∀ q ∈ P, o p = 3 → o q = 3 → p = q)
 (huniq4 : ∀ p ∈ P, ∀ q ∈ P, o p = 4 → o q = 4 → p = q)
 (huniq5 : ∀ p ∈ P, ∀ q ∈ P, o p = 5 → o q = 5 → p = q)
 (hcover : 1 ≤ ∑ p ∈ P, (1 : ℚ) / (o p : ℚ)) :
 5 ≤ P.card := by
 by_contra hlt
 have hcard : P.card ≤ 4 := by omega
 -- Pointwise: 1/o p ≤ 1/6 + 1/6·[o=3] + 1/12·[o=4] + 1/30·[o=5].
 have hpt : ∀ p ∈ P, (1 : ℚ) / (o p : ℚ)
 ≤ 1/6 + 1/6 * (if o p = 3 then (1:ℚ) else 0)
 + 1/12 * (if o p = 4 then (1:ℚ) else 0)
 + 1/30 * (if o p = 5 then (1:ℚ) else 0) := by
 intro p hp
 have h3 : 3 ≤ o p := hpos p hp
 by_cases h6 : 6 ≤ o p
 · have c3 : (if o p = 3 then (1:ℚ) else 0) = 0 := by rw [if_neg]; omega
 have c4 : (if o p = 4 then (1:ℚ) else 0) = 0 := by rw [if_neg]; omega
 have c5 : (if o p = 5 then (1:ℚ) else 0) = 0 := by rw [if_neg]; omega
 rw [c3, c4, c5]
 have hop : (6 : ℚ) ≤ (o p : ℚ) := by exact_mod_cast h6
 have hle : (1 : ℚ) / (o p : ℚ) ≤ 1 / 6 :=
 one_div_le_one_div_of_le (by norm_num) hop
 linarith
 · have h6' : o p ≤ 5 := by omega
 interval_cases (o p) <;> norm_num
 -- The order-3/4/5 fibres each have at most one element.
 have b3 : (P.filter (fun p => o p = 3)).card ≤ 1 := by
 rw [Finset.card_le_one]
 intro a ha b hb
 rw [Finset.mem_filter] at ha hb
 exact huniq3 a ha.1 b hb.1 ha.2 hb.2
 have b4 : (P.filter (fun p => o p = 4)).card ≤ 1 := by
 rw [Finset.card_le_one]
 intro a ha b hb
 rw [Finset.mem_filter] at ha hb
 exact huniq4 a ha.1 b hb.1 ha.2 hb.2
 have b5 : (P.filter (fun p => o p = 5)).card ≤ 1 := by
 rw [Finset.card_le_one]
 intro a ha b hb
 rw [Finset.mem_filter] at ha hb
 exact huniq5 a ha.1 b hb.1 ha.2 hb.2
 -- Sum the pointwise bound and evaluate.
 have hRHS : ∑ p ∈ P, (1/6 + 1/6 * (if o p = 3 then (1:ℚ) else 0)
 + 1/12 * (if o p = 4 then (1:ℚ) else 0)
 + 1/30 * (if o p = 5 then (1:ℚ) else 0)) ≤ 19/20 := by
 rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib,
 ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_const,
 nsmul_eq_mul, Finset.sum_boole, Finset.sum_boole, Finset.sum_boole]
 have hPc : (P.card : ℚ) ≤ 4 := by exact_mod_cast hcard
 have hc3 : ((P.filter (fun p => o p = 3)).card : ℚ) ≤ 1 := by
 exact_mod_cast b3
 have hc4 : ((P.filter (fun p => o p = 4)).card : ℚ) ≤ 1 := by
 exact_mod_cast b4
 have hc5 : ((P.filter (fun p => o p = 5)).card : ℚ) ≤ 1 := by
 exact_mod_cast b5
 have hc3' : (0:ℚ) ≤ ((P.filter (fun p => o p = 3)).card : ℚ) := by positivity
 have hc4' : (0:ℚ) ≤ ((P.filter (fun p => o p = 4)).card : ℚ) := by positivity
 have hc5' : (0:ℚ) ≤ ((P.filter (fun p => o p = 5)).card : ℚ) := by positivity
 linarith
 linarith [Finset.sum_le_sum hpt, hcover, hRHS]

#print axioms size5_abstract

end EG203Formal.Size5
