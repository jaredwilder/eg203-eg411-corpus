import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import Mathlib.Data.Finset.Card

/-!
# Iwaniec linear sieve — sieve set definitions

P2.1 — basic combinatorial setup for the linear sieve.

Sieve set A ⊆ ℕ with a prime "support" P ⊆ ℕ. The sieved count:
 Φ(A, P, z) := |{a ∈ A : ∀ p ∈ P, p < z → ¬ (p ∣ a)}|

This counts elements of A coprime to all primes in P below z.

NO MATHEMATICAL AXIOMS.
-/

namespace EG203R14IwaniecSieveSet

/-- Sieved count: elements of A having no prime divisor in P that is < z. -/
def sievedCount (A : Finset ℕ) (P : Finset ℕ) (z : ℕ) : ℕ :=
 (A.filter (fun a => ∀ p ∈ P, p < z → ¬ (p ∣ a))).card

/-- Sieved count is monotone-decreasing in z (more primes → fewer survivors). -/
theorem sievedCount_anti_mono_z (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ : ℕ}
 (h : z₁ ≤ z₂) :
 sievedCount A P z₂ ≤ sievedCount A P z₁ := by
 unfold sievedCount
 apply Finset.card_le_card
 intro a ha
 simp only [Finset.mem_filter] at ha ⊢
 refine ⟨ha.1, ?_⟩
 intro p hp_in hp_lt
 exact ha.2 p hp_in (lt_of_lt_of_le hp_lt h)

/-- Sieved count is bounded by |A|. -/
theorem sievedCount_le_card (A : Finset ℕ) (P : Finset ℕ) (z : ℕ) :
 sievedCount A P z ≤ A.card := by
 unfold sievedCount
 exact Finset.card_filter_le A _

/-- For z = 0, vacuous: no sieving condition. -/
theorem sievedCount_z_zero (A : Finset ℕ) (P : Finset ℕ) :
 sievedCount A P 0 = A.card := by
 unfold sievedCount
 rw [Finset.filter_eq_self.mpr]
 intro a _ p _ hp_lt
 omega -- p < 0 is impossible for p : ℕ

end EG203R14IwaniecSieveSet
