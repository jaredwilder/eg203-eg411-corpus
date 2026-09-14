import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic

/-!
EG203.Basic

Core statement and closure bridge.

This file should compile now. It contains no sorry/axiom/admit.
-/

namespace EG203

def V (m k l : Nat) : Nat :=
  m * 2 ^ k * 3 ^ l + 1

def Ordinary (m : Nat) : Prop :=
  Nat.Coprime m 6

def TriBox (D : Nat) : Finset (Nat × Nat) :=
  ((Finset.range (D+1)).product (Finset.range (D+1))).filter
    (fun kl => kl.1 + kl.2 ≤ D)

def EG203Closed : Prop :=
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

def PrimePoint (m : Nat) (x : Nat × Nat) : Prop :=
  Nat.Prime (V m x.1 x.2)

def PositivePrimeCountInBox : Prop :=
  ∀ m : Nat, Ordinary m →
    ∃ D x, x ∈ TriBox D ∧ PrimePoint m x

theorem closed_from_positive_prime_count
    (h : PositivePrimeCountInBox) :
    EG203Closed := by
  intro m hm
  rcases h m hm with ⟨D,x,hx,hp⟩
  exact ⟨x.1,x.2,hp⟩

def RankTwoAffineSUnitPrimeProduction : Prop :=
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

theorem exact_equivalence :
    EG203Closed ↔ RankTwoAffineSUnitPrimeProduction := by
  constructor <;> intro h <;> exact h

theorem mem_tribox_sum_le
    {D k l : Nat}
    (h : (k,l) ∈ TriBox D) :
    k + l ≤ D := by
  unfold TriBox at h
  simp at h
  exact h.2

end EG203
