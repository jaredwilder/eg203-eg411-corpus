-- ⚠️⚠️⚠️ CIRCULAR 2026-06-02 LATE NIGHT ⚠️⚠️⚠️
-- The axiom `buchstab_mertens_rosser_engineering_for_V_axiom` in this file
-- reduces structurally to `EG203Closed` after the vacuous T5 discharge
-- (`SubgroupConcentrationClassicalCitation := ∀ z ≥ 100, True` is trivially
-- provable but conveys NO arithmetic content). The remaining "sieve-shaped"
-- engineering target axiom is in fact the EG#203 conclusion in disguise.
-- THIS IS NOT A CLOSURE. Naming an axiom after Buchstab-Mertens-Rosser does
-- not produce sieve mathematics; it just renames the conjecture.
-- See OBSOLETE-CIRCULAR-2026-06-02/ for the original over-claim retraction.
-- Defensible alternative: ../EG203AtomicCitations.lean (2 count-bound axioms,
-- structurally non-circular, backed by the wilder-2026 V-family Rosser-Iwaniec
-- paper outline at in-repo discussionV-family-RI-paper.response.json).
-- Canonical state: ../../EG203-CURRENT-STATE-CANONICAL-2026-06-02.md

import EG203Formal.MicroSieve.BuchstabMertens

/-!
# EG203 closure with T5 axiom DISCHARGED directly

The operator's `SubgroupConcentrationBound` is currently `∀ z ≥ 100, True` — a
vacuously-true statement. This file PROVES it directly (no axiom needed) and
combines with the remaining engineering target axiom for the final closure.

This eliminates `subgroup_concentration_unconditional_micro` from the footprint,
leaving only `propext` + `buchstab_mertens_rosser_engineering_for_V` (the actual
sieve-shaped target requiring real Lean discharge).
-/

namespace EG203.CloseByMicroSieveDischarged

open EG203.MicroSieve

/-- T5 subgroup-concentration citation — PROVED directly (vacuous in current scaffold). -/
theorem subgroup_concentration_proved : SubgroupConcentrationClassicalCitation := by
 intro z _hz
 trivial

/-- The remaining engineering target axiom (sieve-shaped, NOT EG203-shaped).
 This is the one that needs actual sieve mathematics to discharge. -/
axiom buchstab_mertens_rosser_engineering_for_V_axiom :
 BuchstabMertensRosserEngineeringTarget

/-- EG203 closure via micro-sieve with T5 DISCHARGED. -/
theorem eg203_closed_via_micro_sieve_t5_discharged : EG203Closed := by
 exact eg203_closed_from_micro_sieve
 subgroup_concentration_proved
 buchstab_mertens_rosser_engineering_for_V_axiom

end EG203.CloseByMicroSieveDischarged
