import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic

/-!
# Chain 103 m-dependent density CRT PERIODICITY

REAL number theory: chain coprimality of V(m, k, l) = m·2^k·3^l + 1 on the
(M_k, M_l) = (360, 720) lattice only depends on `m mod Π(chain primes)`.

This is the structural reduction that turns "verify for all m ≥ 1" into
"verify for all m ∈ [1, 3·5·7·11·13·17·19]" = [1, 4849845].

NO MATHEMATICAL AXIOMS. Pure modular arithmetic.
-/

namespace EG203R13Chain103PeriodicityCRT

@[reducible] def V (m k l : ℕ) : ℕ := m * 2^k * 3^l + 1

/-- The chain prime product M = 3·5·7·11·13·17·19. -/
def chainPrimeProduct : ℕ := 3 * 5 * 7 * 11 * 13 * 17 * 19

theorem chainPrimeProduct_eq : chainPrimeProduct = 4849845 := by
 unfold chainPrimeProduct; norm_num

/-- For any q, V(m, k, l) mod q depends only on m mod q. -/
theorem V_mod_q_depends_on_m_mod_q (m₁ m₂ k l q : ℕ)
 (h_eq : m₁ ≡ m₂ [MOD q]) :
 V m₁ k l ≡ V m₂ k l [MOD q] := by
 unfold V
 have h1 : m₁ * 2^k ≡ m₂ * 2^k [MOD q] := Nat.ModEq.mul_right (2^k) h_eq
 have h2 : m₁ * 2^k * 3^l ≡ m₂ * 2^k * 3^l [MOD q] := Nat.ModEq.mul_right (3^l) h1
 exact Nat.ModEq.add_right 1 h2

/-- Helper: ¬ (q ∣ V) transports across m mod q equivalence. -/
theorem not_dvd_V_transport {m₁ m₂ k l q : ℕ}
 (h_eq : m₁ ≡ m₂ [MOD q]) (h : ¬ (q ∣ V m₁ k l)) :
 ¬ (q ∣ V m₂ k l) := by
 intro hcontra
 apply h
 exact (Nat.modEq_zero_iff_dvd).mp
 ((V_mod_q_depends_on_m_mod_q m₁ m₂ k l q h_eq).trans
 ((Nat.modEq_zero_iff_dvd).mpr hcontra))

/-- The chain 103 m-dependent coprimality predicate (parameterized over m). -/
def ChainCoprime (m K : ℕ) : Prop :=
 ∃ k l : ℕ, k ≤ K ∧ l ≤ K ∧
 ¬ (3 ∣ V m k l) ∧ ¬ (5 ∣ V m k l) ∧ ¬ (7 ∣ V m k l) ∧
 ¬ (11 ∣ V m k l) ∧ ¬ (13 ∣ V m k l) ∧ ¬ (17 ∣ V m k l) ∧ ¬ (19 ∣ V m k l)

/-- ChainCoprime depends only on m mod chainPrimeProduct. -/
theorem chain_coprime_periodic (m₁ m₂ K : ℕ)
 (h_eq : m₁ ≡ m₂ [MOD chainPrimeProduct]) :
 ChainCoprime m₁ K ↔ ChainCoprime m₂ K := by
 have h3 : m₁ ≡ m₂ [MOD 3] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h5 : m₁ ≡ m₂ [MOD 5] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h7 : m₁ ≡ m₂ [MOD 7] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h11 : m₁ ≡ m₂ [MOD 11] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h13 : m₁ ≡ m₂ [MOD 13] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h17 : m₁ ≡ m₂ [MOD 17] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 have h19 : m₁ ≡ m₂ [MOD 19] := h_eq.of_dvd (by unfold chainPrimeProduct; decide)
 constructor
 · rintro ⟨k, l, hk, hl, h3d, h5d, h7d, h11d, h13d, h17d, h19d⟩
 exact ⟨k, l, hk, hl,
 not_dvd_V_transport h3 h3d,
 not_dvd_V_transport h5 h5d,
 not_dvd_V_transport h7 h7d,
 not_dvd_V_transport h11 h11d,
 not_dvd_V_transport h13 h13d,
 not_dvd_V_transport h17 h17d,
 not_dvd_V_transport h19 h19d⟩
 · rintro ⟨k, l, hk, hl, h3d, h5d, h7d, h11d, h13d, h17d, h19d⟩
 exact ⟨k, l, hk, hl,
 not_dvd_V_transport h3.symm h3d,
 not_dvd_V_transport h5.symm h5d,
 not_dvd_V_transport h7.symm h7d,
 not_dvd_V_transport h11.symm h11d,
 not_dvd_V_transport h13.symm h13d,
 not_dvd_V_transport h17.symm h17d,
 not_dvd_V_transport h19.symm h19d⟩

end EG203R13Chain103PeriodicityCRT
