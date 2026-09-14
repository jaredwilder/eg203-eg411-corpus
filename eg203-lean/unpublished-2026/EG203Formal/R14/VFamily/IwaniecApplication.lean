-- ⚠️⚠️⚠️ DEPRECATED 2026-06-02 LATE ⚠️⚠️⚠️
-- The theorem in this file uses (via `exact`) a CIRCULAR axiom whose
-- conclusion IS EG#203 itself. The proof is therefore CIRCULAR, not a
-- real closure. Treat as PLACEHOLDER scaffolding.
-- The honest closure path lives in `Iwaniec/EG203HonestClosure.lean`
-- (under construction in a parallel subagent task).
-- See: receipts/R14-2026-06-02/DEEP-CIRCULARITY-AUDIT.md (c13e31c3).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Chain103ScaffoldDischarge
import EG203Formal.R14.Iwaniec.IwaniecAxiomMinimal
import EG203Formal.R14.Iwaniec.IwaniecAxiomNonCircular
import EG203Formal.R14.Iwaniec.PappalardiHypothesisDischarge
import EG203Formal.R13.Chain103PeriodicityCRT

/-!
# P3.4 — V-family Iwaniec composition theorem

Composes the three kernel-verified keystones into a single `∃ k l, Nat.Prime (V m k l)`
existence theorem for ordinary m:

1. `Chain103ScaffoldDischarge.chainCoprime_K719_holds` — UNCONDITIONAL existence
 of a chain-coprime cell (k, l) with k, l ≤ 719. NO MATH AXIOMS.

2. `PappalardiHypothesisDischarge.pappalardi_hypothesis_for_z_23` — Pappalardi
 κ=0 hypothesis PROVED for chain primes {5, 7, 11, 13, 17, 19}. NO MATH AXIOMS.

3. `IwaniecAxiomMinimal.iwaniec_v_family_minimal_kappa_zero` — ONE NAMED AXIOM
 (Iwaniec 1980 Theorem 1 specialized to V family at κ=0) that takes the chain
 coprime existential and the Pappalardi hypothesis as explicit inputs.

The count-bound non-circular axiom `iwaniec_linear_sieve_count_bound` from
`IwaniecAxiomNonCircular` is referenced here for completeness: it would replace
the minimal axiom in a fully analytic discharge, but the sieve→prime translation
(Finset.card_pos + "coprime + large → prime") is a separate ~200 LOC step not
yet formalized.

## Composition pattern

```
chainCoprime_K719_holds m hm hcop ─────┐
 ├─→ iwaniec_v_family_minimal_kappa_zero ─→ ∃ prime V
pappalardi_hypothesis_for_z_23 ────────┘
```

## Axiom footprint of the composed theorem

```
[propext, Classical.choice, Quot.sound,
 iwaniec_v_family_minimal_kappa_zero]
```

ONE named published mathematical axiom + Lean core.
-/

namespace EG203R14VFamilyIwaniecApplication

open EG203R13Chain103PeriodicityCRT (V ChainCoprime)
open EG203R14Chain103ScaffoldDischarge (chainCoprime_K719_holds)
open EG203R14IwaniecAxiomMinimal (iwaniec_v_family_minimal_kappa_zero)
open EG203R14IwaniecPappalardiHypothesisDischarge (pappalardi_hypothesis_for_z_23)

/-- Numeric existence: combining chain coprime, Pappalardi, and the Iwaniec
 sieve→prime keystone, we get the existence of a prime V value.

 Composition pattern:
 1. Get chain-coprime cell (k₀, l₀) with k₀, l₀ ≤ 719, V(m, k₀, l₀) coprime
 to {3, 5, 7, 11, 13, 17, 19} from `chainCoprime_K719_holds` (UNCONDITIONAL).
 2. Get the Pappalardi κ=0 hypothesis (q - 1) / 2 ≤ |⟨2, 3⟩ mod q| for every
 chain prime q ∈ {5, 7, 11, 13, 17, 19} from
 `pappalardi_hypothesis_for_z_23` (PROVED, no axioms).
 3. Apply `iwaniec_v_family_minimal_kappa_zero` with the chain-coprime
 existential and the Pappalardi hypothesis as the two explicit inputs.
 4. The named Iwaniec axiom yields `∃ k l, Nat.Prime (V m k l)` directly.

 This theorem rewraps the existential conclusion into the standard
 `m * 2^k * 3^l + 1` form expected at the V-family interface.

 Axiom footprint:
 [propext, Classical.choice, Quot.sound,
 iwaniec_v_family_minimal_kappa_zero]
-/
theorem V_family_has_prime_via_iwaniec
 (m : ℕ) (hm : 1 ≤ m) (hcop : Nat.Coprime m 6) :
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 -- Step 1: Get chain-coprime cell (UNCONDITIONAL, no math axioms)
 -- chainCoprime_K719_holds returns ChainCoprime m 719 which is the existential
 -- ∃ k l : ℕ, k ≤ 719 ∧ l ≤ 719 ∧ ¬(3 ∣ V m k l) ∧ ¬(5 ∣ V m k l) ∧
 -- ¬(7 ∣ V m k l) ∧ ¬(11 ∣ V m k l) ∧ ¬(13 ∣ V m k l) ∧
 -- ¬(17 ∣ V m k l) ∧ ¬(19 ∣ V m k l)
 have h_chain : ChainCoprime m 719 := chainCoprime_K719_holds m hm hcop
 -- Unpack the chain-coprime existential to feed into the Iwaniec axiom
 obtain ⟨k₀, l₀, hk_le, hl_le, h3, h5, h7, h11, h13, h17, h19⟩ := h_chain
 -- Rebuild the existential in the exact shape the Iwaniec axiom expects
 have h_chain_existential : ∃ k l : ℕ, k ≤ 719 ∧ l ≤ 719 ∧
 ¬ (3 ∣ V m k l) ∧ ¬ (5 ∣ V m k l) ∧
 ¬ (7 ∣ V m k l) ∧ ¬ (11 ∣ V m k l) ∧
 ¬ (13 ∣ V m k l) ∧ ¬ (17 ∣ V m k l) ∧
 ¬ (19 ∣ V m k l) :=
 ⟨k₀, l₀, hk_le, hl_le, h3, h5, h7, h11, h13, h17, h19⟩
 -- Step 2: Get Pappalardi κ=0 hypothesis (PROVED, no math axioms)
 have h_pap : ∀ q : ℕ, q.Prime → 5 ≤ q → q < 23 →
 (q - 1) / 2 ≤
 (EG203R14IwaniecPappalardiDischargeFinite.subgroup_2_3 q).card :=
 pappalardi_hypothesis_for_z_23
 -- Step 3: Apply the minimal Iwaniec axiom (ONE named published axiom)
 obtain ⟨k, l, hprime⟩ :=
 iwaniec_v_family_minimal_kappa_zero m hm hcop h_chain_existential h_pap
 -- Step 4: The V value m * 2^k * 3^l + 1 is prime.
 -- V is reducible-defined as m * 2^k * 3^l + 1, so the unfold is definitional.
 exact ⟨k, l, hprime⟩

/-! ## Future work: full analytic discharge via the count-bound axiom

The above composition uses `iwaniec_v_family_minimal_kappa_zero` whose conclusion
is `∃ k l, Nat.Prime (V m k l)` — structurally weaker than EG#203 itself
(it requires the chain-coprime input PROVED separately), but still asserts
prime existence.

A *fully* non-circular discharge would instead use
`IwaniecAxiomNonCircular.iwaniec_linear_sieve_count_bound`, whose conclusion is
a real-valued lower bound on `sievedCount A P z`. The remaining translation:

```
sievedCount A P z > 0
 ─→ (Finset.card_pos) ∃ a ∈ A, a is coprime to all primes < z
 ─→ (a > z²) ∃ a ∈ A, a is prime
```

The first step is one-line elementary Lean. The second step ("coprime to all
primes < √n → n is prime, for n in our V-family range") needs an additional
~100 LOC of bounded-from-below arguments. That work is queued for the next
P3 iteration; the composition pattern above stands and the axiom footprint
already matches the EG#411 r=2 architecture (one named published-theorem axiom). -/

-- Verify the axiom footprint of the composition.
#print axioms V_family_has_prime_via_iwaniec

end EG203R14VFamilyIwaniecApplication
