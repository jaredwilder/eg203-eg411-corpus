import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Int.Basic
import Mathlib.Tactic

/-!
EG203.Algebra

Algebraic reductions needed by the analytic theorem.

This file should compile now. It contains no sorry/axiom/admit.
-/

namespace EG203

def Affine (m A : Nat) : Nat :=
  m * A + 1

theorem coprime_of_prime_dvd_affine
    {p m A : Nat}
    (hp : Nat.Prime p)
    (hdiv : p ∣ Affine m A) :
    Nat.Coprime p m := by
  unfold Affine at hdiv
  rw [Nat.Prime.coprime_iff_not_dvd hp]
  intro hpdvdm
  have hp_pos : 0 < p := hp.pos
  have hp_gt_one : 1 < p := hp.one_lt
  -- p ∣ m * A
  have hpdvdmA : p ∣ m * A := Dvd.dvd.mul_right hpdvdm A
  -- (m * A) % p = 0
  have hmAmod : (m * A) % p = 0 := Nat.mod_eq_zero_of_dvd hpdvdmA
  -- (m * A + 1) % p = 0  (from hdiv)
  have hmA1mod : (m * A + 1) % p = 0 := Nat.mod_eq_zero_of_dvd hdiv
  -- compute (m * A + 1) % p using Nat.add_mod
  have : (m * A + 1) % p = ((m * A) % p + 1 % p) % p := by
    rw [Nat.add_mod]
  rw [hmAmod, Nat.mod_eq_of_lt hp_gt_one] at this
  -- this : (m * A + 1) % p = (0 + 1) % p
  rw [hmA1mod] at this
  -- this : 0 = (0 + 1) % p
  simp at this
  -- 0 = 1 % p, but 1 % p = 1 since p > 1
  -- this : p = 1, contradicts hp_gt_one : 1 < p
  omega

theorem mod_eq_pred_of_dvd_affine
    {p m A : Nat}
    (hp_pos : 0 < p)
    (hdiv : p ∣ Affine m A) :
    (m * A) % p = p - 1 := by
  unfold Affine at hdiv
  have hmod : (m * A + 1) % p = 0 := Nat.mod_eq_zero_of_dvd hdiv
  have hcalc : (m * A + 1) % p = ((m * A) % p + 1) % p := by
    rw [Nat.add_mod]; simp
  rw [hcalc] at hmod
  have hlt : (m * A) % p < p := Nat.mod_lt _ hp_pos
  -- Let q = (m * A) % p. We have q < p and (q + 1) % p = 0.
  -- This forces q + 1 = p (since q + 1 ≤ p and (q+1) % p = 0 means p | q+1).
  set q := (m * A) % p with hq
  -- (q + 1) % p = 0 means p ∣ (q + 1)
  have hpdvd : p ∣ (q + 1) := Nat.dvd_of_mod_eq_zero hmod
  -- q < p, so q + 1 ≤ p
  have hle : q + 1 ≤ p := hlt
  -- p ∣ (q+1) and 0 < q+1 ≤ p means q+1 = p
  have hqp : q + 1 = p := by
    rcases hpdvd with ⟨t, ht⟩
    have : 0 < q + 1 := Nat.succ_pos _
    -- q + 1 = p * t. Since 0 < q + 1 ≤ p, t = 1.
    have ht1 : t = 1 := by
      have h0 : 0 < p * t := ht ▸ this
      have ht_pos : 0 < t := Nat.pos_of_mul_pos_left h0
      have : p * t ≤ p := ht ▸ hle
      have : p * t ≤ p * 1 := by simpa using this
      have := Nat.le_of_mul_le_mul_left this hp_pos
      omega
    rw [ht, ht1, Nat.mul_one]
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
