# Erdős–Graham #203 — proof package

**The question.** For every integer `m` with `gcd(m, 6) = 1` (an *ordinary* `m`), do there
exist `k, ℓ ≥ 0` with `m · 2^k · 3^ℓ + 1` prime? Posed by Erdős and Graham (1980); open.

**What this package establishes** — every claim is machine-checked or reproducible by a script
included here. Nothing requires trusting the author.

| Claim | Grade | Where |
|---|---|---|
| Every ordinary `m ≤ 10⁶` has an explicit prime witness `(k, ℓ)`, `k+ℓ ≤ 13` | **kernel-checked (Lean 4)** | `bounded/` |
| Explicit kernel-verified prime witnesses up the scale ladder to `10¹⁹` | **kernel-checked** | `scale-ladder/` |
| The covering-system refutation route (the only known way the answer could be NO) is blocked | **exact computation + kernel** | `chain-103/`, `verification/` |
| Exact local law: density of `q | V` cells is `1/lcm(ord_q 2, ord_q 3)` (triggered) else 0 | **exact, cross-implemented** | `verification/lane2-*`, `verification/shield-laneA-*` |
| Pairwise entanglement law; 59-carrier census; exact non-covering certificates (`U₅ < 1` for the densest adversary) | **exact rationals** | `verification/shield-*` |
| All `3.33 × 10⁹` ordinary `m ≤ 10¹⁰` have a prime witness; max diagonal `D = 26` | **computational, SHA-pinned** | empirical receipts |

**Verify.**
```
lake build EG203BoundedClosure               # the m ≤ 10⁶ kernel closure
python verification/shield_laneA.py          # regenerates the entanglement law + certificates
python verification/lane2_per_q_density.py   # regenerates the local law
```
Each `verification/*.py` regenerates the exact numbers quoted on the research page; the `.json`
files are the frozen receipts.

**What is open.** An unconditional proof that a prime always appears. The family has sieve
dimension `κ = 1`, so this sits behind the parity barrier — the same wall as the twin-prime
conjecture. The answer is believed (and overwhelmingly evidenced) to be YES; what is *closed*,
with certificates, is every known route to proving it NO.

## Contents
- `bounded/` — kernel-checked prime witnesses for every ordinary `m ≤ 10⁶`.
- `verification/` — the structural-law campaign: local law, pairwise entanglement law, carrier
  census, covering certificates. Scripts regenerate every number; JSON files are the receipts.
- `chain-103/` — the Sylow / CRT density infrastructure (covering route blocked).
- `scale-ladder/` — explicit kernel-verified witnesses to `10¹⁹`.
- `source-pinned-540/` — 540 source-pinned frontier witnesses.
- `lakefile.toml`, `lean-toolchain` — Lean `v4.29.1` + Mathlib pin.
- `REPRODUCE.md`, `MANIFEST.md` — build / reproduction details.

## References
- P. Erdős, R. L. Graham, *Old and New Problems and Results in Combinatorial Number Theory* (1980), p. 27.
- T. F. Bloom, *Erdős Problems* #203, https://www.erdosproblems.com/203
