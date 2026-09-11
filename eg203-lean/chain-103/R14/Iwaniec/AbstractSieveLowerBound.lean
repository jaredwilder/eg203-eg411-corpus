import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.SieveSet
import EG203Formal.R14.Iwaniec.BuchstabIdentity
import EG203Formal.R14.Iwaniec.BuchstabApplied
import EG203Formal.R14.Iwaniec.FSieveWeight
import EG203Formal.R14.Iwaniec.FMonotonicityExtension

/-!
# P2.6 — Abstract Iwaniec linear sieve lower bound (composition)

This file composes the kernel-verified infrastructure already shipped:
 * `EG203R14IwaniecSieveSet.sievedCount` — combinatorial sieved count
 * `EG203R14IwaniecBuchstabIdentity.buchstab_partition` — partition identity
 * `EG203R14IwaniecBuchstabApplied.sievedCount_lower_via_buchstab`
 — Buchstab → lower bound shape
 * `EG203R14IwaniecFSieveWeight.f_pos_of_two_lt` — f(s) > 0 on (2, 3]
 * `EG203R14IwaniecFMonotonicityExtension.f_pos_on_two_three`
 — f(s) > 0 on (2, 3]
 (thin restatement;
 the previous
 "all s > 2" form
 was inconsistent with
 the concrete piecewise
 definition of f and
 has been removed)

## What this file proves

Three lower-bound theorems of increasing strength.

### (1) Trivial lower bound (kernel-verified, ZERO axioms)

`abstract_sieve_count_lower`: `sievedCount A P z ≥ 0`.

This is the absolute floor — the sieved count is a natural-number cardinality,
so it is non-negative. The point: it compiles with **no** axioms, not even
the named ones from `FMonotonicityExtension`.

### (2) Buchstab-derived lower bound (kernel-verified, ZERO new axioms)

`abstract_sieve_count_buchstab_lower`: given an upper bound `C` on the
Buchstab boundary stratum between `z₁ ≤ z₂`, we get
`sievedCount A P z₂ ≥ sievedCount A P z₁ - C`.

This is the **shape** of the Iwaniec lower bound when iterated through the
Buchstab recursion. The only inputs are the partition identity (proved)
and arithmetic.

### (3) Asymptotic Iwaniec form (composition with ONE named axiom)

`abstract_iwaniec_lower_with_count_axiom`: an abstract statement of the
Iwaniec linear-sieve lower bound

 `sievedCount A P z ≥ W · f(s) - R`

where `W` is a "main-term coefficient" (think `|A| · V(z)` in Iwaniec's
notation), `f(s) > 0` is the linear-sieve weight at sifting ratio `s`,
and `R` is the error term. The bound is expressed as an axiom-statement
**hypothesis** (passed in by the caller) and the theorem just unpacks it
into the convenient `sievedCount ≥ 0` form when `W · f(s) ≥ R`.

The point: the only axiom this file pulls is the one already imported
(`iwaniec_f_monotonicity_lower_bound`), used to know `f(s) > 0` for s > 2.

## Axiom footprint

ALL three bounds (trivial, Buchstab-derived, asymptotic) now use **zero
axioms**. The asymptotic form previously inherited a named axiom
(`iwaniec_f_monotonicity_lower_bound`) from `FMonotonicityExtension`,
but that axiom was inconsistent with the concrete piecewise definition
of `f` (it asserted a strictly positive lower bound on `s ≥ 3` where
the definition gives `f s = 0`) and has been deleted.

The cost of that deletion: the asymptotic form now carries an extra
hypothesis `s ≤ 3`, restricting the sifting ratio to the range where
the concrete `f` is honestly positive. Extending past `s = 3` requires
formalizing the Iwaniec delay-differential extension of `f` (a separate
analysis project).

## Why this matters

The real Iwaniec linear sieve lower bound (Iwaniec 1980 Acta Arith Thm 1)
is a deep theorem combining:
 (a) The Buchstab combinatorial identity (PROVED here)
 (b) The f/F weight functions and their delay-differential equations
 (positivity PROVED on (2,3], extension to s > 2 via ONE named axiom)
 (c) Iterated descent giving the asymptotic main term `|A| · V(z) · f(s)`
 (the iteration is the analytic part that we currently take as a
 hypothesis rather than dischargeable in Lean)

This file is the **composition layer**: it shows that *given* the kernel
pieces, the abstract lower-bound shape goes through with no further
axioms. Promotion to the full numeric bound is the job of
`IwaniecAxiomTightened.lean` and downstream files.

NO SORRIES.
-/

namespace EG203R14IwaniecAbstractSieveLowerBound

open EG203R14IwaniecSieveSet
open EG203R14IwaniecBuchstabIdentity
open EG203R14IwaniecBuchstabApplied
open EG203R14IwaniecFSieveWeight
open EG203R14IwaniecFMonotonicityExtension

/-! ## (1) Trivial lower bound — kernel-verified, zero axioms -/

/-- The trivial Iwaniec lower bound: `sievedCount A P z ≥ 0`.

 This compiles with ZERO axioms. It is the absolute floor for the
 sieved count (a natural-number cardinality is non-negative).

 The strength of this statement is intentionally minimal — its purpose
 is to anchor the bottom of the lower-bound hierarchy and to be the
 one fact every caller can rely on without any hypotheses about
 Buchstab, f(s), or the count axiom.

 For the real Iwaniec bound `sievedCount A P z ≥ |A| · V(z) · f(s) - R`
 see `abstract_iwaniec_lower_with_count_axiom` below. -/
theorem abstract_sieve_count_lower
 (A : Finset ℕ) (P : Finset ℕ) (z : ℕ)
 (_h_z : 23 ≤ z) :
 sievedCount A P z ≥ 0 :=
 Nat.zero_le _

/-! ## (2) Buchstab-derived lower bound — kernel-verified, zero new axioms -/

/-- Buchstab-derived lower bound (shape of the iterated sieve descent).

 If the Buchstab boundary stratum between `z₁ ≤ z₂` is bounded above by
 `C`, then
 `sievedCount A P z₂ ≥ sievedCount A P z₁ - C`.

 This is the elementary lower-bound mechanism that Iwaniec's linear
 sieve iterates: each Buchstab step replaces the boundary by an upper
 bound, and the resulting telescoping gives the main-term + error-term
 asymptotic.

 Proof: a one-line consequence of `buchstab_partition`. -/
theorem abstract_sieve_count_buchstab_lower
 (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ C : ℕ}
 (h : z₁ ≤ z₂)
 (h_boundary_le : buchstabBoundary A P z₁ z₂ ≤ C) :
 sievedCount A P z₁ ≤ sievedCount A P z₂ + C :=
 sievedCount_lower_via_buchstab A P h h_boundary_le

/-- Buchstab-derived lower bound (subtraction form, for `sievedCount A P z₁ ≥ C`).

 Same statement as `abstract_sieve_count_buchstab_lower`, but solved
 for `sievedCount A P z₂` in `ℕ` (truncated subtraction). -/
theorem abstract_sieve_count_buchstab_lower_sub
 (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ C : ℕ}
 (h : z₁ ≤ z₂)
 (h_boundary_le : buchstabBoundary A P z₁ z₂ ≤ C) :
 sievedCount A P z₁ - C ≤ sievedCount A P z₂ := by
 have h_le := sievedCount_lower_via_buchstab A P h h_boundary_le
 omega

/-! ## (3) Asymptotic Iwaniec form — composition with named axiom

The real Iwaniec linear-sieve lower bound has the shape

 `sievedCount A P z ≥ W · f(s) - R`

where:
 * `W` is the "main-term coefficient" (`|A| · V(z)` in Iwaniec's notation),
 * `f(s) > 0` is the linear-sieve weight at sifting ratio `s = log y / log z`,
 * `R` is the error term controlled by Iwaniec's R(A,d) sums.

We expose this as a theorem that takes the (W, f(s), R) bound as a hypothesis,
and uses the positivity of `f(s)` from `f_pos_on_two_three` to extract
the useful corollary `sievedCount A P z > 0` (witness extraction).

The sifting ratio `s` is restricted to `(2, 3]` — the range on which the
concrete piecewise `f` from `FSieveWeight` is honestly positive. -/

/-- Composition theorem: from an abstract Iwaniec-shape lower bound
 `sievedCount A P z ≥ W·f(s) - R` and the assumption that the main term
 strictly dominates the error term (`W·f(s) > R`), conclude
 `sievedCount A P z > 0`.

 This is the **witness-extraction** corollary of the Iwaniec lower
 bound used everywhere in the V-family closure: we don't need the exact
 asymptotic — we only need positivity of the sieved count, which buys
 us a survivor with no small prime divisor (the prime-existence step).

 The bound `h_iwaniec_lb` is taken as a HYPOTHESIS so that this file
 introduces no new axioms beyond those already imported. Callers that
 want to discharge `h_iwaniec_lb` against a concrete `(A, P, z)`
 instance can do so via `IwaniecAxiomTightened.lean` (Iwaniec 1980
 Theorem 1) or its successors.

 The sifting ratio is restricted to `s ∈ (2, 3]` — the range on which
 the concrete `f` from `FSieveWeight` is honestly positive. The
 previous version of this theorem allowed all `s > 2` but relied on
 an INCONSISTENT axiom (`iwaniec_f_monotonicity_lower_bound`); that
 axiom has been deleted and the `s ≤ 3` hypothesis added in its place.
 Extending past `s = 3` requires formalizing the true Iwaniec
 delay-differential extension of `f` (separate analysis project).

 NOTE: we state the conclusion `0 < sievedCount A P z` over ℝ-shaped
 hypotheses but rely only on the integer cast — the f(s) > 0
 positivity is what does the work. -/
theorem abstract_iwaniec_lower_with_count_axiom
 (A : Finset ℕ) (P : Finset ℕ) (z : ℕ) (s : ℝ)
 (W R : ℝ)
 (hs_lo : 2 < s) (hs_hi : s ≤ 3)
 (hW_nonneg : 0 ≤ W)
 (h_main_gt_R : R < W * f s)
 (h_iwaniec_lb : (sievedCount A P z : ℝ) ≥ W * f s - R) :
 0 < sievedCount A P z := by
 -- f(s) > 0 on (2, 3] by the closed-form positivity lemma (no axioms).
 have hf_pos : 0 < f s := f_pos_on_two_three s hs_lo hs_hi
 -- Hence the main term W * f(s) is non-negative.
 have hWf_nonneg : 0 ≤ W * f s := mul_nonneg hW_nonneg (le_of_lt hf_pos)
 -- The main term strictly dominates R, so W * f(s) - R > 0.
 have h_diff_pos : 0 < W * f s - R := by linarith
 -- Combined with h_iwaniec_lb: (sievedCount A P z : ℝ) > 0.
 have h_card_pos_real : (0 : ℝ) < (sievedCount A P z : ℝ) := by linarith
 -- Cast back to ℕ.
 exact_mod_cast h_card_pos_real

/-! ## (4) Specialization to the V-family setting

The V-family at `z = 23` is the regime where every chain-coprime cell
lands in `[23, ∞)`-coprime primes. The trivial lower bound is too weak
(it only gives `≥ 0`); the Buchstab/Iwaniec forms above are what enable
the actual prime extraction. -/

/-- Specialization of `abstract_sieve_count_lower` to `z = 23`, which is
 the regime used by the EG#203 V-family closure (since we sieve out
 primes < 23 = {2, 3, 5, 7, 11, 13, 17, 19}).

 Still kernel-verified, no axioms. -/
theorem abstract_sieve_count_lower_at_23
 (A : Finset ℕ) (P : Finset ℕ) :
 sievedCount A P 23 ≥ 0 :=
 abstract_sieve_count_lower A P 23 (le_refl 23)

/-- Asymptotic Iwaniec at `z = 23` — same composition as the abstract
 form above, specialized for documentation. -/
theorem abstract_iwaniec_lower_at_23
 (A : Finset ℕ) (P : Finset ℕ) (s : ℝ)
 (W R : ℝ)
 (hs_lo : 2 < s) (hs_hi : s ≤ 3)
 (hW_nonneg : 0 ≤ W)
 (h_main_gt_R : R < W * f s)
 (h_iwaniec_lb : (sievedCount A P 23 : ℝ) ≥ W * f s - R) :
 0 < sievedCount A P 23 :=
 abstract_iwaniec_lower_with_count_axiom A P 23 s W R hs_lo hs_hi hW_nonneg
 h_main_gt_R h_iwaniec_lb

end EG203R14IwaniecAbstractSieveLowerBound
