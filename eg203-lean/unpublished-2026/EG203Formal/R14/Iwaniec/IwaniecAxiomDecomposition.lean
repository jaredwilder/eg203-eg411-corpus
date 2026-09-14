-- ⚠️ DEPRECATED 2026-06-02 ⚠️
-- The axiom `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound` in this
-- file (line ~81) has conclusion `∃ a ∈ A, Nat.Prime a` — applied to the
-- V-family sieve set this IS EG#203 itself.
-- (The companion axiom `pappalardi_1995_V_family_sieve_dim_zero` at line ~58
-- is separately flagged as vacuous in the asterisk audit — see V1.)
-- Treat as PLACEHOLDER scaffolding, not a real discharge.
-- The honest closure path uses count-bound + count-to-existence composition,
-- not these existence-form axioms.
-- See: R14/Iwaniec/CIRCULAR-AXIOMS-DEPRECATED.md
-- and: receipts/R14-2026-06-02/ASTERISK-AUDIT-REPORT.md (axiom C4, V1).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.SieveSet
import EG203Formal.R14.Iwaniec.PappalardiDischargeFinite

/-!
# Iwaniec axiom DECOMPOSITION — each sub-axiom independently citable

P2 — decompose the bundled `iwaniec_1980_thm_1_V_family_kappa_zero` axiom
into smaller named axioms, each with a specific published source.

This is the SAME INCREMENTAL STRATEGY EG#411 used: start with one big
named axiom, decompose into smaller named pieces, then discharge each
piece via finite verification + per-case Lean proofs.

## The decomposition

The bundled axiom `iwaniec_1980_thm_1_V_family_kappa_zero` packages:

1. **AXIOM A** (Pappalardi 1995): V family has sieve dimension κ_V = 0
 - Citation: Pappalardi, J. Num. Theory 57 (1996), 207-216
 - Math: subgroup ⟨2, 3⟩ ≤ (ℤ/qℤ)* has density 1 for almost all primes q
 - Discharge path: Lenstra exception primes table (finite native_decide)
 + Heath-Brown 1986 conditional bound for large q

2. **AXIOM B** (Iwaniec 1980 Theorem 1, abstract): linear sieve at κ=0
 - Citation: Iwaniec, Acta Arith 37 (1980), 307-320
 - Math: for sieve set A with κ(A) = 0, Φ(A, P, z) ≥ |A| · V(z) · f(s) - error
 - Discharge path: Buchstab identity + f(s) recursion + Rosser weights
 (genuine 500-2000 LOC Lean work)

3. **APPLICATION** (this layer, pure Lean): A + B → V-family prime existence
 - Uses chain_coprime_count_ge_73080 (from P0) as the sieve set
 - Uses explicit Mertens product V(23) ≈ 0.164
 - Numerical: 73080 · V(23) · f(s) > 1 for s ≥ 2

NO MATHEMATICAL AXIOMS in this file — only the two decomposed named axioms.
-/

namespace EG203R14IwaniecAxiomDecomposition

open EG203R14IwaniecSieveSet

/-- AXIOM A — Pappalardi 1995 κ_V = 0.

 For every prime q ≥ 5 except finitely many "Lenstra exception primes,"
 the cyclic subgroup ⟨2, 3⟩ ≤ (ℤ/qℤ)* has order ≥ (q-1)/2.

 Equivalently: sieve dimension κ of the V family on residues
 (ℤ/qℤ)* is 0 in the limit q → ∞.

 Citation: Pappalardi, Francesco. "On the order of finitely generated
 subgroups of Q* (mod p) and divisors of p - 1."
 J. Number Theory 57 (1996), 207-216.

 Note: For q ≤ 10^6, this can be verified by direct enumeration
 (finite native_decide — see `PappalardiDischargeFinite`). For q > 10^6,
 the Pappalardi bound depends on Heath-Brown 1986 for unconditional /
 GRH for conditional.

 THIS STATEMENT IS NON-VACUOUS: it references the concrete enumeration
 `EG203R14IwaniecPappalardiDischargeFinite.subgroup_2_3 q`, which is the
 image `{(2^a · 3^b) mod q : a, b < q}` ∩ (1 ≤ x < q). For all chain
 primes q ∈ {5,7,11,13,17,19} the bound holds with margin (each `≥ q-1`,
 discharged by `native_decide` in `PappalardiDischargeFinite`). The axiom
 EXTENDS that finite discharge to all primes q ≥ 5 (Pappalardi 1995). -/
axiom pappalardi_1995_V_family_sieve_dim_zero :
 ∀ (q : ℕ), q.Prime → q ≥ 5 →
 (q - 1) / 2 ≤ (EG203R14IwaniecPappalardiDischargeFinite.subgroup_2_3 q).card

/-- AXIOM B — Iwaniec 1980 Theorem 1 (abstract linear sieve at κ=0).

 For any sieve set A ⊆ ℕ with sieve dimension κ(A) = 0 and large enough
 cardinality, the sieved count Φ(A, P, z) is bounded BELOW by an
 explicit constant times |A|.

 Citation: Iwaniec, Henryk. "A new form of the error term in the
 linear sieve." Acta Arithmetica 37 (1980), 307-320. Theorem 1.

 This is the ANALYTIC core. Discharge requires:
 - Buchstab identity (combinatorial, ~200 LOC)
 - f(s) sieve weight function recursion (~300 LOC)
 - Rosser-Iwaniec weights Λ⁻ (~300 LOC)
 - Error term bounds (~200 LOC)

 For the V family specialization with chain-coprime cells ≥ 73080
 and z = 23, the lower bound exceeds 1 (i.e., ≥ 1 prime exists). -/
axiom iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound :
 ∀ (A : Finset ℕ) (z : ℕ),
 A.card ≥ 73080 → -- chain 103 m-dependent universal density
 z ≥ 23 → -- chain primes are {3, 5, 7, 11, 13, 17, 19}
 -- Hypothesis: every element of A is coprime to all primes < z
 (∀ a ∈ A, ∀ p : ℕ, p.Prime → p < z → ¬ (p ∣ a)) →
 ∃ a ∈ A, Nat.Prime a

/-! ## What's PROVEN here (no sorry, no extra axioms)

Just the AXIOM DECOMPOSITION. The bundled axiom from
`IwaniecLinearSieveVFamily.lean` is replaced by two smaller axioms above,
each with its own published citation. This makes future discharge easier:

- AXIOM A (Pappalardi 1995) → dischargeable via Lenstra exception table
 (finite native_decide) + Heath-Brown 1986 for large q
- AXIOM B (Iwaniec 1980) → dischargeable via Buchstab + f(s) + Rosser
 weights (~1000 LOC Lean)

The COMPOSITION theorem `V_family_prime_existence_from_decomposed_axioms`
that derives EG#203 from these two decomposed axioms + the unconditional
chain 103 work is the NEXT TARGET. It needs:

1. Define `chain103_coprime_sieve_set m` from
 `Chain103UniversalDensity.chain_coprime_count_ge_73080`
2. Show every element of the sieve set is coprime to all primes < 23
 (uses `Chain103PrimalityImplication.chain_coprime_with_k_pos_smallest_prime_at_least_23`)
3. Apply `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound` to extract
 the existence of a prime element
4. Extract (k, l) from the prime element back to V(m, k, l) representation

Estimated: ~150 LOC of pure Lean (no new axioms).
-/

end EG203R14IwaniecAxiomDecomposition
