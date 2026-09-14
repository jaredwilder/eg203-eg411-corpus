
import EG203.Analytic.Parameters

/-!
EG203.Analytic.Vaughan

Prime detecting decomposition target.
-/

namespace EG203.Analytic

open EG203

def VonMangoldtBoxSumControlled : Prop :=
  ∀ m : Nat, Ordinary m → ∃ scale : BoxScale, MainTermLowerBound m scale

def VaughanHeathBrownDecomposition : Prop :=
  VonMangoldtBoxSumControlled

end EG203.Analytic
