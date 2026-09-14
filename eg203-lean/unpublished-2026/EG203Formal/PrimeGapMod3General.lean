/-
 PrimeGapMod3General.lean — Oracle by-hand Round 45.

 EXACT GENERAL CLOSED FORM at p=3:
 admissibleCount 3 k = 2^k - 1 for every k ≥ 1.

 Strategy: direct enumeration of the non-covering SumTuples at p=3. A tuple
 s : Fin (k-1) → ZMod 3 is NOT-covering iff {0, s_0, ..., s_{k-2}} ≠ ZMod 3 iff
 there exists r ∈ {1, 2} with no i such that s_i = r.

 Equivalently: the not-covering set decomposes as
 {s : ∀i, s i ≠ 1} ∪ {s : ∀i, s i ≠ 2}
 minus the intersection
 {s : ∀i, s i ∈ {0}} = {const-0 tuple}
 Each of the two single-residue sets has cardinality 2^(k-1) (since each s_i
 has 2 choices: {0, 2} or {0, 1}); the intersection has cardinality 1. By
 inclusion-exclusion at the small-set level:
 admissibleCount 3 k = 2 · 2^(k-1) - 1 = 2^k - 1.
-/

import EG203Formal.PrimeGapAdmissibleClosedForm

namespace PrimeGapIE

open Finset

-- ════ ZMod 3 case helper ════

private lemma zmod3_cases (x : ZMod 3) : x = 0 ∨ x = 1 ∨ x = 2 := by
 decide +revert

-- ════ Set characterisation ════

private lemma not_covers_mod3_iff (k : ℕ) (s : SumTuple 3 k) :
 ¬ coversAllResidues 3 k s ↔ (∀ i, s i ≠ 1) ∨ (∀ i, s i ≠ 2) := by
 constructor
 · intro h_not
 unfold coversAllResidues at h_not
 push_neg at h_not
 obtain ⟨r, hr_ne_zero, h_no_match⟩ := h_not
 rcases zmod3_cases r with h0 | h1 | h2
 · exact absurd h0 hr_ne_zero
 · subst h1
 left; exact h_no_match
 · subst h2
 right; exact h_no_match
 · intro h
 rcases h with h1 | h2
 · intro h_cover
 have := h_cover 1
 rcases this with h0 | ⟨i, hi⟩
 · exact absurd h0 (by decide)
 · exact (h1 i) hi
 · intro h_cover
 have := h_cover 2
 rcases this with h0 | ⟨i, hi⟩
 · exact absurd h0 (by decide)
 · exact (h2 i) hi

-- ════ Count the avoid-1 and avoid-2 sets ════

private lemma card_avoid_one (k : ℕ) :
 (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 1)).card = 2 ^ (k - 1) := by
 -- avoiding {1} = each component is in {0, 2}
 have h_eq : (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 1))
 = Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ∈ ({0, 2} : Finset (ZMod 3))) := by
 ext s
 simp only [mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
 constructor
 · intro h i
 have := h i
 rcases zmod3_cases (s i) with h0 | h1 | h2
 · left; exact h0
 · exact absurd h1 this
 · right; exact h2
 · intro h i
 have := h i
 rcases this with h0 | h2
 · rw [h0]; decide
 · rw [h2]; decide
 rw [h_eq, card_sumTuple_in_subset]
 rfl

private lemma card_avoid_two (k : ℕ) :
 (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 2)).card = 2 ^ (k - 1) := by
 have h_eq : (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 2))
 = Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ∈ ({0, 1} : Finset (ZMod 3))) := by
 ext s
 simp only [mem_filter, mem_univ, true_and, Finset.mem_insert, Finset.mem_singleton]
 constructor
 · intro h i
 have := h i
 rcases zmod3_cases (s i) with h0 | h1 | h2
 · left; exact h0
 · right; exact h1
 · exact absurd h2 this
 · intro h i
 have := h i
 rcases this with h0 | h1
 · rw [h0]; decide
 · rw [h1]; decide
 rw [h_eq, card_sumTuple_in_subset]
 rfl

private lemma card_avoid_both (k : ℕ) (hk : k ≥ 1) :
 (Finset.univ.filter
 (fun s : SumTuple 3 k => (∀ i, s i ≠ 1) ∧ (∀ i, s i ≠ 2))).card = 1 := by
 -- This is the set where every s i = 0 (only nonzero alternative would be ≠ 1 AND ≠ 2)
 have h_eq : (Finset.univ.filter
 (fun s : SumTuple 3 k => (∀ i, s i ≠ 1) ∧ (∀ i, s i ≠ 2)))
 = {fun _ => (0 : ZMod 3)} := by
 ext s
 simp only [mem_filter, mem_univ, true_and, Finset.mem_singleton]
 constructor
 · intro ⟨h1, h2⟩
 funext i
 rcases zmod3_cases (s i) with h0 | hh1 | hh2
 · exact h0
 · exact absurd hh1 (h1 i)
 · exact absurd hh2 (h2 i)
 · intro h_eq
 subst h_eq
 refine ⟨?_, ?_⟩
 · intro i
 show (0 : ZMod 3) ≠ 1
 decide
 · intro i
 show (0 : ZMod 3) ≠ 2
 decide
 rw [h_eq]
 exact Finset.card_singleton _

-- ════ HEADLINE THEOREM ════

theorem admissibleCount_mod3_eq (k : ℕ) (hk : k ≥ 1) :
 admissibleCount 3 k = 2 ^ k - 1 := by
 unfold admissibleCount
 -- The not-covering set is (avoid_one ∪ avoid_two) by not_covers_mod3_iff
 -- |avoid_one ∪ avoid_two| = |avoid_one| + |avoid_two| - |avoid_one ∩ avoid_two|
 -- = 2^(k-1) + 2^(k-1) - 1
 -- = 2^k - 1
 have h_eq : (Finset.univ : Finset (SumTuple 3 k)).filter (fun s => ¬ coversAllResidues 3 k s)
 = (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 1))
 ∪ (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 2)) := by
 ext s
 simp only [mem_filter, mem_univ, true_and, Finset.mem_union]
 exact not_covers_mod3_iff k s
 rw [h_eq, Finset.card_union]
 -- Now: |avoid1| + |avoid2| - |avoid1 ∩ avoid2|
 have h1 := card_avoid_one k
 have h2 := card_avoid_two k
 have h_inter : (Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 1)
 ∩ Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 2)).card = 1 := by
 have h_filter_inter : Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 1)
 ∩ Finset.univ.filter (fun s : SumTuple 3 k => ∀ i, s i ≠ 2)
 = Finset.univ.filter
 (fun s : SumTuple 3 k => (∀ i, s i ≠ 1) ∧ (∀ i, s i ≠ 2)) := by
 ext s
 simp only [Finset.mem_inter, mem_filter, mem_univ, true_and]
 rw [h_filter_inter]
 exact card_avoid_both k hk
 rw [h1, h2, h_inter]
 -- Now goal is: 2^(k-1) + 2^(k-1) - 1 = 2^k - 1
 have h_pow : 2 ^ (k - 1) + 2 ^ (k - 1) = 2 ^ k := by
 have hk1 : k - 1 + 1 = k := Nat.sub_add_cancel hk
 calc 2 ^ (k - 1) + 2 ^ (k - 1)
 = 2 ^ (k - 1) * 2 := by ring
 _ = 2 ^ ((k - 1) + 1) := by rw [pow_succ]
 _ = 2 ^ k := by rw [hk1]
 omega

-- ════ Numerical corollaries ════

theorem admissibleCount_3_3_check : admissibleCount 3 3 = 7 := by
 rw [admissibleCount_mod3_eq 3 (by omega)]; decide
theorem admissibleCount_3_4_check : admissibleCount 3 4 = 15 := by
 rw [admissibleCount_mod3_eq 4 (by omega)]; decide
theorem admissibleCount_3_5_check : admissibleCount 3 5 = 31 := by
 rw [admissibleCount_mod3_eq 5 (by omega)]; decide
theorem admissibleCount_3_10_check : admissibleCount 3 10 = 1023 := by
 rw [admissibleCount_mod3_eq 10 (by omega)]; rfl

#eval IO.println s!"R45 EXACT CLOSED FORM at p=3:"
#eval IO.println s!" • zmod3_cases PROVED (helper)"
#eval IO.println s!" • not_covers_mod3_iff PROVED (set decomposition)"
#eval IO.println s!" • card_avoid_one / card_avoid_two PROVED (each = 2^(k-1))"
#eval IO.println s!" • card_avoid_both PROVED (intersection = 1)"
#eval IO.println s!" • admissibleCount_mod3_eq PROVED (GENERAL ∀ k ≥ 1)"
#eval IO.println s!" • admissibleCount_3_3 = 7 / 3_4 = 15 / 3_5 = 31 / 3_10 = 1023 PROVED"
#eval IO.println s!""
#eval IO.println s!"R39 + R40 + R41 + R42 + R43 + R44 + R45 = 56 theorems total"
#eval IO.println s!""
#eval IO.println s!"HEADLINE: admissibleCount 3 k = 2^k - 1 for EVERY k ≥ 1."
#eval IO.println s!"Proof goes through the 2-residue case (avoid 1 OR avoid 2) via direct"
#eval IO.println s!"set-decomposition + card_sumTuple_in_subset (R39) at the |T|=2 case."
#eval IO.println s!""
#eval IO.println s!"Pattern building: at p=2 → 1 (R44), at p=3 → 2^k - 1 (R45)."

end PrimeGapIE
