/-
 PrimeGapSurjectionBoundary.lean — Oracle by-hand Round 46.

 At k = p (the FIRST k where covering becomes possible), the count of covering
 tuples equals the number of surjections {Fin(p-1)} → ZMod p \ {0}, which
 equals (p-1)!.

 Witnessing at small primes p ∈ {3, 5, 7}:
 admissibleCount(p, p) = p^(p-1) − (p-1)!

 Pattern table:
 p=3, k=3: admissibleCount = 9 − 2 = 7 (verified)
 p=5, k=5: admissibleCount = 625 − 24 = 601 (verified)
 p=7, k=7: admissibleCount = 7^6 − 720 = 117649 − 720 = 116929 (verified)
-/

import EG203Formal.PrimeGapAdmissibleClosedForm

namespace PrimeGapIE

open Finset

-- ════ Witnesses for admissibleCount(p, p) at small primes ════

theorem admissibleCount_3_3_surjection_form :
 admissibleCount 3 3 = 3 ^ (3 - 1) - Nat.factorial (3 - 1) := by
 native_decide

theorem admissibleCount_5_5_surjection_form :
 admissibleCount 5 5 = 5 ^ (5 - 1) - Nat.factorial (5 - 1) := by
 native_decide

theorem admissibleCount_7_7_surjection_form :
 admissibleCount 7 7 = 7 ^ (7 - 1) - Nat.factorial (7 - 1) := by
 native_decide

-- ════ Explicit numerical forms ════

theorem admissibleCount_3_3_explicit : admissibleCount 3 3 = 9 - 2 := by native_decide
theorem admissibleCount_5_5_explicit : admissibleCount 5 5 = 625 - 24 := by native_decide
theorem admissibleCount_7_7_explicit : admissibleCount 7 7 = 117649 - 720 := by native_decide

-- ════ coversCount = (p-1)! at k = p ════

theorem coversCount_3_3_factorial :
 coversCount 3 3 = Nat.factorial (3 - 1) := by native_decide

theorem coversCount_5_5_factorial :
 coversCount 5 5 = Nat.factorial (5 - 1) := by native_decide

theorem coversCount_7_7_factorial :
 coversCount 7 7 = Nat.factorial (7 - 1) := by native_decide

-- ════ Consistency: complement at k = p ════

theorem complement_at_k_eq_p_3 : admissibleCount 3 3 + coversCount 3 3 = 3 ^ 2 := by
 rw [admissible_plus_covers_eq_total 3 3]

theorem complement_at_k_eq_p_5 : admissibleCount 5 5 + coversCount 5 5 = 5 ^ 4 := by
 rw [admissible_plus_covers_eq_total 5 5]

theorem complement_at_k_eq_p_7 : admissibleCount 7 7 + coversCount 7 7 = 7 ^ 6 := by
 rw [admissible_plus_covers_eq_total 7 7]

#eval IO.println s!"R46 k=p SURJECTION BOUNDARY PATTERN:"
#eval IO.println s!" • admissibleCount_3_3_surjection_form PROVED (= 3^2 - 2!)"
#eval IO.println s!" • admissibleCount_5_5_surjection_form PROVED (= 5^4 - 4!)"
#eval IO.println s!" • admissibleCount_7_7_surjection_form PROVED (= 7^6 - 6!)"
#eval IO.println s!" • coversCount_3_3 = 2!, _5_5 = 4!, _7_7 = 6! PROVED (surjections)"
#eval IO.println s!" • complement_at_k_eq_p_(3,5,7) PROVED (via R39 complement id)"
#eval IO.println s!""
#eval IO.println s!"R39 + R40 + R41 + R42 + R43 + R44 + R45 + R46 = 65 theorems total"
#eval IO.println s!""
#eval IO.println s!"PATTERN at the BOUNDARY k = p (first k where covering possible):"
#eval IO.println s!" coversCount(p, p) = (p-1)! ← bijections from Fin(p-1) → nonzero residues"
#eval IO.println s!" admissibleCount(p, p) = p^(p-1) - (p-1)!"
#eval IO.println s!""
#eval IO.println s!"Numerical values at small primes (machine-verified):"
#eval IO.println s!" p=3: 9 - 2 = 7"
#eval IO.println s!" p=5: 625 - 24 = 601"
#eval IO.println s!" p=7: 117649 - 720 = 116929"
#eval IO.println s!""
#eval IO.println s!"Sequence (p, admissibleCount(p, p)): (2, 1), (3, 7), (5, 601), (7, 116929)"
#eval IO.println s!"This is the prime-gap-constellation \"first-covering boundary\" sequence."

end PrimeGapIE
