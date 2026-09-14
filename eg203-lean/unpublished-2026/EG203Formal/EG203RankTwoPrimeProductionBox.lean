import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
EG203RankTwoPrimeProductionBox

Lean-first proof box for the only remaining unconditional EG203 target.

No placeholder proof commands are used.
This file does not prove EG203; it freezes the exact theorem and the
acceptable bridge shapes so that sufficient-but-false routes cannot be
renamed as closure.
-/

namespace EG203RankTwoPrimeProductionBox

def V (m k l : Nat) : Nat :=
 m * 2 ^ k * 3 ^ l + 1

def Ordinary (m : Nat) : Prop :=
 Nat.Coprime m 6

def RankTwoAffineSUnitPrimeProduction : Prop :=
 forall m : Nat, Ordinary m -> exists k l : Nat, Nat.Prime (V m k l)

def EG203Closed : Prop :=
 RankTwoAffineSUnitPrimeProduction

theorem exact_equivalence :
 EG203Closed <-> RankTwoAffineSUnitPrimeProduction := by
 rfl

def GenuineCloseTheorem (T : Prop) : Prop :=
 T -> RankTwoAffineSUnitPrimeProduction

theorem closed_from_genuine_close_theorem
 {T : Prop}
 (hT : T)
 (hClose : GenuineCloseTheorem T) :
 EG203Closed := by
 exact hClose hT

/--
A finite or analytic route only counts as a close when it provides a prime
witness for every ordinary m. A box may depend on m; a fixed D route is a
strict special case and is already known to be the wrong instrument.
-/
def MDependentBoxPrimeProduction : Prop :=
 forall m : Nat, Ordinary m ->
 exists D k l : Nat, k + l <= D /\ Nat.Prime (V m k l)

theorem closed_from_m_dependent_box_prime_production
 (h : MDependentBoxPrimeProduction) :
 EG203Closed := by
 intro m hm
 match h m hm with
 | Exists.intro _ restD =>
 match restD with
 | Exists.intro k restK =>
 match restK with
 | Exists.intro l restL =>
 exact Exists.intro k (Exists.intro l restL.right)

/--
The remaining analytic lane after the finite-source/density/source-predicate
routes were killed: a parity-breaking lower bound for prime values on the
rank-two affine S-unit orbit.
-/
def TypeICongruenceAlgebra : Prop := True
def TypeIICollisionControl : Prop := True
def ParityBreakingLowerBound : Prop :=
 TypeICongruenceAlgebra ->
 TypeIICollisionControl ->
 MDependentBoxPrimeProduction

theorem closed_from_typeI_typeII_parity
 (hI : TypeICongruenceAlgebra)
 (hII : TypeIICollisionControl)
 (hParity : ParityBreakingLowerBound) :
 EG203Closed := by
 exact closed_from_m_dependent_box_prime_production (hParity hI hII)

/--
Finite source-pinned no-cover, crude danger-sum inequalities, or density
tail bounds are not closure claims unless this bridge is supplied.
-/
def RouteNeedsPrimeProductionBridge (Route : Prop) : Prop :=
 Route -> MDependentBoxPrimeProduction

theorem route_closes_only_with_prime_production_bridge
 {Route : Prop}
 (hRoute : Route)
 (hBridge : RouteNeedsPrimeProductionBridge Route) :
 EG203Closed := by
 exact closed_from_m_dependent_box_prime_production (hBridge hRoute)

end EG203RankTwoPrimeProductionBox
