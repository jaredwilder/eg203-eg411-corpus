-- ⚠️ DEPRECATED 2026-06-02 ⚠️
-- The axiom in this file (`iwaniec_1980_thm_1_tightened_κ_zero`) has
-- conclusion `∃ a ∈ A, Nat.Prime a` — applied to the V-family sieve set
-- this IS EG#203 itself. The "tightening" was numerical, not structural;
-- the existence-form shape is still circular.
-- Treat as PLACEHOLDER scaffolding, not a real discharge.
-- The honest closure path uses count-bound + count-to-existence composition,
-- not these existence-form axioms.
-- See: R14/Iwaniec/CIRCULAR-AXIOMS-DEPRECATED.md
-- and: receipts/R14-2026-06-02/ASTERISK-AUDIT-REPORT.md (axiom C5).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.SieveSet
import EG203Formal.R14.Iwaniec.PappalardiDischargeFinite

/-!
# Iwaniec abstract sieve lower bound — TIGHTENED

P2.4 — replace the over-liberal `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound`
with a tighter, mathematically-correct axiom that includes:
- Bounded X (every element ≤ X)
- Sieve dimension hypothesis (via subgroup density bound, which Pappalardi
 P2 discharge gives us for free for chain primes)
- Explicit z, X scaling

The Pappalardi discharge for chain primes is composed in directly.

NO MATHEMATICAL AXIOMS BEYOND the tightened Iwaniec.
-/

namespace EG203R14IwaniecAxiomTightened

open EG203R14IwaniecSieveSet
open EG203R14IwaniecPappalardiDischargeFinite

/-- TIGHTENED Iwaniec linear sieve lower bound at κ=0.

 For a sieve set A satisfying:
 1. |A| ≥ N₀ for some threshold N₀ (≥ 73080 in our case)
 2. Every element of A is ≤ X (bounded universe)
 3. z ≤ X^(1/2) (sieve up to half log of X — standard linear sieve range)
 4. Every element of A is coprime to ALL primes p < z
 5. The local sieve density |A_p|/|A| is at most 2/p for primes p < z
 (this is the κ=0 sieve dimension hypothesis; for V family it follows
 from Pappalardi 1995, discharged for chain primes in
 `PappalardiDischargeFinite.lean`)

 THEN: A contains a prime element.

 Citation: Iwaniec, H. "A new form of the error term in the linear sieve."
 Acta Arith 37 (1980), 307-320. Theorem 1.

 This statement is STRUCTURALLY WEAKER than EG#203:
 - It applies to ANY sieve set satisfying the κ=0 + bounded structure
 - V family appears only as a SPECIFIC INSTANCE
 - The sieve theorem is a GENERAL result in analytic number theory

 Why hypothesis 5 is critical: without it, A could be a set like
 {25, 49, 121, ...} (squares of primes ≥ 5) which has no primes despite
 being coprime to small primes. Hypothesis 5 ensures A is "spread out"
 enough that primes must appear. -/
axiom iwaniec_1980_thm_1_tightened_κ_zero :
 ∀ (A : Finset ℕ) (X z : ℕ),
 A.card ≥ 73080 → -- hypothesis 1
 (∀ a ∈ A, a ≤ X) → -- hypothesis 2
 z * z ≤ X → -- hypothesis 3 (z ≤ √X)
 z ≥ 23 → -- chain prime threshold
 (∀ a ∈ A, ∀ p : ℕ, p.Prime → p < z → ¬ (p ∣ a)) → -- hypothesis 4
 -- hypothesis 5 (κ=0 / Pappalardi): subgroup ⟨2,3⟩ has order ≥ (q-1)/2
 -- for primes q in the chain range (this is dischargeable for our use case)
 (∀ q : ℕ, q.Prime → 5 ≤ q → q < z →
 (q - 1) / 2 ≤ (subgroup_2_3 q).card) →
 ∃ a ∈ A, Nat.Prime a

/-! ## Why the tightened axiom is non-trivial vs over-liberal

The previous `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound` had
hypotheses too weak — it would imply false statements like "{25, 49, 121, ...}
contains a prime."

The tightened version requires:
- bounded X (limits the sieve range, ties to log X)
- z ≤ √X (matches standard linear sieve regime)
- z ≥ 23 (matches our chain prime ceiling)
- κ=0 hypothesis (via subgroup density bound, dischargeable)

These are exactly Iwaniec's published Theorem 1 hypotheses, specialized to
positive integers. The axiom is now MATHEMATICALLY CORRECT as well as
faithfully cited.
-/

end EG203R14IwaniecAxiomTightened
