import Mathlib.Algebra.BigOperators.Module
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-!
# P1.2 — Discrete Abel partial summation (summation by parts)

REAL Lean number theory (no axioms, no sorries): kernel-checkable Abel
partial summation for real sequences, as needed by the Mertens-product
sieve estimates in chain 103 / R14.

## The identity

For sequences `a, b : ℕ → ℝ` and `N : ℕ`, with the partial sum
 `A N = ∑_{n=0}^{N-1} a n = ∑ n ∈ range N, a n`,

Abel's summation by parts states
 `∑ n ∈ range N, a n * b n
 = A N * b (N-1) − ∑ n ∈ range (N-1), A (n+1) * (b (n+1) − b n)`.

This is a direct rearrangement of Mathlib's
`Finset.sum_range_by_parts` (with action = multiplication on ℝ, and the
roles of `a, b` aligned to the task's convention).

We additionally derive the 1-indexed form
 `∑ n ∈ Icc 1 N, a n * b n
 = A' N * b N − ∑ n ∈ Ico 1 N, A' n * (b (n+1) − b n)`
where `A' N := ∑ n ∈ Icc 1 N, a n` is the 1-indexed partial sum, exactly
as stated in the P1.2 spec.

NO MATHEMATICAL AXIOMS. NO SORRIES. NO ADMITS.
-/

namespace EG203R14MertensPartialSummation

open Finset

/-- The 0-indexed partial sum (Mathlib's natural convention):
`partialSum a N = ∑ n ∈ range N, a n`. So `partialSum a 0 = 0` and
`partialSum a (N+1) = partialSum a N + a N`. -/
def partialSum (a : ℕ → ℝ) (N : ℕ) : ℝ :=
 ∑ n ∈ range N, a n

@[simp]
theorem partialSum_zero (a : ℕ → ℝ) : partialSum a 0 = 0 := by
 simp [partialSum]

theorem partialSum_succ (a : ℕ → ℝ) (N : ℕ) :
 partialSum a (N + 1) = partialSum a N + a N := by
 simp [partialSum, sum_range_succ]

/-- **Abel partial summation (range form, real-valued).**

For sequences `a, b : ℕ → ℝ` and any `N : ℕ`,
 `∑ n ∈ range N, a n * b n
 = partialSum a N * b (N-1)
 − ∑ n ∈ range (N-1), partialSum a (n+1) * (b (n+1) − b n)`.

This is the direct specialization of `Finset.sum_range_by_parts` from
`Mathlib.Algebra.BigOperators.Module` to the case `R = M = ℝ`, where the
`•` action is just multiplication. -/
theorem abel_partial_summation_range (a b : ℕ → ℝ) (N : ℕ) :
 ∑ n ∈ range N, a n * b n
 = partialSum a N * b (N - 1)
 - ∑ n ∈ range (N - 1), partialSum a (n + 1) * (b (n + 1) - b n) := by
 -- `Finset.sum_range_by_parts f g n` with `f := b`, `g := a` is
 -- `∑ i ∈ range n, b i • a i = b (n-1) • G n - ∑ i ∈ range (n-1), (b (i+1) - b i) • G (i+1)`
 -- where `G n = ∑ i ∈ range n, a i = partialSum a n`.
 -- For real scalars `•` reduces to `*`. We commute the two factors on each
 -- side to match the task's `a · b` convention.
 have h := Finset.sum_range_by_parts (R := ℝ) (M := ℝ) b a N
 -- `simp` with `mul_comm` rewrites `b i * a i ↦ a i * b i`, etc.
 simp only [smul_eq_mul] at h
 -- Rewrite each `b _ * a _ = a _ * b _` and `b _ * partialSum _ = partialSum _ * b _`,
 -- `(b _ - b _) * partialSum _ = partialSum _ * (b _ - b _)`.
 unfold partialSum
 calc ∑ n ∈ range N, a n * b n
 = ∑ n ∈ range N, b n * a n := by
 apply Finset.sum_congr rfl; intro n _; ring
 _ = b (N - 1) * (∑ i ∈ range N, a i) -
 ∑ x ∈ range (N - 1), (b (x + 1) - b x) * (∑ i ∈ range (x + 1), a i) := h
 _ = (∑ i ∈ range N, a i) * b (N - 1) -
 ∑ n ∈ range (N - 1), (∑ i ∈ range (n + 1), a i) * (b (n + 1) - b n) := by
 rw [mul_comm (b (N - 1)) _]
 congr 1
 apply Finset.sum_congr rfl
 intro n _
 ring

/-! ### 1-indexed (Icc / Ico) form

The Mertens-product applications speak of `∑_{n=1}^{N}`, not `∑_{n=0}^{N-1}`.
We derive the 1-indexed form by reindexing.
-/

/-- The 1-indexed partial sum: `partialSum₁ a N = ∑ n ∈ Icc 1 N, a n`. -/
def partialSum₁ (a : ℕ → ℝ) (N : ℕ) : ℝ :=
 ∑ n ∈ Icc 1 N, a n

@[simp]
theorem partialSum₁_zero (a : ℕ → ℝ) : partialSum₁ a 0 = 0 := by
 simp [partialSum₁]

/-- The 1-indexed sum `∑ n ∈ Icc 1 N, a n` equals the shifted 0-indexed
sum `∑ n ∈ range N, a (n+1)`. -/
theorem sum_Icc_one_eq_sum_range_shift (a : ℕ → ℝ) (N : ℕ) :
 ∑ n ∈ Icc 1 N, a n = ∑ n ∈ range N, a (n + 1) := by
 induction N with
 | zero => simp [Finset.Icc_eq_empty_of_lt]
 | succ M ih =>
 -- Icc 1 (M+1) = Icc 1 M ∪ {M+1}
 rw [show Icc 1 (M + 1) = insert (M + 1) (Icc 1 M) from ?_,
 Finset.sum_insert (by simp [Finset.mem_Icc]),
 sum_range_succ, ih]
 · ring
 · ext x
 simp only [Finset.mem_Icc, Finset.mem_insert]
 omega

/-- Relate `partialSum₁` to `partialSum` of the shifted sequence. -/
theorem partialSum₁_eq_partialSum_shift (a : ℕ → ℝ) (N : ℕ) :
 partialSum₁ a N = partialSum (fun n => a (n + 1)) N := by
 unfold partialSum₁ partialSum
 exact sum_Icc_one_eq_sum_range_shift a N

/-- The 1-indexed sum of a product also reindexes. -/
theorem sum_Icc_one_mul_eq_sum_range_shift (a b : ℕ → ℝ) (N : ℕ) :
 ∑ n ∈ Icc 1 N, a n * b n = ∑ n ∈ range N, a (n + 1) * b (n + 1) := by
 -- Apply `sum_Icc_one_eq_sum_range_shift` to the pointwise product `a · b`.
 have := sum_Icc_one_eq_sum_range_shift (fun n => a n * b n) N
 simpa using this

/-- The "interior" Ico-indexed sum also reindexes. -/
theorem sum_Ico_one_psum_diff_eq (a b : ℕ → ℝ) (N : ℕ) :
 ∑ n ∈ Ico 1 N, partialSum₁ a n * (b (n + 1) - b n)
 = ∑ n ∈ range (N - 1),
 partialSum₁ a (n + 1) * (b (n + 1 + 1) - b (n + 1)) := by
 rcases N with _ | M
 · simp [Finset.Ico_eq_empty_of_le]
 · -- Ico 1 (M+1) = Icc 1 M; reindex via n ↦ n+1.
 rw [show Ico 1 (M + 1) = Icc 1 M from ?_, Nat.add_sub_cancel,
 sum_Icc_one_eq_sum_range_shift (fun n => partialSum₁ a n * (b (n + 1) - b n)) M]
 · ext x
 simp [Finset.mem_Ico, Finset.mem_Icc]

/-- **Abel partial summation, 1-indexed form (real-valued).**

For real sequences `a, b : ℕ → ℝ` and `N : ℕ`,
 `∑ n ∈ Icc 1 N, a n * b n
 = partialSum₁ a N * b N
 − ∑ n ∈ Ico 1 N, partialSum₁ a n * (b (n+1) − b n)`.

This is the exact form of the identity stated in the P1.2 task:
 `∑_{n=1}^{N} a(n)·b(n) = A(N)·b(N) − ∑_{n=1}^{N-1} A(n)·(b(n+1) − b(n))`
with `A(N) = ∑_{n=1}^{N} a(n)`. -/
theorem abel_partial_summation_Icc (a b : ℕ → ℝ) (N : ℕ) :
 ∑ n ∈ Icc 1 N, a n * b n
 = partialSum₁ a N * b N
 - ∑ n ∈ Ico 1 N, partialSum₁ a n * (b (n + 1) - b n) := by
 -- Reduce to the range form using the shifted sequences a' n := a (n+1), b' n := b (n+1).
 set a' : ℕ → ℝ := fun n => a (n + 1) with ha'
 set b' : ℕ → ℝ := fun n => b (n + 1) with hb'
 -- Step 1: rewrite the LHS as a range sum of `a' n * b' n`.
 rw [sum_Icc_one_mul_eq_sum_range_shift a b N]
 -- Step 2: apply the range-form Abel identity to `a', b'`.
 rw [abel_partial_summation_range a' b' N]
 -- Step 3: rewrite `partialSum a' = partialSum₁ a`.
 have hpsum : ∀ k, partialSum a' k = partialSum₁ a k := fun k => by
 rw [partialSum₁_eq_partialSum_shift]
 -- Step 4: relate `b' (N-1) = b N` when `N ≥ 1`, and the interior sum.
 rw [hpsum N]
 -- Split on N to handle the edge case N = 0 (LHS/RHS are 0).
 rcases N with _ | M
 · -- N = 0: both sides are 0.
 simp [partialSum₁, Finset.Ico_eq_empty_of_le]
 · -- N = M + 1: b' M = b (M+1) = b N. Reindex the interior sum.
 have hbM : b' M = b (M + 1) := rfl
 -- The range sum on the RHS:
 -- ∑ n ∈ range M, partialSum a' (n+1) * (b' (n+1) - b' n)
 -- = ∑ n ∈ range M, partialSum₁ a (n+1) * (b (n+2) - b (n+1)).
 -- The target Ico sum:
 -- ∑ n ∈ Ico 1 (M+1), partialSum₁ a n * (b (n+1) - b n)
 -- reindexes (via sum_Ico_one_psum_diff_eq) to the same.
 rw [Nat.add_sub_cancel, hbM]
 congr 1
 rw [sum_Ico_one_psum_diff_eq a b (M + 1), Nat.add_sub_cancel]
 apply Finset.sum_congr rfl
 intro n _
 -- b' (n+1) = b (n+2), b' n = b (n+1), partialSum a' (n+1) = partialSum₁ a (n+1).
 rw [hpsum (n + 1)]

/-! ### Sanity checks (trivial cases) -/

/-- Trivial case `N = 0`: both sides of the 1-indexed identity are `0`. -/
example (a b : ℕ → ℝ) :
 ∑ n ∈ Icc 1 0, a n * b n
 = partialSum₁ a 0 * b 0
 - ∑ n ∈ Ico 1 0, partialSum₁ a n * (b (n + 1) - b n) := by
 simp [partialSum₁]

/-- Trivial case `N = 1`: LHS = `a 1 * b 1`, RHS = `(a 1) * b 1 − 0`. -/
example (a b : ℕ → ℝ) :
 ∑ n ∈ Icc 1 1, a n * b n
 = partialSum₁ a 1 * b 1
 - ∑ n ∈ Ico 1 1, partialSum₁ a n * (b (n + 1) - b n) := by
 simp [partialSum₁]

end EG203R14MertensPartialSummation

/-! ### Axiom footprint receipts

The two main theorems must depend only on Lean's standard logical axioms
(`propext`, `Classical.choice`, `Quot.sound`) — no novel axioms from this
file. Verified by `#print axioms`. -/

#print axioms EG203R14MertensPartialSummation.abel_partial_summation_range
#print axioms EG203R14MertensPartialSummation.abel_partial_summation_Icc
