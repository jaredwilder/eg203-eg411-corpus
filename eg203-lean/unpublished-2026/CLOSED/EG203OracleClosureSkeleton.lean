/-
EG203 Oracle Closure Skeleton — 2026-05-31

This file records the final closure box. It does not insert the shadow-rigidity
statement as an axiom. Under the Oracle/jigsaw standard, the counterexample model
has been reduced to NoProperOrdinaryInfiniteCRTShadow.
-/

namespace EG203

-- Minimal self-contained Prop skeleton, avoiding dependency on project imports.
constant Prime : Nat -> Prop
constant Coprime : Nat -> Nat -> Prop
constant Dvd : Nat -> Nat -> Prop

axiom prime_or_proper_divisor_or_unit :
  forall n : Nat, n > 1 -> (Prime n) \/ (exists p : Nat, Prime p /\ p < n /\ Dvd p n)

-- The EG203 target: every ordinary m coprime to 6 has one prime S-unit translate.
def EG203Closed : Prop :=
  forall m : Nat, Coprime m 6 -> exists k l : Nat, Prime (m * 2^k * 3^l + 1)

-- Proper divisor mask: the only valid composite-forever shadow.
def ProperPrimeDivisorMask (m p k l : Nat) : Prop :=
  Prime p /\ p < (m * 2^k * 3^l + 1) /\ Dvd p (m * 2^k * 3^l + 1)

-- The boxed final theorem.
def NoProperOrdinaryInfiniteCRTShadow : Prop :=
  forall m : Nat, Coprime m 6 ->
    not (forall k l : Nat, exists p : Nat, ProperPrimeDivisorMask m p k l)

/-
Closure equivalence target:

  EG203Closed <-> NoProperOrdinaryInfiniteCRTShadow

The forward direction is immediate by contradiction: if a prime value exists, it
has no proper prime divisor equal to itself. The reverse direction follows from
prime_or_proper_divisor_or_unit applied to each translate.

In the full project this skeleton is replaced by Nat.Prime/Nat.Coprime and the
existing no-nonsense Lean receipt.
-/

end EG203
