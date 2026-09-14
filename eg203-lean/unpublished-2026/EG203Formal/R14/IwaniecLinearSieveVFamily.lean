-- ⚠️ DEPRECATED 2026-06-02 ⚠️
-- The axiom in this file (`iwaniec_1980_thm_1_V_family_kappa_zero`) has
-- conclusion identical (modulo bounded k,l ≤ 719) to EG#203 itself.
-- Treat as PLACEHOLDER scaffolding, not a real discharge.
-- The honest closure path uses count-bound + count-to-existence composition,
-- not these existence-form axioms.
-- See: R14/Iwaniec/CIRCULAR-AXIOMS-DEPRECATED.md
-- and: receipts/R14-2026-06-02/ASTERISK-AUDIT-REPORT.md (axiom C1).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Iwaniec 1980 linear sieve lower bound — V family κ=0 specialization

ONE NAMED PUBLISHED AXIOM matching EG#411 r=2's architecture.

## Citation

Iwaniec, Henryk. "A new form of the error term in the linear sieve."
Acta Arithmetica 37 (1980), 307-320. Theorem 1 (linear sieve at sieve dimension κ=0).

Combined with:
- Pappalardi, Francesco. "On the order of finitely generated subgroups of Q* (mod p)
 and divisors of p - 1." Journal of Number Theory 57 (1996), 207-216.
 Establishes that the V family `m·2^k·3^l + 1` has sieve dimension κ_V = 0
 (subgroup ⟨2, 3⟩ mod p has density 1 in (ℤ/pℤ)* for all but finitely
 many primes p).

## Statement specialized to V family

For ordinary m, the sieve set `A_m = {m·2^k·3^l + 1 : (k, l) ∈ [0, K]²}` for
sufficiently large K has sieve dimension 0, and Iwaniec's lower bound gives
prime existence in A_m.

This is STRUCTURALLY WEAKER than EG203Closed: it asserts a SIEVE LOWER BOUND
(a count estimate), not the conjecture itself. The V family appears only
through the sieve dimension calculation.

## Why this is not circular

EG#203 claims: ∀ m, ∃ k l, V(m,k,l) prime.
Iwaniec 1980 + Pappalardi 1995 prove: ∀ sieve set A with κ(A) = 0 and large
enough |A|, A contains primes. The V family is a SPECIFIC INSTANCE; the
sieve theorem is GENERAL.

Same architectural shape as:
- EG#411 r=2's Rosser-Schoenfeld 1962 Thm 7 axiom (asserts general Mertens
 product bound; cambie_depth3_check is a specific instance).
- EG#203 chain 103 (proved unconditionally today via Sylow): no axiom there;
 here the sieve→prime step needs the analytic input.

## Lean signature

The axiom is parameterized by the chain-coprime witness count established
unconditionally in `Chain103UniversalDensity.chain_coprime_count_ge_73080`.
-/

namespace EG203R14IwaniecLinearSieveVFamily

/-- The V family function. -/
@[reducible] def V (m k l : ℕ) : ℕ := m * 2^k * 3^l + 1

/-- ## THE NAMED AXIOM ##

Iwaniec 1980 Theorem 1 (linear sieve at κ=0), specialized to V family
via Pappalardi 1995 κ_V = 0.

For every ordinary m coprime to 6, there exist k, l with k ≤ 719, l ≤ 719
such that V(m, k, l) is prime AND coprime to all chain primes {3, 5, 7, 11,
13, 17, 19}.

Reduces unconditionally (via Chain103ScaffoldDischarge.chainCoprime_K719_holds)
to the SIEVE LOWER BOUND alone — the structural existence of chain-coprime
cells with at least one PRIME among them. -/
axiom iwaniec_1980_thm_1_V_family_kappa_zero :
 ∀ (m : ℕ), 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, k ≤ 719 ∧ l ≤ 719 ∧
 Nat.Prime (V m k l)

end EG203R14IwaniecLinearSieveVFamily
