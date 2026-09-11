# Reproducing the EG#203 closure

## Prerequisites

- Lean 4 toolchain: `leanprover/lean4:v4.29.1`
- Mathlib pinned to `v4.29.1` (declared in `lakefile.toml`)
- `lake` package manager (ships with Lean 4)
- Optional: `pdflatex` (MiKTeX or TeX Live) if you want to compile the paper

Install Lean 4 + lake with `elan`:

```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
# After install, in this directory:
elan toolchain install leanprover/lean4:v4.29.1
elan override set leanprover/lean4:v4.29.1
```

The `lean-toolchain` file in this package pins the version automatically.

## Project layout

This package ships the Lean files in a flat-per-section layout. To
reproduce the kernel-checked builds, place them under an `EG203Formal/`
namespace mirroring the source repo:

```
your-project/
├── lakefile.toml (provided)
├── lean-toolchain (provided)
└── EG203Formal/ (you create — copy files in here)
 ├── EG203AtomicCitations.lean ← from this package's closure/
 ├── EG203PeerClosure.lean ← from closure/
 ├── EG203BoundedClosure.lean ← from bounded/
 ├── EG203BoundedClosureUpdated.lean ← from bounded/
 ├── EG203DirectPrimeWitness*.lean ← from bounded/
 ├── EG203HardestM*.lean ← from scale-ladder/
 ├── EG203MegaScale.lean … EG203BronnoScale.lean ← from scale-ladder/
 ├── EG203BoundedSourcePinned*.lean ← from source-pinned-540/
 ├── MomentLaws*.lean Size5.lean OrderFacts.lean Persistence.lean
 │ TypeIInverseResidue.lean EG203NatZModBridge.lean
 │ EG203AnalyticDescentScaffold.lean ← from chain-103/tier-0/ + closure/
 ├── R12Test/
 │ └── DischargeVFamily.lean ← from closure/
 ├── R13/
 │ └── *.lean ← from chain-103/R13/
 └── R14/
 ├── *.lean ← from chain-103/R14/
 ├── Iwaniec/*.lean ← from chain-103/R14/Iwaniec/
 ├── Mertens/*.lean ← from chain-103/R14/Mertens/
 └── VFamily/*.lean ← from chain-103/R14/VFamily/
```

A `flatten-into-place.sh` helper is one-liner:

```bash
mkdir -p EG203Formal/R12Test EG203Formal/R13 EG203Formal/R14/Iwaniec \
 EG203Formal/R14/Mertens EG203Formal/R14/VFamily
cp closure/EG203AtomicCitations.lean closure/EG203PeerClosure.lean \
 closure/EG203AnalyticDescentScaffold.lean EG203Formal/
cp closure/DischargeVFamily.lean EG203Formal/R12Test/
cp bounded/*.lean EG203Formal/
cp scale-ladder/*.lean EG203Formal/
cp source-pinned-540/*.lean EG203Formal/
cp chain-103/tier-0/*.lean EG203Formal/
cp chain-103/R13/*.lean EG203Formal/R13/
cp chain-103/R14/*.lean EG203Formal/R14/ 2>/dev/null || true
cp chain-103/R14/Iwaniec/*.lean EG203Formal/R14/Iwaniec/
cp chain-103/R14/Mertens/*.lean EG203Formal/R14/Mertens/
cp chain-103/R14/VFamily/*.lean EG203Formal/R14/VFamily/
```

## Build the canonical (atomic-citations) closure

```bash
lake update # fetches Mathlib v4.29.1
lake build EG203Formal.EG203AtomicCitations
# Expected: exit 0
```

Verify the axiom footprint (5 axioms total):

```bash
echo "#print axioms eg203_closed_atomic" >> EG203Formal/EG203AtomicCitations.lean
lake env lean EG203Formal/EG203AtomicCitations.lean
# Expected: 'eg203_closed_atomic' depends on axioms:
# [propext, Classical.choice, Quot.sound,
# V_family_singular_series_uniform_lower_bound,
# wilder_2026_V_family_rosser_iwaniec]
```

## Build the peer closure (single composite axiom, 4-axiom footprint)

```bash
lake build EG203Formal.EG203PeerClosure
# Expected: exit 0
# #print axioms eg203_closed_peer →
# [propext, Classical.choice, Quot.sound, eg203_analytic_NT_input]
```

## Build the bounded closure (unconditional)

```bash
lake build EG203Formal.EG203BoundedClosure
# Expected: exit 0
# Theorem: EG203_nat_form_for_ordinary_m_up_to_1000000
# Footprint: [propext, Classical.choice, Quot.sound, <native_decide ax>]
```

`native_decide` evaluates a kernel-checkable proof against compiled C
code. It introduces one per-call-site certificate axiom (named
`<decl>._native.native_decide.ax_1_1` in Lean v4.29.1) covering the
trusted compiler path.

## Verify the scale ladder

```bash
lake build EG203Formal.EG203BronnoScale
# Expected: exit 0
# Theorem: 20-digit prime witness Nat.Prime 20000000105788936187
```

Other ladder rungs:

```bash
lake build EG203Formal.EG203HardestM # 4-digit (10⁰ range)
lake build EG203Formal.EG203HardestM2 # higher rung
lake build EG203Formal.EG203MegaScale # 10¹⁰ – 10¹²
lake build EG203Formal.EG203PetaScale # 10¹³ – 10¹⁴
lake build EG203Formal.EG203TeraScale # 10¹⁵
lake build EG203Formal.EG203ExaScale # 10¹⁶
lake build EG203Formal.EG203ZettaScale # 10¹⁷
lake build EG203Formal.EG203YottaScale # 10¹⁸
lake build EG203Formal.EG203BronnoScale # 10¹⁹ (20-digit)
```

## Verify the 540 source-pinned frontier

```bash
lake build EG203Formal.EG203BoundedSourcePinned
lake build EG203Formal.EG203BoundedSourcePinnedExtended
# Expected: exit 0 (~38s for Extended)
```

## Verify Chain 103 infrastructure (R13 / R14)

R13 (18 files, m-dependent density, kernel-verified):

```bash
lake build EG203Formal.R13.Chain103Correct
lake build EG203Formal.R13.Chain103JointBoundNativeDecide
# ...etc. for all R13/*.lean
```

R14 supporting infrastructure (Buchstab, f(s), V injectivity,
Pappalardi discharge — only the kernel-verified files are shipped):

```bash
lake build EG203Formal.R14.Iwaniec.BuchstabIdentity
lake build EG203Formal.R14.Iwaniec.BuchstabApplied
lake build EG203Formal.R14.Iwaniec.FFunction
lake build EG203Formal.R14.Iwaniec.FSieveWeight
lake build EG203Formal.R14.Iwaniec.FMonotonicityExtension
lake build EG203Formal.R14.Iwaniec.RosserWeights
lake build EG203Formal.R14.Iwaniec.SieveSet
lake build EG203Formal.R14.Iwaniec.AbstractSieveLowerBound
lake build EG203Formal.R14.Iwaniec.IwaniecAxiomNonCircular
lake build EG203Formal.R14.Iwaniec.PappalardiDischargeFinite
# NOTE: R14.Iwaniec.PappalardiHypothesisDischarge moved to
# chain-103/R14/Iwaniec/deprecated/ (imports a deliberately-excluded
# tightened-axiom file). Excluded from the build.
lake build EG203Formal.R14.Mertens.ChebyshevTheta
lake build EG203Formal.R14.Mertens.PartialSummation
lake build EG203Formal.R14.Mertens.PollackMertens
lake build EG203Formal.R14.VFamily.Pappalardi
lake build EG203Formal.R14.VFamily.SieveSetSize
lake build EG203Formal.R14.VFamily.NumericalEvaluation
lake build EG203Formal.R14.VFamily.NumericalEvaluationAxioms
# All clean ones: exit 0
```

## Compile the V-family Rosser-Iwaniec paper (optional)

```bash
cd paper/
pdflatex wilder-2026-V-family-rosser-iwaniec.tex
pdflatex wilder-2026-V-family-rosser-iwaniec.tex # second pass for refs
# Produces: wilder-2026-V-family-rosser-iwaniec.pdf
```

## What to expect

| Target | Expected exit | Notes |
|---|---|---|
| `EG203AtomicCitations` | 0 | The 5-axiom strongest closure |
| `EG203PeerClosure` | 0 | The 4-axiom peer-shape closure |
| `EG203BoundedClosure` | 0 | Unconditional for m ≤ 10⁶ |
| `EG203BronnoScale` | 0 | 20-digit prime witness |
| `EG203BoundedSourcePinnedExtended` | 0 (~38s) | 540 frontier |
| `R13/*` | 0 | Kernel-verified |
| `R14/Iwaniec/*` (shipped subset) | 0 | Kernel-verified (15 circular/deprecated files cut) |

If any build returns non-zero exit, please file an issue with the
build log (this package may have version-skew issues against newer
Mathlib snapshots).

---

## Honesty note

The five files audit-flagged as circular (axiom = the conjecture)
in R14 — specifically `IwaniecLinearSieveVFamily.lean`,
`Iwaniec/IwaniecAxiomMinimal.lean`, `Iwaniec/IwaniecMinimalNumericAxiom.lean`,
`Iwaniec/IwaniecAxiomDecomposition.lean`, `Iwaniec/IwaniecAxiomTightened.lean` —
plus the 10 downstream files that consume them are **deliberately
excluded from this package**. See
`chain-103/R14/Iwaniec/deprecated/CIRCULAR-AXIOMS-DEPRECATED.md` for the audit
inventory. (One quarantined sample ships under
`chain-103/R14/Iwaniec/deprecated/` as the audit-note pair — the bad
file plus the audit document — per `MANIFEST.md`.)
