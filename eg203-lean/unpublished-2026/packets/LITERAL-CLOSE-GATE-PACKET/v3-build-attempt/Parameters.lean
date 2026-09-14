
import EG203_close_gate.Elementary.Basic

/-!
EG203.Analytic.Parameters

Parameter objects for the analytic proof.
-/

namespace EG203.Analytic

open EG203

structure BoxScale where
  D : Nat
  z : Nat
  y : Nat
  hD : 0 < D
  hz : 3 ≤ z
  hy : 1 ≤ y

def MainTermLowerBound (m : Nat) (scale : BoxScale) : Prop :=
  True

def ErrorTermAcceptable (m : Nat) (scale : BoxScale) : Prop :=
  True

end EG203.Analytic
