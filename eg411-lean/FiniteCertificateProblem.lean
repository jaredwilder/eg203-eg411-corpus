import Mathlib

/-!
# `FiniteCertificateProblem`: a shared abstraction for finite-certificate proof systems

Design doc `ERDŐSFIRE-FERRARI.txt` §9.2 proposes a single interface that both of this
session's finite-certificate proof systems should instantiate:

* the **omega-ladder** (`oracle/data_engine/omega_ladder/codegen.py`), which proves
  `3·φ(n) = 2n + 2` has no solution with exactly `w` distinct prime factors, by
  case-exhausting over prime tuples with every terminal node closed by `native_decide`
  on a concrete, bounded arithmetic fact;
* the **Graham/Alspach rearrangement certificates**
  (`erdosfire/evidence/round4-discovery/graham-z29`, `.../graham-z31`), which prove
  every subset of `ℤ_p \ {0}` in a size range is sequenceable, by exhibiting — for each
  of tens of thousands of canonical orbit representatives — an explicit ordering whose
  partial sums satisfy the Graham/Alspach condition, checked independently by a Go and
  a Python verifier entirely outside Lean.

This file defines the structure as a real, compiling Lean 4 declaration, then
instantiates it twice against **real data pulled from both systems**, not fabricated:
a genuine terminal node of the certified `omega5` kill-tree
(`public/proofs/eg411/omega5_tree.json`, node `P = [5, 7, 37]` — the same node closed
in `OmegaTree5.lean` lines 106-141), and the first genuine certified row of
`erdosfire/evidence/round4-discovery/graham-z29/witnesses.tsv` (canonical representative
`A = {1, …, 21} ⊆ ℤ_29`, mask `0x01fffff`).

No `Base20Conditional.lean` exists yet anywhere under `public/proofs/eg411/` (checked
directly — the directory holds only `CascadeLemma`, `OmegaCapstone`, `OmegaLadder`,
`OmegaTree5/6(_NEW)`, `OmegaTreeSupport`, `RealResult`, `SolutionStructure`), so
`Sequenceable`/`IsSequencing` are defined fresh below, directly from
`erdosfire/round4-paper-graham-z29/main.tex` §"Statement".

See `## 5. Fit assessment` at the end for how well each side actually fits the
interface — short version: clean for Graham, degenerate-but-real for the omega-ladder.
The session report accompanying this file has the full discussion.
-/

namespace EG411Unify

/-! ## 1. The shared structure, as literally proposed by §9.2

Tried verbatim first (no pre-emptive "fix"): `Instance Witness : Type` are ordinary
`Type 0`-valued fields, not `Prop`-valued ones. Lean 4 handles this exactly the way it
handles Mathlib's `Bundled`/category-theoretic "bundled object" structures — the
containing structure is automatically placed one universe up
(`FiniteCertificateProblem : Type 1`). **No manual universe annotation was needed**;
the doc's sketch compiles as written. (What the structure does *not* get for free,
because the doc's sketch never asked for it, is `decode (encode i) = some i` — there is
no such field. See the fit assessment.) -/

/-- A finite-certificate problem: a checkable relation between instances and witnesses,
whose checker is sound for a target proposition. -/
structure FiniteCertificateProblem where
  Instance    : Type
  Witness     : Type
  encode      : Instance → ByteArray
  decode      : ByteArray → Option Instance
  check       : Instance → Witness → Bool
  proposition : Instance → Prop
  check_sound : ∀ i w, check i w = true → proposition i

/-! ## 2. Shared byte-serialization helpers

Neither instantiation below needs anything fancier than "a list of naturals" on the
wire, so one pair of helpers covers both. -/

/-- Encode a list of naturals as comma-separated decimal, UTF-8 bytes. -/
def encodeNatList (l : List ℕ) : ByteArray :=
  (String.intercalate "," (l.map toString)).toUTF8

/-- Decode the inverse of `encodeNatList`. -/
def decodeNatList (b : ByteArray) : Option (List ℕ) := do
  let s ← String.fromUTF8? b
  if s = "" then some [] else (s.splitOn ",").mapM String.toNat?

set_option linter.style.nativeDecide false

/-! ## 3. Instantiation A — the omega-ladder's terminal-check shape -/

/-- The numeric data a single omega-ladder terminal node depends on, once its prime
prefix has been pinned by the ancestor `fin_cases` chain (`codegen.py`,
`_Codegen.emit_terminal`): the algebraic coefficients `A, B` from `heq_sides` (so the
node's equation reads `A · (s−1)(t−1) = B · s·t + 2`), the search window `(lo, hi]` that
`terminal_bound` certifies the remaining free prime `s` must lie in, and the
already-excluded prime divisors `priors` (the ancestor chain) feeding the
`¬ p ∣ (v − 1)` conjuncts of `filter_pred`. -/
structure OmegaTerminalInstance where
  A      : ℕ
  B      : ℕ
  lo     : ℕ
  hi     : ℕ
  priors : List ℕ

/-- The exact decidable predicate `codegen.py`'s `filter_pred` emits at a terminal
node's "high" branch (`A < (A−B)·v`, where `terminal_formula` pins `t` to the exact
quotient `M / D`) — the same shape as the generated code in `OmegaTree5.lean` lines
120-140, with `A`/`B`/`priors` as instance data instead of hardcoded literals.

`abbrev`, not `def`: a plain `def` here made `Finset.filter`'s `DecidablePred` search
fail (`failed to synthesize instance ... DecidablePred fun v => omegaNodePred i v`) —
instance search does not unfold ordinary (non-reducible) `def`s to find the `Decidable`
instance hiding underneath a conjunction. `abbrev` (`@[reducible] def`) fixes it; this
was found empirically by actually running `lean-verify.ts`, not assumed. -/
abbrev omegaNodePred (i : OmegaTerminalInstance) (v : ℕ) : Prop :=
  Nat.Prime v ∧
  (∀ p ∈ i.priors, ¬ p ∣ (v - 1)) ∧
  ((i.A - i.B) * v - i.A) ∣ (i.A * v - i.A + 2) ∧
  Nat.Prime ((i.A * v - i.A + 2) / ((i.A - i.B) * v - i.A)) ∧
  v < (i.A * v - i.A + 2) / ((i.A - i.B) * v - i.A)

/-- `check`: exactly the one `native_decide` fact `emit_terminal` emits — the candidate
set over the certified window is empty. `Witness` degenerates to `Unit`: there is
nothing for a caller to *supply*, the "certificate" is a closed decision-procedure
result. See the fit assessment for why this is the honest modeling choice, not a
shortcut. -/
def omegaCheck (i : OmegaTerminalInstance) (_ : Unit) : Bool :=
  decide ((Finset.Ioc i.lo i.hi).filter (fun v => omegaNodePred i v) = ∅)

/-- `proposition`: "no `v` in the certified window satisfies the node predicate" — the
mathematical content that makes the terminal node a dead end. -/
def omegaProposition (i : OmegaTerminalInstance) : Prop :=
  ∀ v ∈ Finset.Ioc i.lo i.hi, ¬ omegaNodePred i v

theorem omega_check_sound (i : OmegaTerminalInstance) (w : Unit)
    (h : omegaCheck i w = true) : omegaProposition i := by
  have he : (Finset.Ioc i.lo i.hi).filter (fun v => omegaNodePred i v) = ∅ :=
    of_decide_eq_true h
  intro v hv hpv
  have hmem : v ∈ (Finset.Ioc i.lo i.hi).filter (fun v => omegaNodePred i v) :=
    Finset.mem_filter.mpr ⟨hv, hpv⟩
  rw [he] at hmem
  exact absurd hmem (Finset.notMem_empty v)

/-- **Real data**: the genuine terminal node `P = [5, 7, 37]` of the certified
`omega5` kill-tree (`public/proofs/eg411/omega5_tree.json`), with
`A = 2592 = 3·4·6·36`, `B = 2590 = 2·5·7·37`, certified window `(37, 2593]` — the exact
node `OmegaTree5.lean` closes at lines 106-141. -/
def omegaDemoInstance : OmegaTerminalInstance :=
  { A := 2592, B := 2590, lo := 37, hi := 2593, priors := [5, 7, 37] }

theorem omegaDemo_check : omegaCheck omegaDemoInstance () = true := by
  native_decide

theorem omegaDemo_proposition : omegaProposition omegaDemoInstance :=
  omega_check_sound omegaDemoInstance () omegaDemo_check

-- Axiom footprint, disclosed exactly as `RealResult.lean` does for its own
-- `native_decide` facts: `omega_check_sound` itself is fully axiom-free (pure logic
-- over an already-computed `Bool`); the concrete demo pulls in the standard
-- `native_decide` compiler-trust axiom because it actually runs the decision procedure.
#print axioms omega_check_sound
#print axioms omegaDemo_check
#print axioms omegaDemo_proposition

/-- One concrete round-trip through the shared byte codec, on the real demo instance
(the structure does not require this in general — see the fit assessment — but it
really does hold here). -/
example : decodeNatList (encodeNatList
    ([omegaDemoInstance.A, omegaDemoInstance.B, omegaDemoInstance.lo, omegaDemoInstance.hi]
      ++ omegaDemoInstance.priors))
    = some [2592, 2590, 37, 2593, 5, 7, 37] := by native_decide

/-- The omega-ladder terminal-check shape, bundled as a `FiniteCertificateProblem`. -/
def omegaLadderFCP : FiniteCertificateProblem where
  Instance := OmegaTerminalInstance
  Witness := Unit
  encode := fun i => encodeNatList ([i.A, i.B, i.lo, i.hi] ++ i.priors)
  decode := fun b => (decodeNatList b).bind fun l =>
    match l with
    | A :: B :: lo :: hi :: priors => some { A, B, lo, hi, priors }
    | _ => none
  check := omegaCheck
  proposition := omegaProposition
  check_sound := omega_check_sound

/-! ## 4. Instantiation B — the Graham witness-check shape -/

/-- Running partial sums of `l`, starting from `acc` (helper for `partialSums`, kept
recursive and self-contained rather than reaching for `List.scanl`'s exact stdlib
signature). -/
def partialSumsFrom {G : Type} [Add G] : G → List G → List G
  | _, [] => []
  | acc, a :: rest => (acc + a) :: partialSumsFrom (acc + a) rest

/-- `partialSums [a₁, …, aₘ] = [a₁, a₁+a₂, …, a₁+⋯+aₘ] = [s₁, …, sₘ]`. -/
def partialSums {G : Type} [Add G] [Zero G] (l : List G) : List G :=
  partialSumsFrom 0 l

/-- `l` sequences the finite subset `A` of an abelian group: it uses every element of
`A` exactly once, and its partial sums `s₁, …, sₘ` are pairwise distinct with `sᵢ ≠ 0`
for `1 ≤ i < m` (`main.tex` §"Statement", verbatim).

`abbrev`, not `def` — same reducibility reason as `omegaNodePred` above: `checkOrdering`
wraps this in `decide`, which needs the `Decidable` instance search to see through the
definition. -/
abbrev IsSequencing {G : Type} [AddCommGroup G] [DecidableEq G]
    (A : Finset G) (l : List G) : Prop :=
  l.Nodup ∧ l.toFinset = A ∧
    (0 : G) ∉ (partialSums l).dropLast ∧ (partialSums l).Nodup

/-- `A` is sequenceable: some ordering of it is a sequencing. -/
def Sequenceable {G : Type} [AddCommGroup G] [DecidableEq G] (A : Finset G) : Prop :=
  ∃ l, IsSequencing A l

/-- Decode a 28-bit orbit-representative mask (`graham-z29/witnesses.tsv`'s `mask`
column) into the subset of `ℤ_29` it encodes: bit `k` set ↔ residue `k + 1` present. -/
def maskToFinsetZ29 (mask : ℕ) : Finset (ZMod 29) :=
  ((Finset.range 28).filter (fun k => mask.testBit k = true)).image
    (fun k => ((k + 1 : ℕ) : ZMod 29))

/-- `check`: exactly what the independent Go verifier's `validateOrdering` computes
(`erdosfire/oracle/tools/frontier-math/round4/graham-z29/verify_witnesses.source.go`,
lines 96-120) — the witness `l` (read as residues mod 29) really is a sequencing of the
subset `mask` encodes. -/
def checkOrdering (mask : ℕ) (l : List ℕ) : Bool :=
  decide (IsSequencing (maskToFinsetZ29 mask) (l.map (fun a => (a : ZMod 29))))

/-- `proposition`: the mask's subset is sequenceable. -/
def grahamProposition (mask : ℕ) : Prop := Sequenceable (maskToFinsetZ29 mask)

theorem graham_check_sound (mask : ℕ) (l : List ℕ)
    (h : checkOrdering mask l = true) : grahamProposition mask :=
  ⟨_, of_decide_eq_true h⟩

/-- **Real data**: row 1 of the genuine, certified
`erdosfire/evidence/round4-discovery/graham-z29/witnesses.tsv` — the canonical orbit
representative `A = {1, …, 21} ⊆ ℤ_29` (mask `0x01fffff = 2²¹ − 1`, `total ≡ 28
(mod 29)` matching `1+⋯+21 = 231 ≡ 28`) and its certified ordering. -/
def grahamDemoMask : ℕ := 0x01fffff

def grahamDemoOrdering : List ℕ :=
  [5, 2, 7, 17, 4, 6, 18, 15, 21, 1, 14, 19, 11, 3, 13, 9, 12, 16, 20, 8, 10]

theorem grahamDemo_check : checkOrdering grahamDemoMask grahamDemoOrdering = true := by
  native_decide

theorem grahamDemo_sequenceable : grahamProposition grahamDemoMask :=
  graham_check_sound grahamDemoMask grahamDemoOrdering grahamDemo_check

#print axioms graham_check_sound
#print axioms grahamDemo_check
#print axioms grahamDemo_sequenceable

/-- The Graham witness-check shape, bundled as a `FiniteCertificateProblem`. -/
def grahamFCP : FiniteCertificateProblem where
  Instance := ℕ
  Witness := List ℕ
  encode := fun mask => encodeNatList [mask]
  decode := fun b => (decodeNatList b).bind fun l => l.head?
  check := checkOrdering
  proposition := grahamProposition
  check_sound := graham_check_sound

/-! ## 5. Fit assessment (short version — full discussion in the session report)

**Graham fits naturally.** `Witness` carries real information (a candidate ordering
that could be wrong); `check` does the same per-candidate verification work as the
independent Go/Python checkers; `proposition` is the natural `∃`-statement
`check_sound` was built for. Textbook NP-certificate shape.

**The omega-ladder fits, but only by degenerating `Witness` to `Unit`.** A terminal
kill is a *refutation* ("no `v` in this window works"), verified by one closed
`native_decide` call with no external input — there is nothing for a caller to
*supply*. Forcing it through the same `Instance → Witness → Bool` shape either
(a) makes `Witness` informationally empty (`Unit`, as done here), or (b) reintroduces
an existential shape by making the "witness" a claimed enumeration of survivors
(workable for *branch* nodes, whose `native_decide` really does check a claimed
literal `Finset` for equality against the true filtered set — but degenerate again for
*terminal* nodes specifically, whose claimed set is always `∅`, i.e. still no real
per-witness content). Either way, `check_sound` on this side is barely more than
`of_decide_eq_true` wrapped in a `Finset.filter_eq_empty_iff`-shaped rewrite — none of
Graham's "verify a specific external claim against the instance" content survives. The
interface **compiles for both**, but only actually earns its keep — a cheap check
standing in for an expensive search — on the Graham side.
-/

end EG411Unify
