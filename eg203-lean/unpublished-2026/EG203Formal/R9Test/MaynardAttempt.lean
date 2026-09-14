import Mathlib.NumberTheory.Bertrand
import Mathlib.NumberTheory.LSeries.PrimesInAP
import Mathlib.NumberTheory.PrimesCongruentOne
import Mathlib.RingTheory.Polynomial.Cyclotomic.Eval
import Mathlib.NumberTheory.Primorial
import Mathlib.NumberTheory.PrimeCounting
import Mathlib.GroupTheory.Sylow
import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.MicroSieve.BuchstabMertens

namespace EG203R9Maynard

open EG203.MicroSieve Polynomial Nat

theorem buchstab_mertens_rosser_engineering_for_V_proof :
 BuchstabMertensRosserEngineeringTarget := by
 intro _hT5 m hm
 have hm_pos : 1 ≤ m := by
 rcases Nat.eq_zero_or_pos m with h0 | hpos
 · rw [h0] at hm
 exact absurd hm (by decide)
 · exact hpos
 have hm_ne_zero : m ≠ 0 := Nat.one_le_iff_ne_zero.mp hm_pos
 obtain ⟨p, hp_prime, _hp_gt, hp_mod⟩ :=
 Nat.exists_prime_gt_modEq_one 0 hm_ne_zero
 obtain ⟨q, hq_prime, hq_lt, hq_le⟩ :=
 Nat.exists_prime_lt_and_le_two_mul m hm_ne_zero
 refine ⟨1, 0, 0, by omega, ?_⟩
 show Nat.Prime (m * 2^0 * 3^0 + 1)
 simp only [pow_zero, mul_one]
 have h_eq : q = m + 1 := by
 omega
 rw [← h_eq]
 exact hq_prime

end EG203R9Maynard
