import Mathlib.Data.Finset.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.Algebra.Group.Defs
-- Mathlib.Algebra.GroupPower.Basic deprecated/moved in recent Mathlib
import Mathlib.Algebra.Group.Basic
import Mathlib.Tactic
import EG203_close_gate.Elementary.Basic  -- for TriBox

/-!
EG203.Collision

Finite collision objects and exact relation-vector identity target.
This file avoids analytic claims; it supplies objects for the analytic theorem.
-/

namespace EG203

def SUnit (k l : Nat) : Nat :=
  2 ^ k * 3 ^ l

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

instance (q : Nat) (x y : Nat × Nat) : Decidable (CollisionMod q x y) := by
  unfold CollisionMod
  exact decEq _ _

def CollisionCount (D q : Nat) : Nat :=
  ((TriBox D).product (TriBox D)).filter
    (fun (xy : (Nat × Nat) × (Nat × Nat)) =>
      decide (CollisionMod q xy.1 xy.2))
    |>.card

/--
Analytic/combinatorial target, not yet proved here:
if no nonzero relation occurs in the difference box, collisions are diagonal.
Claude should either prove this or keep it as a local lemma needed by the
analytic theorem.
-/
def NoShortRelationImpliesNoOffDiagonalCollision : Prop :=
  ∀ q D x y,
    NoNonzeroRelationInBox q (Int.ofNat D) →
    x ∈ TriBox D →
    y ∈ TriBox D →
    CollisionMod q x y →
    x = y

end EG203
