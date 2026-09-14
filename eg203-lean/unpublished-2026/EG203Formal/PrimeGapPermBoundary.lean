/-
 PrimeGapPermBoundary.lean — Oracle by-hand Round 47.

 Connects the R46 boundary observation `coversCount(p, p) = (p-1)!` to mathlib's
 symmetric-group cardinality `Fintype.card_perm`.

 GENERAL CLAIM: coversCount(p, p) = Fintype.card (Equiv.Perm (Fin (p-1))) = (p-1)!.

 Lean-witnessed at p ∈ {3, 5, 7} (native_decide on covers + mathlib evaluation
 of Equiv.Perm cardinality). General theorem stated as a conjecture pending a
 bijection-level proof.
-/

import EG203Formal.PrimeGapSurjectionBoundary
import Mathlib.Data.Fintype.Perm

namespace PrimeGapIE

open Finset

-- ════ The mathlib permutation cardinality, specialised to small (p-1) ════

theorem perm_card_fin_2 : Fintype.card (Equiv.Perm (Fin 2)) = 2 := by
 rw [Fintype.card_perm, Fintype.card_fin]
 decide

theorem perm_card_fin_4 : Fintype.card (Equiv.Perm (Fin 4)) = 24 := by
 rw [Fintype.card_perm, Fintype.card_fin]
 decide

theorem perm_card_fin_6 : Fintype.card (Equiv.Perm (Fin 6)) = 720 := by
 rw [Fintype.card_perm, Fintype.card_fin]
 decide

-- ════ Witnesses: coversCount(p, p) equals Equiv.Perm cardinality ════

theorem coversCount_3_3_eq_perm_card :
 coversCount 3 3 = Fintype.card (Equiv.Perm (Fin 2)) := by
 rw [perm_card_fin_2]
 native_decide

theorem coversCount_5_5_eq_perm_card :
 coversCount 5 5 = Fintype.card (Equiv.Perm (Fin 4)) := by
 rw [perm_card_fin_4]
 native_decide

theorem coversCount_7_7_eq_perm_card :
 coversCount 7 7 = Fintype.card (Equiv.Perm (Fin 6)) := by
 rw [perm_card_fin_6]
 native_decide

-- ════ Composite: admissibleCount(p, p) = p^(p-1) - perm-card at p=3,5,7 ════

theorem admissibleCount_3_3_via_perm :
 admissibleCount 3 3 = 3^2 - Fintype.card (Equiv.Perm (Fin 2)) := by
 rw [perm_card_fin_2]
 native_decide

theorem admissibleCount_5_5_via_perm :
 admissibleCount 5 5 = 5^4 - Fintype.card (Equiv.Perm (Fin 4)) := by
 rw [perm_card_fin_4]
 native_decide

theorem admissibleCount_7_7_via_perm :
 admissibleCount 7 7 = 7^6 - Fintype.card (Equiv.Perm (Fin 6)) := by
 rw [perm_card_fin_6]
 native_decide

#eval IO.println s!"R47 PERMUTATION-CARDINALITY BOUNDARY:"
#eval IO.println s!" • perm_card_fin_2 = 2, _4 = 24, _6 = 720 PROVED (via Fintype.card_perm)"
#eval IO.println s!" • coversCount(3,3) = Fintype.card (Perm Fin 2) PROVED ( = 2 = 2!)"
#eval IO.println s!" • coversCount(5,5) = Fintype.card (Perm Fin 4) PROVED ( = 24 = 4!)"
#eval IO.println s!" • coversCount(7,7) = Fintype.card (Perm Fin 6) PROVED ( = 720 = 6!)"
#eval IO.println s!" • admissibleCount(p,p) = p^(p-1) - perm-card PROVED at p=3,5,7"
#eval IO.println s!""
#eval IO.println s!"R39 + R40 + R41 + R42 + R43 + R44 + R45 + R46 + R47 = 74 theorems total"
#eval IO.println s!""
#eval IO.println s!"INTERPRETATION: at the BOUNDARY k = p, the count of COVERING tuples"
#eval IO.println s!"equals the cardinality of the symmetric group on (p-1) elements —"
#eval IO.println s!"i.e. the number of BIJECTIONS Fin(p-1) → (nonzero residues of ZMod p)."
#eval IO.println s!""
#eval IO.println s!"This connects the prime-gap-constellation count to a classical"
#eval IO.println s!"mathlib object (Equiv.Perm) via a Lean-verified bridge at p = 3, 5, 7."
#eval IO.println s!""
#eval IO.println s!"The general theorem ∀ p ≥ 2, coversCount(p, p) = Fintype.card (Perm (Fin(p-1)))"
#eval IO.println s!"requires a SumTuple ↔ Equiv bijection in Lean; left as follow-up."

end PrimeGapIE
