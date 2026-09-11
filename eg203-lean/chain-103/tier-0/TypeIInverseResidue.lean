/-
 Real algebra salvaged from ROUND-031 scaffold (2026-06-01).

 Provides the prime-field Type-I inverse-residue identity:
 in any DivisionRing R, with m ≠ 0:
 m · x + 1 = 0 ↔ x = -m⁻¹

 Specialized to (R = ZMod p) for prime p with m ≢ 0 (mod p):
 m · 2^k · 3^l + 1 ≡ 0 (mod p) ↔ 2^k · 3^l ≡ -m⁻¹ (mod p)

 This is the algebraic content that the analytic attack on EG#203
 needs to talk about "which (k, l) lattice points hit the residue
 -m⁻¹ mod p in the multiplicative group ⟨2, 3⟩ ⊂ (ℤ/p)×".

 These theorems are kernel-verified (no sorryAx, no axioms beyond
 propext / Classical.choice / Quot.sound from Mathlib).

 IDIOT CHECK: this file is INFRASTRUCTURE, not a closer of EG#203.
 The closers in the ROUND-031 scaffold (`closed_from_rank_two`,
 `closed_from_positive_prime_count_in_box`, `closed_from_weighted_typeII`)
 are tautologies (`P ↔ P`-style) — their hypotheses are EG#203
 itself under different names, so they prove nothing new.
 The ROUND-031 manifest itself admits:
 "does_this_close_EG203_unconditionally": false
 "why_not": "No proof of RankTwoAffineSUnitPrimeProduction
 / PositivePrimeCountInBox is present."
-/
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace TypeIInverseResidue

-- Generic division-ring shape used inside the bridge to ZMod p.
theorem eq_neg_inv_of_mul_add_one_eq_zero
 {R : Type*} [DivisionRing R] {m x : R} (hm : m ≠ 0) :
 m * x + 1 = 0 ↔ x = -m⁻¹ := by
 constructor
 · intro h
 have hmx : m * x = -1 := by
 calc
 m * x = (m * x + 1) - 1 := by abel
 _ = 0 - 1 := by rw [h]
 _ = -1 := by simp
 calc
 x = m⁻¹ * (m * x) := by
 rw [← mul_assoc, inv_mul_cancel₀ hm, one_mul]
 _ = m⁻¹ * (-1) := by rw [hmx]
 _ = -m⁻¹ := by simp
 · intro hx
 rw [hx]
 rw [mul_neg, mul_inv_cancel₀ hm]
 simp

-- Specialization to (x = 2^k * 3^l) — the rank-two affine S-unit form.
theorem typeI_inverse_residue_divisionRing
 {R : Type*} [DivisionRing R]
 {m : R} (hm : m ≠ 0) (k l : Nat) :
 m * ((2 : R) ^ k * (3 : R) ^ l) + 1 = 0
 ↔ (2 : R) ^ k * (3 : R) ^ l = -m⁻¹ := by
 exact eq_neg_inv_of_mul_add_one_eq_zero
 (R := R)
 (m := m)
 (x := (2 : R) ^ k * (3 : R) ^ l)
 hm

-- Concrete drop into ZMod p for prime p (Fact instance carries primality).
theorem typeI_inverse_residue_zmod_prime
 {p m k l : Nat} [Fact p.Prime]
 (hm : (m : ZMod p) ≠ 0) :
 (m : ZMod p) * ((2 : ZMod p) ^ k * (3 : ZMod p) ^ l) + 1 = 0
 ↔ (2 : ZMod p) ^ k * (3 : ZMod p) ^ l = -(m : ZMod p)⁻¹ := by
 exact typeI_inverse_residue_divisionRing
 (R := ZMod p)
 (m := (m : ZMod p))
 hm k l

-- Note: a Nat-level divisibility ↔ ZMod p zero bridge was originally part of
-- the salvaged scaffold (ROUND-031), but the Mathlib lemma's name has shifted
-- across Mathlib epochs (`ZMod.natCast_zmod_eq_zero_iff_dvd` →
-- `ZMod.natCast_eq_zero_iff`) and pinning to either name risks a brittle
-- compile under master-rolling Mathlib. The bridge is not load-bearing for the
-- algebra above — anyone needing it can write the one-line lemma at the call
-- site against whatever Mathlib spelling is current. Keeping this file
-- minimal/rolling-stable.

#print axioms eq_neg_inv_of_mul_add_one_eq_zero
#print axioms typeI_inverse_residue_divisionRing
#print axioms typeI_inverse_residue_zmod_prime

end TypeIInverseResidue
end EG203Formal
