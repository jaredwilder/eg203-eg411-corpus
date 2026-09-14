
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Int.Basic
import Mathlib.Tactic

/-!
EG203.Elementary.Algebra

Elementary algebraic reductions.
-/

namespace EG203

def Affine (m A : Nat) : Nat :=
  m * A + 1

def SUnit (k l : Nat) : Nat :=
  2 ^ k * 3 ^ l

theorem coprime_of_prime_dvd_affine
    {p m A : Nat}
    (hp : Nat.Prime p)
    (hdiv : p ∣ Affine m A) :
    Nat.Coprime p m := by
  unfold Affine at hdiv
  by_contra hnot
  have hpdvdm : p ∣ m := hp.dvd_of_not_coprime hnot
  have hpdvdmA : p ∣ m * A := Nat.dvd_mul_right_of_dvd hpdvdm A
  have hpdvdone : p ∣ 1 := by
    have hsub : p ∣ (m * A + 1) - (m * A) :=
      Nat.dvd_sub hdiv hpdvdmA (Nat.le_add_right (m*A) 1)
    simpa using hsub
  exact hp.not_dvd_one hpdvdone

theorem mod_eq_pred_of_dvd_affine
    {p m A : Nat}
    (hp_pos : 0 < p)
    (hdiv : p ∣ Affine m A) :
    (m * A) % p = p - 1 := by
  unfold Affine at hdiv
  have hmod : (m * A + 1) % p = 0 := Nat.mod_eq_zero_of_dvd hdiv
  have hcalc : (m * A + 1) % p = ((m * A) % p + 1) % p := by
    rw [Nat.add_mod]
    simp
  rw [hcalc] at hmod
  have hlt : (m * A) % p < p := Nat.mod_lt _ hp_pos
  omega

theorem common_divisor_forces_difference_int
    {d m A B : Int}
    (hA : d ∣ m * A + 1)
    (hB : d ∣ m * B + 1)
    (bezout : ∃ u v : Int, u * m + v * d = 1) :
    d ∣ A - B := by
  rcases hA with ⟨x, hx⟩
  rcases hB with ⟨y, hy⟩
  rcases bezout with ⟨u, v, huv⟩
  have hdiff : d ∣ m * (A - B) := by
    refine ⟨x - y, ?_⟩
    calc
      m * (A - B) = (m * A + 1) - (m * B + 1) := by ring
      _ = d * x - d * y := by rw [hx, hy]
      _ = d * (x - y) := by ring
  rcases hdiff with ⟨t, ht⟩
  refine ⟨u * t + v * (A - B), ?_⟩
  calc
    A - B = 1 * (A - B) := by ring
    _ = (u * m + v * d) * (A - B) := by rw [huv]
    _ = u * (m * (A - B)) + v * d * (A - B) := by ring
    _ = u * (d * t) + v * d * (A - B) := by rw [ht]
    _ = d * (u * t + v * (A - B)) := by ring

end EG203
