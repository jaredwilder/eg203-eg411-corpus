# CIRCULAR AXIOMS — DEPRECATED 2026-06-02

Consolidation index of the 5 circular axiom files marked DEPRECATED on
2026-06-02, plus the downstream files that consume them.

Source of truth for the audit:
`receipts/R14-2026-06-02/ASTERISK-AUDIT-REPORT.md` (sections B and F).

---

## TL;DR

Five axiom files in `EG203Formal/R14/` (`IwaniecLinearSieveVFamily.lean`
plus four in `R14/Iwaniec/`) ship axioms whose CONCLUSION is, modulo
cosmetic bounds, the statement of Erdős–Graham #203 itself.

Asserting them = assuming the conjecture. The "proofs" of `EG#203`
that consume these axioms are pure repackaging (destructure the
existential and re-pack).

The files are NOT deleted (they are imported by several keystone
scaffolds), but each is marked at the top with a deprecation header.
The honest closure path is COUNT BOUND + COUNT → EXISTENCE composition,
NOT these existence-form axioms.

---

## The five circular axioms

| # | Axiom name | File | Audit code |
|---|---|---|---|
| 1 | `iwaniec_1980_thm_1_V_family_kappa_zero` | `R14/IwaniecLinearSieveVFamily.lean` (line 67) | C1 |
| 2 | `iwaniec_v_family_minimal_kappa_zero` | `R14/Iwaniec/IwaniecAxiomMinimal.lean` (line 49) | C2 |
| 3 | `iwaniec_v_family_numeric_evaluation` | `R14/Iwaniec/IwaniecMinimalNumericAxiom.lean` (line 64) | C3 |
| 4 | `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound` | `R14/Iwaniec/IwaniecAxiomDecomposition.lean` (line 81) | C4 |
| 5 | `iwaniec_1980_thm_1_tightened_κ_zero` | `R14/Iwaniec/IwaniecAxiomTightened.lean` (line 52) | C5 |

(The audit's C6 was a duplicate cross-reference to C2 — same symbol, same
shape — not a separate file.)

Each of these axioms has conclusion of one of these forms:

- `∃ k l : ℕ, k ≤ 719 ∧ l ≤ 719 ∧ Nat.Prime (m * 2^k * 3^l + 1)`
- `∃ k l, Nat.Prime (V m k l)`
- `∃ a ∈ A, Nat.Prime a` (where `A` is the V-family sieve set)

All three are the EG#203 conjecture itself, modulo trivial bounds.

---

## Related but DISTINCT axiom (not circular, separately problematic)

The file `R14/Iwaniec/IwaniecAxiomNonCircular.lean` (line 57) ships
`iwaniec_linear_sieve_count_bound` — this axiom is structurally NON-circular
(it's a count lower bound, not an existence claim) but the asterisk audit
flagged it as T1 (truth-mismatch / placeholder):

- `mertensProduct z := 1` is a placeholder (real value at z=23 is ≈ 0.164)
- the κ=0 hypothesis is `(∀ q ..., True)` which is vacuously satisfied
- on the V-family `s > 3` makes `f(s) = 0` per the piecewise definition,
 so the conclusion degenerates to `sievedCount ≥ 0`

This file is left WITHOUT a deprecation header because its axiom is the
intended template for the honest count-bound replacement — it just needs
the placeholders filled in with the real Mertens product and the real
κ=0 constraint.

---

## Vacuous axiom flagged in the same files

`R14/Iwaniec/IwaniecAxiomDecomposition.lean` (line 58) also ships
`pappalardi_1995_V_family_sieve_dim_zero`, audit code V1. It claims
`∀ q prime ≥ 5, ∃ d, d ≥ (q-1)/2 ∧ d ∣ (q-1)`. Witness `d := q-1` makes
it trivially true with zero mathematical content. The deprecation header
on `IwaniecAxiomDecomposition.lean` calls this out as well.

---

## Downstream consumers (what imports / references these axioms)

### Consumes `iwaniec_1980_thm_1_V_family_kappa_zero` (C1)

| File | Role |
|---|---|
| `R14/EG203UnconditionalClosure.lean` | THE headline closure — `eg203_closed_unconditional` destructures C1 and repackages. This is the file that exposes the circularity end-to-end. |
| `R14/Iwaniec/IwaniecAxiomNonCircular.lean` | Cross-references C1 in commentary (the "previously circular" framing). |
| `R14/Iwaniec/IwaniecAxiomDecomposition.lean` | Cross-references C1 as the axiom being decomposed. |
| `R14/Iwaniec/EG203CleanComposition.lean` | Cross-references / composes alongside. |
| `R14/Iwaniec/EG203FromTightenedAxioms.lean` | Cross-references. |
| `R14/Iwaniec/EG203FromDecomposedAxioms.lean` | Cross-references. |

### Consumes `iwaniec_v_family_minimal_kappa_zero` (C2)

| File | Role |
|---|---|
| `R14/Iwaniec/IwaniecAxiomMinimal.lean` | Declaration site. |
| `R14/Iwaniec/IwaniecMinimalNumericAxiom.lean` | Cross-references. |
| `R14/Iwaniec/IwaniecAxiomNonCircular.lean` | Cross-references. |
| `R14/VFamily/IwaniecApplication.lean` | Applies to V-family. |
| `R14/Iwaniec/EG203KeystoneFinal.lean` | Composes into keystone. |

### Consumes `iwaniec_v_family_numeric_evaluation` (C3)

| File | Role |
|---|---|
| `R14/Iwaniec/IwaniecMinimalNumericAxiom.lean` | Declaration site. |
| `R14/Iwaniec/IwaniecAxiomNonCircular.lean` | Cross-references. |
| `R14/Iwaniec/EG203NumericKeystone.lean` | Composes into keystone. |

### Consumes `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound` (C4)

| File | Role |
|---|---|
| `R14/Iwaniec/IwaniecAxiomDecomposition.lean` | Declaration site. |
| `R14/Iwaniec/IwaniecAxiomTightened.lean` | Cross-references. |
| `R14/Iwaniec/EG203FromDecomposedAxioms.lean` | Composes via decomposition. |

### Consumes `iwaniec_1980_thm_1_tightened_κ_zero` (C5)

| File | Role |
|---|---|
| `R14/Iwaniec/IwaniecAxiomTightened.lean` | Declaration site. |
| `R14/Iwaniec/EG203CleanComposition.lean` | Composes via tightened path. |
| `R14/Iwaniec/EG203FromTightenedAxioms.lean` | Composes via tightened path. |

---

## Files MARKED with the deprecation header on 2026-06-02

```
EG203Formal/R14/IwaniecLinearSieveVFamily.lean
EG203Formal/R14/Iwaniec/IwaniecAxiomMinimal.lean
EG203Formal/R14/Iwaniec/IwaniecMinimalNumericAxiom.lean
EG203Formal/R14/Iwaniec/IwaniecAxiomDecomposition.lean
EG203Formal/R14/Iwaniec/IwaniecAxiomTightened.lean
```

The header is a Lean line-comment block placed BEFORE the imports. It does
not break compilation — only documents the deprecation.

---

## What this changes

- These five files still build (the axioms still exist, the keystones
 still type-check). The comment is documentation only.
- Anyone reading these files now sees the warning before encountering the
 axiom shape.
- The asterisk audit report at `receipts/R14-2026-06-02/ASTERISK-AUDIT-REPORT.md`
 remains the authoritative source for the line-by-line analysis.

## What this does NOT change

- The `eg203_closed_unconditional` theorem in
 `R14/EG203UnconditionalClosure.lean` still depends on
 `iwaniec_1980_thm_1_V_family_kappa_zero` as confirmed by
 `#print axioms`. The circularity is not removed — it is now flagged.
- The honest closure path (count-bound + count-to-existence composition)
 has not been wired through.

---

## Honest current state

EG#203 closure in R14 is NOT proved. What is proved is that EG#203
follows from an axiom whose conclusion is EG#203. The five files above
are PLACEHOLDER SCAFFOLDING. They must be replaced by a real closure
chain before any external closure claim is made.

The two structurally honest infrastructure axioms in R14 are:

1. `rosser_schoenfeld_1962_theorem_7` in `R14/Mertens/PollackMertens.lean`
 (Mertens product lower bound — CLEAN ✓1)
2. `pappalardi_1995_thm_kappa_V_zero_for_large_primes` in
 `R14/VFamily/Pappalardi.lean` (borderline — statement sensible but
 citation may not support the uniform pointwise form)

Neither is wired into the headline closure.
