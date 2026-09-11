import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R13.Chain103PeriodicityCRT

/-!
# Chain 103 BOUNDED → UNBOUNDED reduction via CRT periodicity

REAL number theory:
- CRT Periodicity: ChainCoprime depends only on m mod 4849845.
- Therefore: if ChainCoprime m K holds for ALL m ∈ [1, 4849845],
 then ChainCoprime holds for ALL m ≥ 1.

NO MATHEMATICAL AXIOMS. This is the structural framework — the bounded
m ∈ [1, 4849845] check is the only computational work left for unconditional
chain 103 m-dependent density.
-/

namespace EG203R13Chain103UniversalReduction

open EG203R13Chain103PeriodicityCRT

/-- The full reduction: bounded ChainCoprime in [1, M] implies
 universal ChainCoprime for all m ≥ 1, where M = chainPrimeProduct = 4849845. -/
theorem bounded_implies_universal (K : ℕ)
 (h_bounded : ∀ m : ℕ, 1 ≤ m → m ≤ chainPrimeProduct → ChainCoprime m K) :
 ∀ m : ℕ, 1 ≤ m → ChainCoprime m K := by
 intro m hm
 set M := chainPrimeProduct with hM_def
 have hM_pos : 0 < M := by show 0 < chainPrimeProduct; unfold chainPrimeProduct; decide
 set m' := (m - 1) % M + 1 with hm'_def
 have hm'_pos : 1 ≤ m' := by show 1 ≤ (m - 1) % M + 1; omega
 have hm'_le : m' ≤ M := by
 show (m - 1) % M + 1 ≤ M
 have h_mod_lt : (m - 1) % M < M := Nat.mod_lt _ hM_pos
 omega
 have h_mod_eq : m ≡ m' [MOD M] := by
 show m ≡ (m - 1) % M + 1 [MOD M]
 have h_m_sub_eq : m - 1 ≡ (m - 1) % M [MOD M] :=
 (Nat.mod_modEq (m - 1) M).symm
 have h_m_unfold : m = (m - 1) + 1 := by omega
 conv_lhs => rw [h_m_unfold]
 exact Nat.ModEq.add_right 1 h_m_sub_eq
 exact (chain_coprime_periodic m m' K h_mod_eq).mpr
 (h_bounded m' hm'_pos hm'_le)

/-- Coprime-preserving reduction modulus: 2 * chainPrimeProduct = 9699690. -/
def coprimeReductionModulus : ℕ := 2 * chainPrimeProduct

theorem coprimeReductionModulus_eq : coprimeReductionModulus = 9699690 := by
 unfold coprimeReductionModulus chainPrimeProduct; norm_num

/-- Coprime-preserving reduction: m ≡ m' mod 2·M preserves both
 chain coprimality (via M | 2·M) and parity (so Coprime m 6 ↔ Coprime m' 6
 when both m, m' are not divisible by 3, which is guaranteed by chain primes). -/
theorem bounded_ordinary_implies_universal_ordinary (K : ℕ)
 (h_bounded : ∀ m : ℕ, 1 ≤ m → m ≤ coprimeReductionModulus →
 Nat.Coprime m 6 → ChainCoprime m K) :
 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 → ChainCoprime m K := by
 intro m hm hcop
 set M2 := coprimeReductionModulus with hM2_def
 have hM2_pos : 0 < M2 := by show 0 < coprimeReductionModulus; unfold coprimeReductionModulus chainPrimeProduct; decide
 set m' := (m - 1) % M2 + 1 with hm'_def
 have hm'_pos : 1 ≤ m' := by show 1 ≤ (m - 1) % M2 + 1; omega
 have hm'_le : m' ≤ M2 := by
 show (m - 1) % M2 + 1 ≤ M2
 have h_mod_lt : (m - 1) % M2 < M2 := Nat.mod_lt _ hM2_pos
 omega
 have h_mod_eq_M2 : m ≡ m' [MOD M2] := by
 show m ≡ (m - 1) % M2 + 1 [MOD M2]
 have h_m_sub_eq : m - 1 ≡ (m - 1) % M2 [MOD M2] :=
 (Nat.mod_modEq (m - 1) M2).symm
 have h_m_unfold : m = (m - 1) + 1 := by omega
 conv_lhs => rw [h_m_unfold]
 exact Nat.ModEq.add_right 1 h_m_sub_eq
 -- M2 = 2 · chainPrimeProduct, so chainPrimeProduct | M2
 have h_M_dvd_M2 : chainPrimeProduct ∣ M2 := by
 show chainPrimeProduct ∣ coprimeReductionModulus
 unfold coprimeReductionModulus; exact ⟨2, by ring⟩
 have h_mod_eq_M : m ≡ m' [MOD chainPrimeProduct] := h_mod_eq_M2.of_dvd h_M_dvd_M2
 -- Coprime preservation: m ≡ m' [MOD 6] since 6 | M2
 have h_6_dvd_M2 : (6 : ℕ) ∣ M2 := by
 show (6 : ℕ) ∣ coprimeReductionModulus
 unfold coprimeReductionModulus chainPrimeProduct; decide
 have h_mod_eq_6 : m ≡ m' [MOD 6] := h_mod_eq_M2.of_dvd h_6_dvd_M2
 have hcop' : Nat.Coprime m' 6 := by
 unfold Nat.Coprime at *
 -- Nat.ModEq.gcd_eq : a ≡ b [MOD m] → gcd a m = gcd b m
 have h_gcd : Nat.gcd m 6 = Nat.gcd m' 6 := Nat.ModEq.gcd_eq h_mod_eq_6
 rw [← h_gcd]; exact hcop
 exact (chain_coprime_periodic m m' K h_mod_eq_M).mpr
 (h_bounded m' hm'_pos hm'_le hcop')

end EG203R13Chain103UniversalReduction
