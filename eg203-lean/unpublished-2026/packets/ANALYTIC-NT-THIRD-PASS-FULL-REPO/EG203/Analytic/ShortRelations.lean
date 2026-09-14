
import EG203.Analytic.Parameters
import EG203.Elementary.Collision
import EG203.Elementary.Multiplicity

/-!
EG203.Analytic.ShortRelations
-/

namespace EG203.Analytic

open EG203

def ShortRelationLatticeControl : Prop :=
  ∀ m : Nat, Ordinary m → ∀ scale : BoxScale, ErrorTermAcceptable m scale

end EG203.Analytic
