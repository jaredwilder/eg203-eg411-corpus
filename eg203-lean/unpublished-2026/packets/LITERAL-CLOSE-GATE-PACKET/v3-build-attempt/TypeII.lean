
import EG203_close_gate.Analytic.Parameters
import EG203_close_gate.Elementary.Collision
import EG203_close_gate.Elementary.Multiplicity

/-!
EG203.Analytic.TypeII

Off-diagonal S-unit difference estimate target.
-/

namespace EG203.Analytic

open EG203

def WeightedSUnitDifferenceBound : Prop :=
  ∀ m : Nat, Ordinary m → ∀ scale : BoxScale, ErrorTermAcceptable m scale

def TypeIISUnitDifferenceEstimate : Prop :=
  WeightedSUnitDifferenceBound

end EG203.Analytic
