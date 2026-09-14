import Mathlib.Data.Int.Basic
import Mathlib.Tactic

/-!
EG203.Multiplicity

Closed-form multiplicity of a difference vector in a triangular box.
This file contains the algebraic shape. The full bijective counting theorem
is a useful optional Mathlib task.
-/

namespace EG203

def ShiftLowerA (a : Int) : Int := max 0 (-a)
def ShiftLowerB (b : Int) : Int := max 0 (-b)
def ShiftUpper (D a b : Int) : Int := min D (D - a - b)

def TriangleCountInt (S : Int) : Int :=
  if 0 ≤ S then (S + 1) * (S + 2) / 2 else 0

def DifferenceMultiplicityFormula (D a b : Int) : Int :=
  TriangleCountInt (ShiftUpper D a b - ShiftLowerA a - ShiftLowerB b)

theorem lowerA_nonneg (a : Int) : 0 ≤ ShiftLowerA a := by
  unfold ShiftLowerA
  exact le_max_left 0 (-a)

theorem lowerB_nonneg (b : Int) : 0 ≤ ShiftLowerB b := by
  unfold ShiftLowerB
  exact le_max_left 0 (-b)

theorem upper_le_D (D a b : Int) : ShiftUpper D a b ≤ D := by
  unfold ShiftUpper
  exact min_le_left D (D - a - b)

theorem upper_le_shifted_sum (D a b : Int) :
    ShiftUpper D a b ≤ D - a - b := by
  unfold ShiftUpper
  exact min_le_right D (D - a - b)

theorem shift_lowerA_makes_nonnegative
    (u a : Int)
    (hu : ShiftLowerA a ≤ u) :
    0 ≤ u + a := by
  unfold ShiftLowerA at hu
  have h : -a ≤ u := le_trans (le_max_right 0 (-a)) hu
  omega

theorem shift_lowerB_makes_nonnegative
    (v b : Int)
    (hv : ShiftLowerB b ≤ v) :
    0 ≤ v + b := by
  unfold ShiftLowerB at hv
  have h : -b ≤ v := le_trans (le_max_right 0 (-b)) hv
  omega

end EG203
