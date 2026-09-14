
import EG203.Elementary.Basic
import EG203.Elementary.Algebra
import Mathlib.Data.ZMod.Basic
import Mathlib.Algebra.Group.Defs
import Mathlib.Algebra.GroupPower.Basic
import Mathlib.Tactic

/-!
EG203.Elementary.Collision

Collision and relation-vector objects.
-/

namespace EG203

def Orbit {G : Type} [CommGroup G] (a b : G) (k l : Nat) : G :=
  a ^ k * b ^ l

theorem collision_iff_quotient_relation
    {G : Type} [CommGroup G] {a b : G} {k l k' l' : Nat} :
    Orbit a b k l = Orbit a b k' l'
      ↔ Orbit a b k l * (Orbit a b k' l')⁻¹ = 1 := by
  constructor
  · intro h
    rw [h]
    simp [Orbit]
  · intro h
    have hmul := congrArg (fun x => x * Orbit a b k' l') h
    simpa [mul_assoc, Orbit] using hmul

def ClearedRelationMod (q : Nat) (a b : Int) : Prop :=
  ((2 : ZMod q) ^ (Int.toNat (max a 0)) *
   (3 : ZMod q) ^ (Int.toNat (max b 0)))
  =
  ((2 : ZMod q) ^ (Int.toNat (max (-a) 0)) *
   (3 : ZMod q) ^ (Int.toNat (max (-b) 0)))

def DifferenceBox (D : Int) (a b : Int) : Prop :=
  -D ≤ a ∧ a ≤ D ∧ -D ≤ b ∧ b ≤ D

def NoNonzeroRelationInBox (q : Nat) (D : Int) : Prop :=
  ∀ a b : Int, DifferenceBox D a b → (a ≠ 0 ∨ b ≠ 0) →
    ¬ ClearedRelationMod q a b

def CollisionMod (q : Nat) (x y : Nat × Nat) : Prop :=
  ((SUnit x.1 x.2 : ZMod q) = (SUnit y.1 y.2 : ZMod q))

def CollisionCount (D q : Nat) : Nat :=
  ((TriBox D).product (TriBox D)).filter
    (fun xy => CollisionMod q xy.1 xy.2)
    |>.card

def NoShortRelationImpliesNoOffDiagonalCollision : Prop :=
  ∀ q D x y,
    NoNonzeroRelationInBox q (Int.ofNat D) →
    x ∈ TriBox D →
    y ∈ TriBox D →
    CollisionMod q x y →
    x = y

end EG203
