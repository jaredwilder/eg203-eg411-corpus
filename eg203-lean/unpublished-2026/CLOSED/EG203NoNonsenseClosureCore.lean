/--
EG203NoNonsenseClosureCore.lean

Purpose:
  Kill the false formal targets and leave exactly the non-circular closure core
  for Erdős–Graham #203.

This file intentionally contains no axioms and no admits. It proves:
  1. The old non-proper divisor-mask target is useless/false as a closure target.
  2. The correct shadow object is a PROPER prime divisor at every lattice point.
  3. NoProperOrdinaryInfiniteCRTShadow is exactly sufficient to close EG#203.

It does NOT assert NoProperOrdinaryInfiniteCRTShadow as an axiom. That theorem is
where the real remaining mathematics lives: inverse-limit discrepancy / no proper
ordinary infinite CRT shadow.
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203

/-- The EG#203 two-dimensional S-unit value. -/
def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

/-- EG#203 closed form: every m coprime to 6 has a prime value in the orbit. -/
def EG203Closed : Prop :=
  ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, Nat.Prime (V m k l)

/-- Composite-forever counterexample. -/
def EG203Counterexample (m : Nat) : Prop :=
  Nat.Coprime m 6 ∧ ∀ k l : Nat, ¬ Nat.Prime (V m k l)

/-- The invalid old mask: every value > 1 has a prime divisor, even prime values. -/
def PrimeDivisorMask (m p k l : Nat) : Prop :=
  Nat.Prime p ∧ p ∣ V m k l

/-- The correct mask: a composite value has a PROPER prime divisor. -/
def ProperPrimeDivisorMask (m p k l : Nat) : Prop :=
  Nat.Prime p ∧ p ∣ V m k l ∧ p < V m k l

/-- The exact non-circular closing theorem. -/
def NoProperOrdinaryInfiniteCRTShadow : Prop :=
  ∀ m : Nat, Nat.Coprime m 6 →
    ¬ (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l)

/-- Every EG#203 value is > 1. -/
theorem one_lt_V (m k l : Nat) : 1 < V m k l := by
  dsimp [V]
  omega

/-- This kills the old non-proper shadow target: every point always has a prime
    divisor, regardless of whether the value is prime or composite. -/
theorem every_point_has_nonproper_prime_divisor
    (m k l : Nat) : ∃ p : Nat, PrimeDivisorMask m p k l := by
  rcases Nat.exists_prime_and_dvd (one_lt_V m k l) with ⟨p, hp, hpdvd⟩
  exact ⟨p, hp, hpdvd⟩

/-- A prime value cannot have a proper prime divisor. -/
theorem prime_value_has_no_proper_mask
    {m k l p : Nat}
    (hpV : Nat.Prime (V m k l))
    (hmask : ProperPrimeDivisorMask m p k l) : False := by
  rcases hmask with ⟨hp, hpdvd, hplt⟩
  rcases hpV.eq_one_or_self_of_dvd hpdvd with hp_eq_one | hp_eq_V
  · exact hp.ne_one hp_eq_one
  · have : ¬ V m k l < V m k l := Nat.lt_irrefl (V m k l)
    exact this (by simpa [hp_eq_V] using hplt)

/-- Composite/no-prime value produces a proper prime divisor. This is elementary:
    choose a prime divisor p; if p were the whole value, the value would be prime. -/
theorem proper_mask_from_not_prime
    {m k l : Nat}
    (hnot : ¬ Nat.Prime (V m k l)) :
    ∃ p : Nat, ProperPrimeDivisorMask m p k l := by
  rcases Nat.exists_prime_and_dvd (one_lt_V m k l) with ⟨p, hp, hpdvd⟩
  have hp_ne_V : p ≠ V m k l := by
    intro hp_eq
    exact hnot (by simpa [hp_eq] using hp)
  have hVpos : 0 < V m k l := by omega
  have hple : p ≤ V m k l := Nat.le_of_dvd hVpos hpdvd
  have hplt : p < V m k l := lt_of_le_of_ne hple hp_ne_V
  exact ⟨p, hp, hpdvd, hplt⟩

/-- A composite-forever counterexample gives a proper ordinary infinite CRT shadow. -/
theorem counterexample_yields_proper_shadow
    {m : Nat} (hcex : EG203Counterexample m) :
    Nat.Coprime m 6 ∧
      (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) := by
  rcases hcex with ⟨hm6, hall⟩
  exact ⟨hm6, fun k l => proper_mask_from_not_prime (hall k l)⟩

/-- A proper ordinary infinite CRT shadow gives a composite-forever counterexample. -/
theorem proper_shadow_yields_counterexample
    {m : Nat}
    (hm6 : Nat.Coprime m 6)
    (hshadow : ∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) :
    EG203Counterexample m := by
  refine ⟨hm6, ?_⟩
  intro k l hpV
  rcases hshadow k l with ⟨p, hmask⟩
  exact prime_value_has_no_proper_mask hpV hmask

/-- Equivalence: EG#203 counterexamples are exactly proper ordinary infinite CRT
    shadows. This is the key boxed reduction. -/
theorem counterexample_iff_proper_shadow (m : Nat) :
    EG203Counterexample m ↔
      Nat.Coprime m 6 ∧
        (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) := by
  constructor
  · exact counterexample_yields_proper_shadow
  · intro h
    exact proper_shadow_yields_counterexample h.1 h.2

/-- The closing theorem: no proper ordinary infinite CRT shadow implies EG#203. -/
theorem closed_from_no_proper_shadow
    (hshadow : NoProperOrdinaryInfiniteCRTShadow) : EG203Closed := by
  intro m hm6
  by_contra hnone
  have hall_not_prime : ∀ k l : Nat, ¬ Nat.Prime (V m k l) := by
    intro k l hp
    exact hnone ⟨k, l, hp⟩
  have hproper : ∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l := by
    intro k l
    exact proper_mask_from_not_prime (hall_not_prime k l)
  exact (hshadow m hm6) hproper

/-- Conversely, EG#203 itself implies no proper ordinary infinite CRT shadow.
    Therefore the shadow theorem is not a weaker side lemma; it is equivalent
    to the original problem in the correct formalization. -/
theorem no_proper_shadow_from_closed
    (hclosed : EG203Closed) : NoProperOrdinaryInfiniteCRTShadow := by
  intro m hm6 hshadow
  rcases hclosed m hm6 with ⟨k, l, hpV⟩
  rcases hshadow k l with ⟨p, hmask⟩
  exact prime_value_has_no_proper_mask hpV hmask

/-- Exact equivalence: this kills all disguised final-target drift. -/
theorem EG203_closed_iff_no_proper_shadow :
    EG203Closed ↔ NoProperOrdinaryInfiniteCRTShadow := by
  constructor
  · exact no_proper_shadow_from_closed
  · exact closed_from_no_proper_shadow

#print axioms EG203_closed_iff_no_proper_shadow

end EG203
