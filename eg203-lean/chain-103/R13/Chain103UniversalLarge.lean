import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Chain 103 m-dependent density — LARGE bounded universal statement

Push the universal-quantified native_decide as high as compiler tolerates.
Each theorem is one decide call covering ALL ordinary m in the range.

NO MATHEMATICAL AXIOMS — only `native_decide` (compiler trust).
-/

set_option maxRecDepth 16000

namespace EG203R13Chain103UniversalLarge

@[reducible] def V (m k l : ℕ) : ℕ := m * 2^k * 3^l + 1

def chainPrimes : List ℕ := [3, 5, 7, 11, 13, 17, 19]

def UniversalChainCoprime (N K : ℕ) : Prop :=
 ∀ m : Fin (N + 1),
 1 ≤ m.val → Nat.Coprime m.val 6 →
 ∃ k : Fin (K + 1), ∃ l : Fin (K + 1),
 ∀ q ∈ chainPrimes, ¬ (q ∣ V m.val k.val l.val)

instance (N K : ℕ) : Decidable (UniversalChainCoprime N K) := by
 unfold UniversalChainCoprime; exact inferInstance

/-- Chain 103 bounded m ≤ 1000, search [0, 32) × [0, 32). -/
theorem chain_103_bounded_1000 : UniversalChainCoprime 1000 31 := by native_decide

/-- Chain 103 bounded m ≤ 2000, search [0, 32) × [0, 32). -/
theorem chain_103_bounded_2000 : UniversalChainCoprime 2000 31 := by native_decide

/-- Chain 103 bounded m ≤ 5000, search [0, 64) × [0, 64). -/
theorem chain_103_bounded_5000 : UniversalChainCoprime 5000 63 := by native_decide

/-- Nat-form extraction for m ≤ 5000. -/
theorem exists_chain_coprime_nat_bounded_5000
 (m : ℕ) (hm_pos : 1 ≤ m) (hm_ub : m ≤ 5000) (hm_coprime : Nat.Coprime m 6) :
 ∃ k l : ℕ, k ≤ 63 ∧ l ≤ 63 ∧ ∀ q ∈ chainPrimes, ¬ (q ∣ V m k l) := by
 have hbnd : m < 5001 := by omega
 obtain ⟨k, l, hcoprime⟩ := chain_103_bounded_5000 ⟨m, hbnd⟩ hm_pos hm_coprime
 exact ⟨k.val, l.val, by omega, by omega, hcoprime⟩

end EG203R13Chain103UniversalLarge
