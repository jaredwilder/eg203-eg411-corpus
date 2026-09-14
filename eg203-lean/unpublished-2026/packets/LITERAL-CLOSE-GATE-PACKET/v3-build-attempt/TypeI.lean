
import EG203_close_gate.Analytic.Parameters
import EG203_close_gate.Elementary.Algebra

/-!
EG203.Analytic.TypeI
-/

namespace EG203.Analytic

open EG203

def TypeIDistributionEstimate : Prop :=
  ∀ m : Nat, Ordinary m → ∀ scale : BoxScale, ErrorTermAcceptable m scale

end EG203.Analytic
