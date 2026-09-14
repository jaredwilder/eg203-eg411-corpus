/--
EG203ClosureLean.lean

Erdos-Graham #203 closure kernel receipt.

This file is intentionally small and sharp. It formalizes the exact closed box:
EG203Closed is equivalent to NoProperOrdinaryInfiniteCRTShadow.

No axioms. No sorry. No admit.

The final kernel-close task is therefore not allowed to drift: prove
NoProperOrdinaryInfiniteCRTShadow, and EG203Closed follows immediately by
`closed_from_no_proper_shadow`. Conversely, any proof of EG203Closed gives
NoProperOrdinaryInfiniteCRTShadow.
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203

/-- The two-dimensional S-unit translate appearing in Erdős-Graham #203. -/
def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/-- EG#203 closed form: every ordinary `m` coprime to `6` has a prime translate. -/
def EG203Closed : Prop :=
 ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, Nat.Prime (V m k l)

/-- A composite-forever counterexample candidate. -/
def EG203Counterexample (m : Nat) : Prop :=
 Nat.Coprime m 6 ∧ ∀ k l : Nat, ¬ Nat.Prime (V m k l)

/-- The invalid non-proper mask: every value > 1 has one, including prime values. -/
def PrimeDivisorMask (m p k l : Nat) : Prop :=
 Nat.Prime p ∧ p ∣ V m k l

/-- The correct mask: a composite value has a proper prime divisor. -/
def ProperPrimeDivisorMask (m p k l : Nat) : Prop :=
 Nat.Prime p ∧ p ∣ V m k l ∧ p < V m k l

/-- The boxed final shadow-rigidity theorem. -/
def NoProperOrdinaryInfiniteCRTShadow : Prop :=
 ∀ m : Nat, Nat.Coprime m 6 →
 ¬ (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l)

/-- Every EG#203 translate is larger than one. -/
theorem one_lt_V (m k l : Nat) : 1 < V m k l := by
 dsimp [V]
 omega

/-- This kills the old non-proper shadow target: it is always inhabited. -/
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
 · exact (Nat.lt_irrefl (V m k l)) (by simpa [hp_eq_V] using hplt)

/-- If a translate is not prime, it has a proper prime divisor. -/
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

/-- A composite-forever counterexample yields a proper ordinary infinite CRT shadow. -/
theorem counterexample_yields_proper_shadow
 {m : Nat} (hcex : EG203Counterexample m) :
 Nat.Coprime m 6 ∧
 (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) := by
 rcases hcex with ⟨hm6, hall⟩
 exact ⟨hm6, fun k l => proper_mask_from_not_prime (hall k l)⟩

/-- A proper ordinary infinite CRT shadow yields a composite-forever counterexample. -/
theorem proper_shadow_yields_counterexample
 {m : Nat}
 (hm6 : Nat.Coprime m 6)
 (hshadow : ∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) :
 EG203Counterexample m := by
 refine ⟨hm6, ?_⟩
 intro k l hpV
 rcases hshadow k l with ⟨p, hmask⟩
 exact prime_value_has_no_proper_mask hpV hmask

/-- Counterexamples are exactly proper ordinary infinite CRT shadows. -/
theorem counterexample_iff_proper_shadow (m : Nat) :
 EG203Counterexample m ↔
 Nat.Coprime m 6 ∧
 (∀ k l : Nat, ∃ p : Nat, ProperPrimeDivisorMask m p k l) := by
 constructor
 · exact counterexample_yields_proper_shadow
 · intro h
 exact proper_shadow_yields_counterexample h.1 h.2

/-- Closing direction: shadow-rigidity implies EG#203. -/
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

/-- Reverse direction: EG#203 implies shadow-rigidity. -/
theorem no_proper_shadow_from_closed
 (hclosed : EG203Closed) : NoProperOrdinaryInfiniteCRTShadow := by
 intro m hm6 hshadow
 rcases hclosed m hm6 with ⟨k, l, hpV⟩
 rcases hshadow k l with ⟨p, hmask⟩
 exact prime_value_has_no_proper_mask hpV hmask

/-- Exact closure box. This is the Lean object to preserve. -/
theorem EG203_closed_iff_no_proper_shadow :
 EG203Closed ↔ NoProperOrdinaryInfiniteCRTShadow := by
 constructor
 · exact no_proper_shadow_from_closed
 · exact closed_from_no_proper_shadow

/-- If the shadow-rigidity theorem is imported/proved, this is the final line. -/
theorem EG203_closed_from_shadow_rigidity
 (shadowRigidity : NoProperOrdinaryInfiniteCRTShadow) : EG203Closed :=
 closed_from_no_proper_shadow shadowRigidity

#print axioms EG203_closed_iff_no_proper_shadow
#print axioms EG203_closed_from_shadow_rigidity

end EG203
