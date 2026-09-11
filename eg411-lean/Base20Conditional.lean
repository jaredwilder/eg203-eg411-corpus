import Mathlib.Data.Finset.Card
import Mathlib.Algebra.BigOperators.Group.List.Defs

/-!
# Graham/Alspach rearrangement conjecture — base case `|A| ≤ 20` (external dependency)

============================================================
EXTERNAL DEPENDENCY
NOT FORMALIZED IN THIS REPOSITORY
DO NOT IMPORT FROM UNCONDITIONAL TARGETS
============================================================

**Citation.** S. Costa, S. Della Fiore, M. Fontana, and L. Vena,
*"Graham conjecture on small sets in abelian groups,"* arXiv:2603.20961 [math.CO], 2026.

This file declares, as an explicit project-local Lean `axiom`, a single published theorem from
the paper above: every subset of an abelian group of cardinality at most `20` that avoids `0`
is sequenceable. That theorem has **not** been formalized in Lean anywhere in this repository
(nor, as far as this session is aware, anywhere else) — we take it as an assumption, the same
way `EG411RealResult.TotientConjecture` takes Steinerberger's conjecture as an explicit,
named, non-axiomatic hypothesis threaded through a theorem's binders. The difference here is
that the `|A| ≤ 20` case is meant to be composed automatically into any downstream file that
proves the `Z_29`/`Z_31` "combine the axiom with the certified `21 ≤ |A| ≤ 28` (`Z_29`) /
`21 ≤ |A| ≤ 30` (`Z_31`) computational witnesses" closure theorem described in
`erdosfire/round4-paper-graham-z29/main.tex` ("Proof of the theorem"), so a project-local
`axiom` — rather than a hypothesis argument threaded through every downstream theorem — is the
right tool: it lets the dependency travel silently through the type system while remaining
100% visible to `#print axioms`.

**Why an axiom, not a theorem.** The result is real, published, peer-reviewed mathematics. It
is not proved here because formalizing it is out of scope for this file (and, at the time of
writing, has not been attempted by anyone in this repository). Declaring it a `sorry` would be
just as honest about *that one theorem*, but a `sorry` does not propagate a distinct, greppable
name through `#print axioms` the way a named `axiom` does — Lean reports bare `sorry`s as the
generic `sorryAx`, which is easy to lose track of across a large file. A named axiom is the
more disciplined choice for a dependency that other files are expected to build on.

**The isolation contract.** Every *unconditional* target in this repository's `EG411` library
must report an axiom footprint of exactly `{propext, Classical.choice, Quot.sound}` (optionally
plus `native_decide`'s `Lean.ofReduceBool`) — nothing else. If `base_sequenceable_upto_20` ever
appears in an unconditional target's `#print axioms` output, that target has silently become
conditional on an unformalized external result and MUST be relabeled — exactly the discipline
`public/proofs/eg411/RETRACTION.md` and `EG411RealResult.eg411_r2_conditional_closure` already
enforce for Steinerberger's conjecture. `oracle/scripts/lean-axiom-check.ts` treats any axiom
beyond that expected set as `UNEXPECTED` (nonzero exit) precisely so this cannot pass unnoticed
— see that script's comment referencing "the exact RETRACTION.md failure mode."

**Scope of this file.** Deliberately narrow: it defines `Sequenceable` (matching
`erdosfire/round4-paper-graham-z29/main.tex` §1 "Statement" verbatim) and the single conditional
axiom below. It does **not** attempt the `Z_29`/`Z_31` closure theorem that combines this axiom
with the certified computational witnesses (main.tex §"Proof of the theorem" / campaign
"§7.2–7.3") — that depends on a certificate checker that is separate, not-yet-existing work.
-/

/-! ## `Sequenceable`

Formalizes `erdosfire/round4-paper-graham-z29/main.tex` §1 ("Statement"), verbatim:

> "For a finite subset `A` of an abelian group, call an ordering `a_1,…,a_m` a sequencing when
> the partial sums `s_i = Σ_{j=1}^i a_j` are pairwise distinct and `s_i ≠ 0` for `1 ≤ i < m`."

An "ordering `a_1,…,a_m` of `A`" is represented as a `List G` `l` with no repeated entries
(`l.Nodup`) whose set of entries is exactly `A` (`∀ x, x ∈ l ↔ x ∈ A`); together these force
`l.length = A.card = m` and make `l` literally the sequence `a_1, …, a_m`. Deliberately stated
without `List.toFinset` / `DecidableEq G`: the axiom below assumes only `[AddCommGroup G]`, so
`Sequenceable` must typecheck and mean the right thing for a fully general abelian group with
no decidable-equality assumption. -/

/-- The `i`-th partial sum of an ordering `l` (1-indexed): `s_i = a_1 + a_2 + ⋯ + a_i`, the sum
of the first `i` entries of `l`. `partialSum l 0 = 0` (the empty sum) is never used below — the
paper's indices always start at `1`. -/
def partialSum {G : Type*} [AddCommGroup G] (l : List G) (i : ℕ) : G :=
  (l.take i).sum

/-- `l` is a sequencing of the finite set `S`: `l` enumerates exactly the elements of `S`, each
once (`l.Nodup` and `∀ x, x ∈ l ↔ x ∈ S`), its partial sums `s_1, …, s_m` (`m = l.length`) are
pairwise distinct, and every partial sum before the last — `s_i` for `1 ≤ i < m` — is nonzero. -/
def IsSequencing {G : Type*} [AddCommGroup G] (S : Finset G) (l : List G) : Prop :=
  l.Nodup ∧ (∀ x, x ∈ l ↔ x ∈ S) ∧
    (∀ i j, 1 ≤ i → i ≤ l.length → 1 ≤ j → j ≤ l.length →
      partialSum l i = partialSum l j → i = j) ∧
    (∀ i, 1 ≤ i → i < l.length → partialSum l i ≠ 0)

/-- `S` is sequenceable: some ordering of `S` witnesses `IsSequencing`. This is the Lean
formalization of "sequenceable" as used by the Graham/Alspach rearrangement conjecture and by
`erdosfire/round4-paper-graham-z29/main.tex` (whose Theorem states: "Every subset
`A ⊆ Z_29 \ {0}` is sequenceable.", proved there for `21 ≤ |A| ≤ 28` by an explicit certificate
and for `|A| ≤ 20` by direct appeal to the axiom below). -/
def Sequenceable {G : Type*} [AddCommGroup G] (S : Finset G) : Prop :=
  ∃ l : List G, IsSequencing S l

/-!
============================================================
EXTERNAL DEPENDENCY
NOT FORMALIZED IN THIS REPOSITORY
DO NOT IMPORT FROM UNCONDITIONAL TARGETS
============================================================

S. Costa, S. Della Fiore, M. Fontana, and L. Vena, "Graham conjecture on small sets in abelian
groups," arXiv:2603.20961 [math.CO], 2026.

Encodes that published (peer-reviewed, not-yet-formalized-in-Lean) theorem's exact content:
every subset of an abelian group with at most `20` elements that avoids `0` is sequenceable. No
proof of this axiom exists in this repository. Any theorem — in this file or in a file that
imports it — that uses this axiom becomes CONDITIONAL, and `#print axioms` on that theorem MUST
list `base_sequenceable_upto_20` explicitly. Do not discharge, `sorry`, or otherwise attempt to
prove this axiom locally; do not reference it from any target this repository calls
"unconditional."
-/
axiom base_sequenceable_upto_20
    {G : Type*}
    [AddCommGroup G]
    (S : Finset G)
    (h0 : 0 ∉ S)
    (hcard : S.card ≤ 20) :
    Sequenceable S
