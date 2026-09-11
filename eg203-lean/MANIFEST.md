# EG#203 proof package — MANIFEST

This file pins exactly what is included in the shipped ZIP and what is
deliberately excluded. Generated 2026-06-03; if you edit the package
contents, edit this file to match.

## Included

| Path | Contents |
|---|---|
| `README.md` | Package overview + posture + reproduce TL;DR |
| `REPRODUCE.md` | Step-by-step build instructions |
| `MANIFEST.md` | This file |
| `lean-toolchain` | Pins `leanprover/lean4:v4.29.1` |
| `lakefile.toml` | Pins Mathlib `v4.29.1` |
| `flatten-into-place.sh` | One-shot helper to materialize `EG203Formal/` from the per-folder source organization |
| `closure/` | 4 Lean closure files: `EG203AtomicCitations.lean`, `EG203PeerClosure.lean`, `EG203AnalyticDescentScaffold.lean`, `DischargeVFamily.lean` |
| `bounded/` | `EG203BoundedClosure.lean` + `EG203BoundedClosureUpdated.lean` + `EG203DirectPrimeWitness*.lean` (unconditional for m ≤ 10⁶, kernel-verified via `native_decide`) |
| `scale-ladder/` | to 10¹⁹ kernel-verified prime-witness ladder (`EG203HardestM*`, `EG203MegaScale.lean`, ..., `EG203BronnoScale.lean` — 20-digit prime) |
| `source-pinned-540/` | 540-frontier source-pinned uncovered-pair certificates (`EG203BoundedSourcePinned*.lean`) |
| `chain-103/tier-0/` | Tier-0 algebra: `MomentLaws*.lean`, `Size5.lean`, `OrderFacts.lean`, `Persistence.lean`, `TypeIInverseResidue.lean`, `EG203NatZModBridge.lean` |
| `chain-103/R13/` | R13 m-dependent density / Sylow + CRT infrastructure (kernel-verified) |
| `chain-103/R14/` | R14 Buchstab, F(s), V-injectivity, Pappalardi-discharge — kernel-verified only |
| `chain-103/R14/Iwaniec/deprecated/` | Quarantined files that import audit-flagged tightened axioms; excluded from build (see `CIRCULAR-AXIOMS-DEPRECATED.md`) |
| `paper/` | V-family Rosser-Iwaniec preprint TeX (root + 3 inputs) + `README.md` for compile + the compiled `wilder-2026-V-family-rosser-iwaniec.pdf` (25 pages, exit 0 under `pdflatex` two-pass on `texlive/texlive:latest`, 2026-06-03) |
| `docs/` | `EG203-PROOF-SPINE-2026-06-01.md` (historical spine) + `L6_PRODUCTION_ATTACK_2026-06-03.md` (active-frontier finding) |
| `active-frontier/` | L6 attack receipts: `sieve_variance/variance.jsonl`, `summary_1e{9..11}.json`, `D0_OPTIMIZATION_PROD.{md,json}`, `ANALYSIS.md` |

## Excluded (kept separately, available on request)

- Full chain-103 Python kernel scripts (`forge/forge_*`) that generate
  the empirical sweep + the per-m SHA-pinned receipts.
- Per-m JSONL receipts for the full sweep to m ≤ 10¹⁰
  (~3.3B values; not included for size).
- Any historical Lean files audit-flagged as circular (axiom = the
  conjecture). The quarantined sample under `chain-103/R14/Iwaniec/deprecated/`
  is included only as the audit-note pair (the bad file + the audit
  document explaining why it was cut). The other 14 files audit-flagged
  in the same pass were removed outright.
- `.git/`, build artifacts (`.lake/`, `lake-manifest.json`, `*.olean`).

## Layout pre-flatten vs post-flatten

The ZIP ships the per-folder source organization (closure/, bounded/,
scale-ladder/, chain-103/, source-pinned-540/). After running
`bash flatten-into-place.sh` you get a ready-to-build `EG203Formal/`
tree mirroring the source repo. The flatten step preserves the special
mapping `chain-103/tier-0/<name>.lean -> EG203Formal/<name>.lean`
(without the `tier-0/` subdirectory) because tier-0 files self-import
each other as `EG203Formal.MomentLaws` etc.

## Empirical record (canonical, 2026-06-03)

- Every ordinary `m ≤ 10¹⁰` (3,333,333,333 values coprime to 6) tested,
  zero failures.
- Maximum first-prime diagonal `D = 26` attained at `m = 6,257,518,159`
  with witness `(k, ℓ) = (16, 10)`.
- Lean kernel-verified for `m ≤ 10⁶` with `k + ℓ ≤ 13` (and `≤ 12` for
  `m ≤ 5·10⁵`).

## Closure footprint (canonical)

`#print axioms eg203_closed_atomic` (the strongest closure) yields:

```
[propext, Classical.choice, Quot.sound,
 V_family_singular_series_uniform_lower_bound,
 wilder_2026_V_family_rosser_iwaniec]
```

= 3 Mathlib defaults + 2 named mathematical-content axioms = 5 axioms.
Both content axioms are quantitative lower bounds (one singular-series
bound, one prime-count bound); neither is the EG#203 existence
statement itself.

## Singular-series constant disambiguation

- `c_pre = 1/256` — pre-Mertens structural density on `(2520, 5040)`
  (uncovered base density `1/128` from the 2-Sylow argument, times the
  head normalisation `1/2`). Source: `chain-103/` Lean infrastructure.
- `c₀ ≈ 6.6×10⁻⁴` — effective post-Mertens singular-series lower
  bound, `c₀ = c_pre · exp(-2·C_Mertens) ≈ 1/256 · e^{-1.78}`. Source:
  `paper/05-almost-prime-and-constants.tex` §5.
- The Lean axiom `V_family_singular_series_uniform_lower_bound` asserts
  only `∃ c₀ > 0, ...`; the explicit value `c₀ ≈ 6.6×10⁻⁴` is the
  effective witness from the paper's computation.
