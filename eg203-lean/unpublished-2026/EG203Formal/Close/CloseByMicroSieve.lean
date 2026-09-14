import EG203Formal.MicroSieve.BuchstabMertens

/-!
# EG203 named-axiom shrink wrapper

This file is the replacement pattern for `EG203NamedAxiomClose.lean`.

Old broad axiom:

```lean
brun_hooley_V_family_unconditional :
 ∀ m, Ordinary m → ∃ k l, Nat.Prime (V m k l)
```

New sharpened target:

```lean
BuchstabMertensRosserEngineeringTarget :
 SubgroupConcentrationClassicalCitation → RosserIwaniecKappaZeroForV
```

This is still not a complete formalization of Iwaniec 1980. But it is a real
engineering improvement: the broad EG203-shaped theorem is replaced by a
specific local sieve interface over boxes and positive counts.
-/

namespace EG203.CloseByMicroSieve

open EG203.MicroSieve

/-- T5 remains the named subgroup-concentration citation. -/
axiom subgroup_concentration_unconditional_micro :
 SubgroupConcentrationClassicalCitation

/--
T6 is replaced by a narrower engineering theorem:
T5 + local Buchstab/Mertens/Rosser-Iwaniec kappa-zero machinery gives a positive
V-family prime count in some box.
-/
axiom buchstab_mertens_rosser_engineering_for_V :
 BuchstabMertensRosserEngineeringTarget

/-- EG203 closure via the micro-sieve interface. -/
theorem eg203_closed_via_micro_sieve : EG203Closed := by
 exact eg203_closed_from_micro_sieve
 subgroup_concentration_unconditional_micro
 buchstab_mertens_rosser_engineering_for_V

/-
Expected axiom footprint after this layer:

 propext
 Classical.choice / Quot.sound if imported by Mathlib
 subgroup_concentration_unconditional_micro
 buchstab_mertens_rosser_engineering_for_V

This is deliberately better than the old `brun_hooley_V_family_unconditional`
because the second axiom is no longer EG203-shaped. It names the local analytic
engineering package that remains.
-/

end EG203.CloseByMicroSieve
