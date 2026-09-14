/--
EG203ProperShadowClosureTarget.lean

Purpose:
  Correct the formal target for Erdős #203 closure.

Critical correction:
  A mere prime divisor mask is useless: prime values divide themselves.
  The obstruction corresponding to "composite forever" is a PROPER prime divisor
  at every lattice point.

Status:
  This file states the exact closing theorem and the elementary reduction.
  The only non-elementary theorem is `no_proper_infinite_crt_shadow`.
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203

/-- The EG#203 value at lattice point `(k,l)`. -/
def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

/-- EG#203 closure statement. -/
def EG203Closed : Prop :=
  ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, Nat.Prime (V m k l)

/-- A genuine counterexample: all values composite, expressed as no prime values. -/
def EG203Counterexample (m : Nat) : Prop :=
  Nat.Coprime m 6 ∧ ∀ k l : Nat, ¬ Nat.Prime (V m k l)

/-- Proper prime divisor: this is the correct mask for compositeness. -/
def ProperPrimeDivisorMask (m p k l : Nat) : Prop :=
  Nat.Prime p ∧ p ∣ V m k l ∧ p < V m k l

/-- The exact shadow-rigidity theorem needed for closure.

There is no ordinary integer `m`, coprime to 6, whose entire two-dimensional
S-unit orbit has a proper prime divisor at every point.
-/
def NoProperOrdinaryInfiniteCRTShadow : Prop :=
  ∀ m : Nat, Nat.Coprime m 6 →
    ¬ (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l)

/-- Why the earlier non-proper divisor target was invalid:
    every value > 1 has a prime divisor, whether it is prime or composite. -/
theorem every_value_has_a_prime_divisor
  (m k l : Nat) : ∃ p : Nat, Nat.Prime p ∧ p ∣ V m k l := by
  have hgt : 1 < V m k l := by
    dsimp [V]
    omega
  exact Nat.exists_prime_and_dvd hgt

/-- A prime value cannot have a proper prime divisor. -/
theorem prime_value_has_no_proper_prime_divisor
  {m k l p : Nat}
  (hpv : Nat.Prime (V m k l))
  (hmask : ProperPrimeDivisorMask m p k l) : False := by
  rcases hmask with ⟨hp, hpdvd, hplt⟩
  have hpeq_or_one := hpv.eq_one_or_self_of_dvd hpdvd
  rcases hpeq_or_one with hpeq | hpeq
  · have hpne : p ≠ 1 := hp.ne_one
    exact hpne hpeq
  · have : ¬ V m k l < V m k l := Nat.lt_irrefl (V m k l)
    exact this (by simpa [hpeq] using hplt)

/-- If every point has a proper prime divisor, then no point is prime. -/
theorem proper_shadow_yields_counterexample
  {m : Nat}
  (hm6 : Nat.Coprime m 6)
  (hshadow : ∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) :
  EG203Counterexample m := by
  refine ⟨hm6, ?_⟩
  intro k l hpv
  rcases hshadow k l with ⟨p, hmask⟩
  exact prime_value_has_no_proper_prime_divisor hpv hmask

/-- The elementary final reduction: the proper-shadow theorem closes EG#203. -/
theorem closed_from_no_proper_shadow
  (hshadow : NoProperOrdinaryInfiniteCRTShadow) : EG203Closed := by
  intro m hm6
  by_contra hnone
  have hall_not_prime : ∀ k l : Nat, ¬ Nat.Prime (V m k l) := by
    intro k l hp
    exact hnone ⟨k, l, hp⟩
  -- The missing hard step is the converse direction:
  -- from `¬ Prime (V m k l)` and `1 < V m k l`, produce a proper prime divisor.
  -- This is elementary number theory, but left factored to make the non-elementary
  -- gap impossible to hide.
  have hproper : ∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l := by
    intro k l
    have hgt : 1 < V m k l := by
      dsimp [V]
      omega
    rcases Nat.exists_prime_and_dvd hgt with ⟨p, hp, hpdvd⟩
    have hp_ne_v : p ≠ V m k l := by
      intro hpeq
      exact hall_not_prime k l (by simpa [hpeq] using hp)
    have hple : p ≤ V m k l := Nat.le_of_dvd (by omega : 0 < V m k l) hpdvd
    have hplt : p < V m k l := lt_of_le_of_ne hple hp_ne_v
    exact ⟨p, hp, hpdvd, hplt⟩
  exact (hshadow m hm6) hproper

/-- The one theorem that would finish the proof.

No `axiom` is used in this file. This theorem is intentionally left as the
named target for the next proof file, not smuggled as an assumption.
-/
-- theorem no_proper_infinite_crt_shadow : NoProperOrdinaryInfiniteCRTShadow := by
--   -- TODO: inverse-limit discrepancy / no ordinary infinite CRT shadow.
--   -- This is the only remaining mathematical content.
--   admit

end EG203
