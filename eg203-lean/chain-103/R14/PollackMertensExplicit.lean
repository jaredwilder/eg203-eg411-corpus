import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum

/-!
# P1 — Explicit RATIONAL Mertens products for chain 103 primes

REAL Lean number theory (no axioms): kernel-checkable explicit rational
Mertens products for finite prime sets, matching EG#411's
`FiniteProductMertens.lean` style.

The Mertens product `∏_{p ≤ z}(1 - 1/p)` for finite z is a RATIONAL CONSTANT
computable directly. For z = 23 (our chain 103 boundary):

 V(23) = (1/2)·(2/3)·(4/5)·(6/7)·(10/11)·(12/13)·(16/17)·(18/19)·(22/23)
 = 1,658,880·22 / (9,699,690·23)
 = 36,495,360 / 223,092,870
 ≈ 0.16358

For the SIEVE LOWER BOUND on chain-coprime cells with prime factor ≥ 23,
we use this explicit V(23) constant.

NO MATHEMATICAL AXIOMS. norm_num + Rat arithmetic.
-/

namespace EG203R14PollackMertensExplicit

/-- The explicit rational Mertens product over primes {2, 3, 5, 7, 11, 13, 17, 19}. -/
def mertensProduct_chain : ℚ :=
 (1/2) * (2/3) * (4/5) * (6/7) * (10/11) * (12/13) * (16/17) * (18/19)

theorem mertensProduct_chain_eq : mertensProduct_chain = 1658880 / 9699690 := by
 unfold mertensProduct_chain
 norm_num

/-- The explicit rational Mertens product including p = 23. -/
def mertensProduct_through_23 : ℚ := mertensProduct_chain * (22/23)

theorem mertensProduct_through_23_eq :
 mertensProduct_through_23 = 36495360 / 223092870 := by
 unfold mertensProduct_through_23 mertensProduct_chain
 norm_num

/-- Lower bound on V(23) as a rational: V(23) ≥ 16/100 = 0.16. -/
theorem mertensProduct_through_23_ge_0_16 :
 (16 : ℚ) / 100 ≤ mertensProduct_through_23 := by
 rw [mertensProduct_through_23_eq]
 norm_num

/-- The 99225 chain 103 base cell count (chain-103 master log). -/
def chain103_base_cells : ℕ := 99225

theorem chain103_base_cells_eq : chain103_base_cells = 315 * 315 := by
 unfold chain103_base_cells
 norm_num

/-- The 73080 universal chain-coprime cell lower bound (from P0). -/
def universal_chain_coprime_lower : ℕ := 73080

/-- Heuristic prime count estimate (Bateman-Horn-like):
 For sieve set of size N with sieve dim 0 and X total integers,
 # primes ≈ N · V(z) · f(s) where s = log X / log z.

 For our V family with N = 73080, z = 23, X = m · 6^D:
 Expected primes ≈ 73080 · 0.16 · f(s) ≈ 11,693 · f(s).

 For f(s) ≥ 1/100 (mild lower bound), expected primes ≥ 117 > 0.
 The exact f(s) bound comes from Iwaniec's recursion (Phase 2).

 This file establishes the CONSTANTS. The asymptotic f(s) > 0 lives in Phase 2.
-/
theorem prime_count_heuristic_constant :
 (universal_chain_coprime_lower : ℚ) * mertensProduct_through_23 ≥ 11000 := by
 unfold universal_chain_coprime_lower
 rw [mertensProduct_through_23_eq]
 norm_num

end EG203R14PollackMertensExplicit
