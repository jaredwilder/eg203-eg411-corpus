
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic

/-!
EG203.Elementary.Basic

Core definitions and closure bridge.
-/

namespace EG203

def V (m k l : Nat) : Nat :=
  m * 2 ^ k * 3 ^ l + 1

def Ordinary (m : Nat) : Prop :=
  Nat.Coprime m 6

def TriBox (D : Nat) : Finset (Nat × Nat) :=
  ((Finset.range (D + 1)).product (Finset.range (D + 1))).filter
    (fun kl => kl.1 + kl.2 ≤ D)

def PrimePoint (m : Nat) (x : Nat × Nat) : Prop :=
  Nat.Prime (V m x.1 x.2)

def PrimeCountInBox (m D : Nat) : Nat :=
  ((TriBox D).filter (fun x => PrimePoint m x)).card

def PositivePrimeCountInBox : Prop :=
  ∀ m : Nat, Ordinary m → ∃ D : Nat, 0 < PrimeCountInBox m D

def EG203Closed : Prop :=
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

def RankTwoAffineSUnitPrimeProduction : Prop :=
  ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

theorem positive_count_gives_witness
    {m D : Nat}
    (h : 0 < PrimeCountInBox m D) :
    ∃ k l : Nat, Nat.Prime (V m k l) := by
  unfold PrimeCountInBox at h
  have hnonempty :
      (((TriBox D).filter (fun x => PrimePoint m x)).Nonempty) := by
    exact Finset.card_pos.mp h
  rcases hnonempty with ⟨x,hx⟩
  simp [PrimePoint] at hx
  exact ⟨x.1,x.2,hx.2⟩

theorem closed_from_positive_prime_count
    (h : PositivePrimeCountInBox) :
    EG203Closed := by
  intro m hm
  rcases h m hm with ⟨D,hpos⟩
  exact positive_count_gives_witness hpos

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
