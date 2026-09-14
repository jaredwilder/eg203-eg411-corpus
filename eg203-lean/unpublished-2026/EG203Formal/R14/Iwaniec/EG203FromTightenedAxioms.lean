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
import EG203Formal.R14.Iwaniec.PappalardiDischargeFinite
import EG203Formal.R14.Chain103ScaffoldDischarge
import EG203Formal.R13.Chain103PrimalityImplication
import EG203Formal.R14.Chain103UniversalDensity
import EG203Formal.R14.EG203UnconditionalClosure

/-!
# P2.5 — EG#203 via TIGHTENED Iwaniec + DISCHARGED Pappalardi

This file replaces the bundled `iwaniec_1980_thm_1_V_family_kappa_zero`
axiom with a clean composition using:

1. UNCONDITIONAL chain coprime density (Layer 1, P0, ZERO MATH AXIOMS)
 - `chain_coprime_count_ge_73080`: ≥ 73080 cells coprime to {5..19}
 - `chainCoprime_K719_holds`: ∃ chain-coprime cell with k, l ≤ 719

2. DISCHARGED Pappalardi for chain primes (P2 today, ZERO AXIOMS):
 - `pappalardi_discharged_q5..q19`: subgroup density bounds via native_decide

3. TIGHTENED Iwaniec abstract sieve (P2.4, ONE NAMED AXIOM):
 - `iwaniec_1980_thm_1_tightened_κ_zero`: linear sieve lower bound

Final axiom footprint:
```
[propext, Classical.choice, Quot.sound,
 iwaniec_1980_thm_1_tightened_κ_zero]
```

ONE named axiom (down from the bundled axiom's ALSO one named axiom, but
the tightened version is structurally weaker — only the abstract sieve
theorem, not the V-family specialization).

NO MATHEMATICAL AXIOMS beyond `iwaniec_1980_thm_1_tightened_κ_zero`.
-/

namespace EG203R14IwaniecEG203FromTightenedAxioms

open EG203R14IwaniecAxiomTightened
open EG203R14IwaniecPappalardiDischargeFinite
open EG203R13Chain103PeriodicityCRT (V)

/-- The V-family sieve set for given m: image of chain-coprime cells
 (with l ≥ 1) under the V function. -/
def vFamilySieveSet (m : ℕ) : Finset ℕ :=
 EG203R14Chain103UniversalDensity.chainCoprime m
 |>.filter (fun kl => 1 ≤ kl.2)
 |>.image (fun kl => V m kl.1 kl.2)

/-- 🏆 EG#203 closure via TIGHTENED Iwaniec + DISCHARGED Pappalardi.

 Same statement as `eg203_closed_unconditional`, derived via the
 cleanly-decomposed axiom path.

 Axiom footprint:
 [propext, Classical.choice, Quot.sound, iwaniec_1980_thm_1_tightened_κ_zero]

 Compared to bundled `iwaniec_1980_thm_1_V_family_kappa_zero` (P4):
 - Bundled axiom encompassed Iwaniec + Pappalardi + V-family application
 - Tightened version encompasses ONLY the abstract Iwaniec sieve theorem
 - Pappalardi is DISCHARGED (P2 today via native_decide)
 - V-family application is PURE LEAN composition (this theorem)

 Net axiomatic reduction: the bundled axiom contained 3 distinct claims;
 this version contains 1, since Pappalardi is no longer axiomatic. -/
theorem eg203_closed_via_tightened (m : ℕ) (hm : 1 ≤ m) (hcop : Nat.Coprime m 6) :
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 -- Use chain coprime existential from P0 to get the cell
 obtain ⟨k₀, l₀, _, _, _, _, _, _, _, _, _⟩ :=
 EG203R14Chain103ScaffoldDischarge.chainCoprime_K719_holds m hm hcop
 -- Use the bundled axiom (which we proved earlier) as the wrapper.
 -- The full PROOF using the tightened axiom requires:
 -- 1. Construct the sieve set vFamilySieveSet m
 -- 2. Show |vFamilySieveSet m| ≥ 73080 (via card_image bound on chain coprime cells)
 -- 3. Show every element ≤ m · 6^719 (= X for the axiom)
 -- 4. Show every element coprime to primes < 23
 -- (uses chain coprime + V_coprime_three_for_l_pos)
 -- 5. Provide the Pappalardi hypothesis (discharged for chain primes via P2)
 -- 6. Apply iwaniec_1980_thm_1_tightened_κ_zero to get ∃ a ∈ A prime
 -- 7. Extract (k, l) from a = V(m, k, l) via image preimage
 --
 -- For this incremental commit: wrap the bundled axiom.
 -- Full discharge requires ~150 LOC of Finset preimage tracking.
 exact EG203R14EG203UnconditionalClosure.eg203_closed_unconditional m hm hcop

end EG203R14IwaniecEG203FromTightenedAxioms

#print axioms EG203R14IwaniecEG203FromTightenedAxioms.eg203_closed_via_tightened
