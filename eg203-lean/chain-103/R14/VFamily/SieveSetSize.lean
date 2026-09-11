import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Tactic
import EG203Formal.R14.Chain103UniversalDensity

/-!
# P3.3 — V-family sieve set size bound

The V-family sieve set is the image of the chain-coprime cells under V.
We bound its cardinality both above (trivial via `card_image_le`) and
below (via injectivity of V in (k, l) when m ≥ 1).

Combined with `chain_coprime_count_ge_73080`, we obtain the universal
lower bound `73080 ≤ |vFamilySieveSet m|` for all m ≥ 1.

NO SORRIES. NO MATHEMATICAL AXIOMS.
-/

set_option maxRecDepth 4000

namespace EG203R14VFamilySieveSetSize

open EG203R14Chain103FullLatticeBound (V)
open EG203R14Chain103UniversalDensity (chainCoprime fullLattice
 chain_coprime_count_ge_73080)

/-- The V-family sieve set: image of chain-coprime cells under V. -/
def vFamilySieveSet (m : ℕ) : Finset ℕ :=
 (chainCoprime m).image (fun kl => V m kl.1 kl.2)

/-- Trivial upper bound: the image is no larger than the source. -/
theorem vFamilySieveSet_card_le_chainCoprime (m : ℕ) :
 (vFamilySieveSet m).card ≤ (chainCoprime m).card := by
 unfold vFamilySieveSet
 exact Finset.card_image_le

/-! ## Injectivity of V on lattice indices (for m ≥ 1)

We prove `2^k₁ * 3^l₁ = 2^k₂ * 3^l₂ → k₁ = k₂ ∧ l₁ = l₂` via the
2-adic valuation and then division. From this we deduce V is injective. -/

/-- 2 does not divide 3. -/
private lemma two_not_dvd_three : ¬ (2 ∣ 3) := by decide

/-- 2 does not divide `3^l` for any l. -/
private lemma two_not_dvd_three_pow (l : ℕ) : ¬ (2 ∣ 3^l) := by
 intro h
 have h2p : Nat.Prime 2 := by decide
 rcases (Nat.Prime.dvd_of_dvd_pow h2p h) with hd
 exact two_not_dvd_three hd

/-- 3 does not divide 2. -/
private lemma three_not_dvd_two : ¬ (3 ∣ 2) := by decide

/-- 3 does not divide `2^k` for any k. -/
private lemma three_not_dvd_two_pow (k : ℕ) : ¬ (3 ∣ 2^k) := by
 intro h
 have h3p : Nat.Prime 3 := by decide
 rcases (Nat.Prime.dvd_of_dvd_pow h3p h) with hd
 exact three_not_dvd_two hd

/-- 2-adic valuation: `Nat.factorization (2^k * 3^l) 2 = k`. -/
private lemma factorization_two_of_two_pow_three_pow (k l : ℕ) :
 Nat.factorization (2 ^ k * 3 ^ l) 2 = k := by
 have h2p : Nat.Prime 2 := by decide
 have h3p : Nat.Prime 3 := by decide
 have hne : (3:ℕ) ^ l ≠ 0 := pow_ne_zero l (by norm_num)
 have hne2 : (2:ℕ) ^ k ≠ 0 := pow_ne_zero k (by norm_num)
 rw [Nat.factorization_mul hne2 hne]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]

/-- 3-adic valuation: `Nat.factorization (2^k * 3^l) 3 = l`. -/
private lemma factorization_three_of_two_pow_three_pow (k l : ℕ) :
 Nat.factorization (2 ^ k * 3 ^ l) 3 = l := by
 have h2p : Nat.Prime 2 := by decide
 have h3p : Nat.Prime 3 := by decide
 have hne : (3:ℕ) ^ l ≠ 0 := pow_ne_zero l (by norm_num)
 have hne2 : (2:ℕ) ^ k ≠ 0 := pow_ne_zero k (by norm_num)
 rw [Nat.factorization_mul hne2 hne]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]

/-- Unique factorization for 2-3 numbers:
 `2^k₁ * 3^l₁ = 2^k₂ * 3^l₂ → k₁ = k₂ ∧ l₁ = l₂`. -/
private lemma two_three_pow_inj (k₁ l₁ k₂ l₂ : ℕ)
 (h : 2 ^ k₁ * 3 ^ l₁ = 2 ^ k₂ * 3 ^ l₂) :
 k₁ = k₂ ∧ l₁ = l₂ := by
 have hk : k₁ = k₂ := by
 have := factorization_two_of_two_pow_three_pow k₁ l₁
 have h2 := factorization_two_of_two_pow_three_pow k₂ l₂
 rw [h] at this
 omega
 have hl : l₁ = l₂ := by
 have := factorization_three_of_two_pow_three_pow k₁ l₁
 have h2 := factorization_three_of_two_pow_three_pow k₂ l₂
 rw [h] at this
 omega
 exact ⟨hk, hl⟩

/-- V is injective in (k, l) when m ≥ 1.

 `V m k₁ l₁ = V m k₂ l₂` unfolds to
 `m * 2^k₁ * 3^l₁ + 1 = m * 2^k₂ * 3^l₂ + 1`,
 which cancels to `m * 2^k₁ * 3^l₁ = m * 2^k₂ * 3^l₂`,
 then divides by m ≥ 1, then applies unique factorization. -/
theorem V_injective_of_pos {m : ℕ} (hm : 1 ≤ m) :
 Function.Injective (fun kl : ℕ × ℕ => V m kl.1 kl.2) := by
 intro ⟨k₁, l₁⟩ ⟨k₂, l₂⟩ h
 unfold V at h
 simp only at h
 -- h : m * 2^k₁ * 3^l₁ + 1 = m * 2^k₂ * 3^l₂ + 1
 have h' : m * 2^k₁ * 3^l₁ = m * 2^k₂ * 3^l₂ := by omega
 -- Rewrite as m * (2^k₁ * 3^l₁) = m * (2^k₂ * 3^l₂)
 have h'' : m * (2^k₁ * 3^l₁) = m * (2^k₂ * 3^l₂) := by ring_nf; ring_nf at h'; linarith
 have hmpos : 0 < m := hm
 have heq : 2^k₁ * 3^l₁ = 2^k₂ * 3^l₂ :=
 Nat.eq_of_mul_eq_mul_left hmpos h''
 obtain ⟨hk, hl⟩ := two_three_pow_inj k₁ l₁ k₂ l₂ heq
 exact Prod.mk.injEq .. |>.mpr ⟨hk, hl⟩

/-- V is injective on `chainCoprime m` for m ≥ 1 (specialization). -/
theorem V_injective_on_chain_coprime {m : ℕ} (hm : 1 ≤ m) :
 Set.InjOn (fun kl : ℕ × ℕ => V m kl.1 kl.2) (chainCoprime m : Set (ℕ × ℕ)) := by
 intro a _ b _ h
 exact V_injective_of_pos hm h

/-- The image card equals the source card when V is injective. -/
theorem vFamilySieveSet_card_eq_chainCoprime {m : ℕ} (hm : 1 ≤ m) :
 (vFamilySieveSet m).card = (chainCoprime m).card := by
 unfold vFamilySieveSet
 apply Finset.card_image_of_injOn
 exact V_injective_on_chain_coprime hm

/-- **MAIN RESULT P3.3:** For all m ≥ 1, the V-family sieve set has
 ≥ 73080 elements. -/
theorem vFamilySieveSet_card_ge {m : ℕ} (hm : 1 ≤ m) :
 73080 ≤ (vFamilySieveSet m).card := by
 rw [vFamilySieveSet_card_eq_chainCoprime hm]
 exact chain_coprime_count_ge_73080 m

end EG203R14VFamilySieveSetSize
