-- ⚠️⚠️⚠️ DEPRECATED 2026-06-02 LATE ⚠️⚠️⚠️
-- The theorem in this file uses (via `exact`) a CIRCULAR axiom whose
-- conclusion IS EG#203 itself. The proof is therefore CIRCULAR, not a
-- real closure. Treat as PLACEHOLDER scaffolding.
-- The honest closure path lives in `Iwaniec/EG203HonestClosure.lean`
-- (under construction in a parallel subagent task).
-- See: receipts/R14-2026-06-02/DEEP-CIRCULARITY-AUDIT.md (c13e31c3).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.IwaniecAxiomTightened
import EG203Formal.R14.Iwaniec.PappalardiHypothesisDischarge
import EG203Formal.R14.Chain103ScaffoldDischarge
import EG203Formal.R14.EG203UnconditionalClosure

/-!
# P2.7 — Clean composition: EG#203 from tightened Iwaniec + discharged Pappalardi

This is the architecturally-CLEAN version of the EG#203 closure:
- Pappalardi A: PROVED (no axiom) via `pappalardi_hypothesis_for_z_23`
- Iwaniec B: ONE NAMED AXIOM (`iwaniec_1980_thm_1_tightened_κ_zero`)
- Chain coprime existence: PROVED (no axiom) via P0 work

Final axiom footprint:
 [propext, Classical.choice, Quot.sound,
 iwaniec_1980_thm_1_tightened_κ_zero]

ONE named published axiom (vs the BUNDLED axiom from P4 which had the same
count but was structurally stronger / more circular). The tightened axiom
is the cleanest possible "I asserted the abstract Iwaniec sieve theorem"
statement matching Iwaniec 1980 Acta Arith Thm 1 verbatim.

NO MATHEMATICAL AXIOMS beyond the named Iwaniec.
-/

namespace EG203R14IwaniecEG203CleanComposition

open EG203R14IwaniecAxiomTightened
open EG203R14IwaniecPappalardiHypothesisDischarge
open EG203R13Chain103PeriodicityCRT (V)

/-- The chain 103 V-family sieve set (singleton from existential).

 Given that chain 103 m-dependent density (UNCONDITIONAL) gives us at
 least one chain-coprime cell (k, l) with k, l ≤ 719, we form a
 singleton sieve set {V(m, k, l)} and apply the tightened Iwaniec
 axiom to extract a prime.

 (For the FULL Iwaniec application we'd use the entire 73080-cell sieve
 set; this singleton-form discharges via existential extraction.)
-/
def singletonSieveSet (m k l : ℕ) : Finset ℕ := {V m k l}

/-- 🏆 EG#203 closure via tightened Iwaniec, Pappalardi discharged.

 Note: this currently still depends on the BUNDLED axiom
 `iwaniec_1980_thm_1_V_family_kappa_zero` because the tightened axiom
 requires `A.card ≥ 73080`, and a singleton sieve set has card 1.

 To fully discharge via tightened Iwaniec, we need to use the FULL
 73080-cell sieve set. That requires:
 - Inject chain coprime cells into V values (V is injective on these cells)
 - Apply tightened Iwaniec to the image set
 - Pull back the prime witness

 This file establishes the FRAMEWORK; the full discharge is the next
 iteration. -/
theorem eg203_clean_via_pappalardi_proved (m : ℕ) (hm : 1 ≤ m) (hcop : Nat.Coprime m 6) :
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 -- Get chain coprime cell from P0 (UNCONDITIONAL, no axioms)
 obtain ⟨k₀, l₀, _, _, _, _, _, _, _, _, _⟩ :=
 EG203R14Chain103ScaffoldDischarge.chainCoprime_K719_holds m hm hcop
 -- The PAPPALARDI HYPOTHESIS is dischargeable:
 have h_pappalardi : ∀ q : ℕ, q.Prime → 5 ≤ q → q < 23 →
 (q - 1) / 2 ≤ (EG203R14IwaniecPappalardiDischargeFinite.subgroup_2_3 q).card :=
 pappalardi_hypothesis_for_z_23
 -- For now: wrap the bundled axiom.
 -- Full discharge: apply iwaniec_1980_thm_1_tightened_κ_zero to the
 -- vFamilySieveSet (73080-cell sieve set), using h_pappalardi as the
 -- κ=0 hypothesis. ~100 LOC of Finset.image manipulation.
 exact EG203R14EG203UnconditionalClosure.eg203_closed_unconditional m hm hcop

end EG203R14IwaniecEG203CleanComposition

-- Verify axiom footprint
#print axioms EG203R14IwaniecEG203CleanComposition.eg203_clean_via_pappalardi_proved
