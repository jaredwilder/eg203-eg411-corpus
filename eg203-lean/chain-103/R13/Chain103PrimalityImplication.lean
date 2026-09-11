import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R13.Chain103UniversalMega

/-!
# Chain 103 → Primality CLEAN implication (no sorry)

CORRECT statement of what chain 103 m-dependent coprimality implies:
For V(m, k, l) coprime to chain primes {3, 5, 7, 11, 13, 17, 19},
the smallest prime factor of V (if any prime factor exists) is
either 2 OR ≥ 23.

For V > 23 and V odd, V's smallest prime factor is ≥ 23, so V has
"sieve depth" at least 23.

NO MATHEMATICAL AXIOMS. Pure Lean.
-/

namespace EG203R13Chain103PrimalityImplication

open EG203R13Chain103UniversalMega

/-- Smallest prime factor of V is NOT in chain primes if V chain-coprime. -/
theorem chain_coprime_no_chain_factor
 (m k l : ℕ) (hcop : ∀ q ∈ chainPrimes, ¬ (q ∣ V m k l)) :
 ∀ q ∈ chainPrimes, ¬ (q ∣ V m k l) := hcop

/-- The CORRECT bridge: chain-coprime + odd V ⟹ smallest prime factor ≥ 23. -/
theorem chain_coprime_odd_smallest_prime_factor_at_least_23
 (m k l : ℕ)
 (hV_odd : ¬ (2 ∣ V m k l))
 (hcop : ∀ q ∈ chainPrimes, ¬ (q ∣ V m k l))
 (p : ℕ) (hp : p.Prime) (hpdvd : p ∣ V m k l) :
 23 ≤ p := by
 by_contra hlt
 push_neg at hlt
 have hp2 : 2 ≤ p := hp.two_le
 interval_cases p
 · exact absurd hpdvd hV_odd
 · exact absurd hpdvd (hcop 3 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 5 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 7 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 11 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 13 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 17 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hpdvd (hcop 19 (by simp [chainPrimes]))
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)
 · exact absurd hp (by decide)

/-- V is odd when k ≥ 1 (since 2^k contributes a factor of 2). -/
theorem V_odd_when_k_pos (m k l : ℕ) (hk : 1 ≤ k) (hm : Odd m → True) :
 ¬ (2 ∣ V m k l) := by
 unfold V
 -- V = m·2^k·3^l + 1; since k ≥ 1, 2 ∣ 2^k, so 2 ∣ m·2^k·3^l, so V ≡ 1 mod 2
 intro h
 -- m·2^k·3^l + 1 = 2 * j for some j
 have h_even_mul : 2 ∣ (m * 2 ^ k * 3 ^ l) := by
 have h2k : 2 ∣ 2 ^ k := dvd_pow_self 2 (by omega : k ≠ 0)
 have : 2 ∣ (m * 2 ^ k) := Dvd.dvd.mul_left h2k m
 exact Dvd.dvd.mul_right this (3 ^ l)
 -- So m·2^k·3^l + 1 ≡ 1 mod 2, contradiction with 2 ∣ V
 have : m * 2 ^ k * 3 ^ l + 1 ≡ 1 [MOD 2] := by
 have h_zero : m * 2 ^ k * 3 ^ l ≡ 0 [MOD 2] := by
 exact (Nat.modEq_zero_iff_dvd).mpr h_even_mul
 calc m * 2 ^ k * 3 ^ l + 1 ≡ 0 + 1 [MOD 2] := Nat.ModEq.add_right 1 h_zero
 _ = 1 := by omega
 -- h says 2 ∣ V, but V ≡ 1 mod 2, contradiction
 have h2 : V m k l ≡ 0 [MOD 2] := (Nat.modEq_zero_iff_dvd).mpr h
 unfold V at h2
 have hcontra : (1 : ℕ) ≡ 0 [MOD 2] := this.symm.trans h2
 exact absurd hcontra (by decide)

/-- Combined: chain-coprime + k ≥ 1 ⟹ smallest prime factor of V ≥ 23.
 This is the CORRECT chain 103 → primality lower-bound bridge. -/
theorem chain_coprime_with_k_pos_smallest_prime_at_least_23
 (m k l : ℕ) (hk : 1 ≤ k)
 (hcop : ∀ q ∈ chainPrimes, ¬ (q ∣ V m k l))
 (p : ℕ) (hp : p.Prime) (hpdvd : p ∣ V m k l) :
 23 ≤ p := by
 apply chain_coprime_odd_smallest_prime_factor_at_least_23 m k l
 · exact V_odd_when_k_pos m k l hk (fun _ => trivial)
 · exact hcop
 · exact hp
 · exact hpdvd

end EG203R13Chain103PrimalityImplication
