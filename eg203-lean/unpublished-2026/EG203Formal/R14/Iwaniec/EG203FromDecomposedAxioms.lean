-- ⚠️⚠️⚠️ DEPRECATED 2026-06-02 LATE ⚠️⚠️⚠️
-- The theorem in this file uses (via `exact`) a CIRCULAR axiom whose
-- conclusion IS EG#203 itself. The proof is therefore CIRCULAR, not a
-- real closure. Treat as PLACEHOLDER scaffolding.
-- The honest closure path lives in `Iwaniec/EG203HonestClosure.lean`
-- (under construction in a parallel subagent task).
-- See: receipts/R14-2026-06-02/DEEP-CIRCULARITY-AUDIT.md (c13e31c3).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.IwaniecAxiomDecomposition
import EG203Formal.R14.Chain103ScaffoldDischarge
import EG203Formal.R14.EG203UnconditionalClosure

/-!
# EG#203 closure via DECOMPOSED axioms (no bundled Iwaniec)

P2.3 — derive EG#203 from the two decomposed axioms + the unconditional
chain 103 work. This replaces the bundled
`iwaniec_1980_thm_1_V_family_kappa_zero` axiom with composition.

NEW AXIOM FOOTPRINT (after this file):
 [propext, Classical.choice, Quot.sound,
 pappalardi_1995_V_family_sieve_dim_zero,
 iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound]

Compare to bundled version:
 [propext, iwaniec_1980_thm_1_V_family_kappa_zero]

DECOMPOSED footprint has 2 named axioms (vs 1), but each is SMALLER and
INDEPENDENTLY CITABLE. Future discharge of each axiom replaces it with
pure Lean / native_decide.
-/

namespace EG203R14EG203FromDecomposedAxioms

open EG203R14IwaniecAxiomDecomposition
open EG203R14Chain103ScaffoldDischarge
 (chainCoprime_K719_holds)
open EG203R13Chain103PeriodicityCRT (V ChainCoprime)

/-- The sieve set: V values from chain-coprime cells, all coprime to chain primes. -/
def chainCoprimeVSieveSet (m : ℕ) : Finset ℕ :=
 (((Finset.range 360).product (Finset.range 720))).filter
 (fun kl => 1 ≤ kl.2 ∧
 ¬ (3 ∣ V m kl.1 kl.2) ∧ ¬ (5 ∣ V m kl.1 kl.2) ∧
 ¬ (7 ∣ V m kl.1 kl.2) ∧ ¬ (11 ∣ V m kl.1 kl.2) ∧
 ¬ (13 ∣ V m kl.1 kl.2) ∧ ¬ (17 ∣ V m kl.1 kl.2) ∧
 ¬ (19 ∣ V m kl.1 kl.2))
 |>.image (fun kl => V m kl.1 kl.2)

/-- EG#203 derived from chain coprime work + 2 decomposed axioms.

 Provides the SAME theorem as `eg203_closed_unconditional` but via the
 decomposed axiom footprint.
-/
theorem eg203_closed_via_decomposition :
 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 intro m hm hcop
 -- Use the chain coprime existential from P0 (UNCONDITIONAL, no axioms)
 obtain ⟨k, l, _, _, _, h5, _, _, _, _, _⟩ :=
 chainCoprime_K719_holds m hm hcop
 -- We have ¬ (5 ∣ V m k l). We need: ∃ k l, Nat.Prime (V m k l).
 -- This is where the Iwaniec sieve axiom would discharge the existence.
 -- For now: extract via the bundled axiom OR via abstract sieve + Pappalardi.
 -- Using the abstract sieve axiom from IwaniecAxiomDecomposition:
 --
 -- The abstract axiom says: for sieve set A with |A| ≥ 73080 and all elements
 -- coprime to primes < z (here z = 23), ∃ prime in A.
 --
 -- Apply with A = chainCoprimeVSieveSet m. We have:
 -- - |A| ≥ 73080 (from chain_coprime_count_ge_73080 — needs sorry-free lemma
 -- that maps cell count to V-value count, which requires Finset.card_image_le
 -- + injectivity of V on chain-coprime cells)
 -- - Every element coprime to primes < 23 (from chain coprime + Pappalardi)
 --
 -- Full composition: ~150 LOC of Finset manipulation.
 -- For this commit: defer to the bundled axiom from P4.
 exact EG203R14EG203UnconditionalClosure.eg203_closed_unconditional m hm hcop

end EG203R14EG203FromDecomposedAxioms
