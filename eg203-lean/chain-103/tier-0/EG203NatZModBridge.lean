/-
 EG203NatZModBridge.lean -- 2026-06-01

 Load-bearing infrastructure, not a closer.

 This file connects the Nat divisibility statement used by the sieve/
 covering side of EG#203 with the ZMod inverse-residue statement proved
 in TypeIInverseResidue.lean:

 p | m*2^k*3^l + 1
 <-> 2^k*3^l = -m^{-1} in ZMod p

 for prime p with m nonzero mod p.

 NO SORRY. NO ADMIT. NO NOVEL AXIOM.
-/

import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace NatZModBridge

@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

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

/-- Cast the EG#203 translate into `ZMod p`. -/
theorem natCast_V (p m k l : Nat) :
 ((V m k l : Nat) : ZMod p) =
 (m : ZMod p) * ((2 : ZMod p) ^ k * (3 : ZMod p) ^ l) + 1 := by
 simp [V, mul_assoc]

/-- Nat divisibility is exactly vanishing after casting to `ZMod p`. -/
theorem dvd_V_iff_zmod_zero (p m k l : Nat) :
 p ∣ V m k l ↔
 (m : ZMod p) * ((2 : ZMod p) ^ k * (3 : ZMod p) ^ l) + 1 = 0 := by
 rw [← ZMod.natCast_eq_zero_iff]
 simp [natCast_V, V, mul_assoc]

/-- The source-pinned danger coset identity for a prime divisor of `V m k l`. -/
theorem prime_dvd_V_iff_typeI_forbidden_residue
 {p m k l : Nat} [Fact p.Prime]
 (hm : (m : ZMod p) ≠ 0) :
 p ∣ V m k l ↔
 (2 : ZMod p) ^ k * (3 : ZMod p) ^ l = -(m : ZMod p)⁻¹ := by
 rw [dvd_V_iff_zmod_zero]
 exact eq_neg_inv_of_mul_add_one_eq_zero
 (R := ZMod p)
 (m := (m : ZMod p))
 (x := (2 : ZMod p) ^ k * (3 : ZMod p) ^ l)
 hm

#print axioms eq_neg_inv_of_mul_add_one_eq_zero
#print axioms natCast_V
#print axioms dvd_V_iff_zmod_zero
#print axioms prime_dvd_V_iff_typeI_forbidden_residue

end NatZModBridge
end EG203Formal
