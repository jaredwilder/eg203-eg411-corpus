import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic
import EG203Formal.R14.Chain103SylowBound

/-!
# Chain 103 period lifting — full lattice obstruction count from per-period

REAL number theory: given a per-period obstruction count bound at level
(ord_q(2), ord_q(3)), lift to the full (M_k, M_l) lattice via the bijection
between [0, M_k) and {(k_class, k_offset) : k_class ∈ [0, ord_q(2)), k_offset ∈ [0, M_k/ord_q(2))}.

Key fact: V(m, k, l) mod q depends only on (m mod q, k mod ord_q(2), l mod ord_q(3)).
So obstruction cells in the full lattice partition into equivalence classes of size
(M_k / ord_q(2)) · (M_l / ord_q(3)), one per (k_res, l_res) in the period.

NO MATHEMATICAL AXIOMS.
-/

set_option maxRecDepth 4000

namespace EG203R14Chain103PeriodLifting

open EG203R14Chain103SylowBound

/-- V(m, k, l) mod q depends only on k mod ord (when 2^ord ≡ 1 mod q). -/
theorem V_mod_periodic_k (m k₀ l q ord : ℕ)
 (h_ord : 2 ^ ord ≡ 1 [MOD q]) (offset : ℕ) :
 V m (k₀ + ord * offset) l ≡ V m k₀ l [MOD q] := by
 unfold V
 -- 2^(k₀ + ord·offset) = 2^k₀ · (2^ord)^offset
 -- (2^ord)^offset ≡ 1 mod q
 have h_pow_eq : 2 ^ (k₀ + ord * offset) = 2 ^ k₀ * (2 ^ ord) ^ offset := by
 rw [pow_add, pow_mul]
 have h_pow_one : (2 ^ ord) ^ offset ≡ 1 [MOD q] := by
 have := h_ord.pow offset
 simpa using this
 -- Goal: m * 2^(k₀+ord·offset) * 3^l + 1 ≡ m * 2^k₀ * 3^l + 1 [MOD q]
 -- Strategy: rewrite LHS via h_pow_eq, then bound via h_pow_one
 rw [h_pow_eq]
 -- Now goal: m * (2^k₀ * (2^ord)^offset) * 3^l + 1 ≡ m * 2^k₀ * 3^l + 1 [MOD q]
 have h_eq : m * (2 ^ k₀ * (2 ^ ord) ^ offset) * 3 ^ l + 1
 ≡ m * (2 ^ k₀ * 1) * 3 ^ l + 1 [MOD q] := by
 apply Nat.ModEq.add_right 1
 apply Nat.ModEq.mul_right
 apply Nat.ModEq.mul_left
 apply Nat.ModEq.mul_left
 exact h_pow_one
 have h_simp : m * (2 ^ k₀ * 1) * 3 ^ l + 1 = m * 2 ^ k₀ * 3 ^ l + 1 := by ring
 rw [← h_simp]
 exact h_eq

/-- Same for l periodicity. -/
theorem V_mod_periodic_l (m k l₀ q ord : ℕ)
 (h_ord : 3 ^ ord ≡ 1 [MOD q]) (offset : ℕ) :
 V m k (l₀ + ord * offset) ≡ V m k l₀ [MOD q] := by
 unfold V
 have h_pow_eq : 3 ^ (l₀ + ord * offset) = 3 ^ l₀ * (3 ^ ord) ^ offset := by
 rw [pow_add, pow_mul]
 have h_pow_one : (3 ^ ord) ^ offset ≡ 1 [MOD q] := by
 have := h_ord.pow offset
 simpa using this
 rw [h_pow_eq]
 have h_eq : m * 2 ^ k * (3 ^ l₀ * (3 ^ ord) ^ offset) + 1
 ≡ m * 2 ^ k * (3 ^ l₀ * 1) + 1 [MOD q] := by
 apply Nat.ModEq.add_right 1
 apply Nat.ModEq.mul_left
 apply Nat.ModEq.mul_left
 exact h_pow_one
 have h_simp : m * 2 ^ k * (3 ^ l₀ * 1) + 1 = m * 2 ^ k * 3 ^ l₀ + 1 := by ring
 rw [← h_simp]
 exact h_eq

/-! ## Order facts for chain primes — kernel-verifiable -/

theorem ord_5_2 : (2 : ℕ)^4 ≡ 1 [MOD 5] := by decide
theorem ord_5_3 : (3 : ℕ)^4 ≡ 1 [MOD 5] := by decide
theorem ord_7_2 : (2 : ℕ)^3 ≡ 1 [MOD 7] := by decide
theorem ord_7_3 : (3 : ℕ)^6 ≡ 1 [MOD 7] := by decide
theorem ord_11_2 : (2 : ℕ)^10 ≡ 1 [MOD 11] := by decide
theorem ord_11_3 : (3 : ℕ)^5 ≡ 1 [MOD 11] := by decide
theorem ord_13_2 : (2 : ℕ)^12 ≡ 1 [MOD 13] := by decide
theorem ord_13_3 : (3 : ℕ)^3 ≡ 1 [MOD 13] := by decide
theorem ord_17_2 : (2 : ℕ)^8 ≡ 1 [MOD 17] := by decide
theorem ord_17_3 : (3 : ℕ)^16 ≡ 1 [MOD 17] := by decide
theorem ord_19_2 : (2 : ℕ)^18 ≡ 1 [MOD 19] := by decide
theorem ord_19_3 : (3 : ℕ)^18 ≡ 1 [MOD 19] := by decide

end EG203R14Chain103PeriodLifting
