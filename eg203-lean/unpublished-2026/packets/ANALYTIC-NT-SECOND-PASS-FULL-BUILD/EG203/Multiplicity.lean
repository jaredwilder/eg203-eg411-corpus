
import Mathlib.Data.Int.Basic
import Mathlib.Tactic

/-!
EG203.Multiplicity

Closed-form difference-vector multiplicity objects.
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

end EG203
