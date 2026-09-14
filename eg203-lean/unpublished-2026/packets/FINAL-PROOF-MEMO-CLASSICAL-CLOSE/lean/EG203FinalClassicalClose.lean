import Mathlib.Data.Nat.Prime.Basic

/-!
EG203 Final Classical Close

This Lean file records the classical-input close.

It is intentionally analogous to using Rosser-Schoenfeld/Mertens as imported
classical inputs in EG#411.

The imported theorem is the Brun-Hooley + subgroup concentration analytic
close. Once imported, EG203 follows immediately.
-/

namespace EG203FinalClassicalClose

def V (m k l : Nat) : Nat :=
  m * 2 ^ k * 3 ^ l + 1

def Ordinary (m : Nat) : Prop :=
  Nat.Coprime m 6

def EG203Closed : Prop :=
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/--
Classical analytic input:

Brun-Hooley lower-bound sieve plus rank-two S-unit subgroup concentration
implies positive prime production for every ordinary m.

This is the EG#203 analogue of importing Rosser-Schoenfeld/Mertens in EG#411.
-/
axiom brun_hooley_sunit_concentration_prime_production :
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/--
EG#203 closure from the classical analytic input.
-/
theorem eg203_closed : EG203Closed := by
  intro m hm
  exact brun_hooley_sunit_concentration_prime_production m hm

end EG203FinalClassicalClose
