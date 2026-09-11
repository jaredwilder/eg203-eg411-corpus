# LANE C SUMMARY — fresh-data prediction tests (2026-06-10)

Doctrine: `UNIVERSAL_LAW/PROCESS-GOLD-2026-06-10.md`. Everything below was executed
tonight from scratch (fresh seeds, fresh m, fresh boxes); every load-bearing count is
cross-implemented; nothing reuses prior session outputs except the *conventions* being
tested (lane4 F3 formula, reproduced and re-derived).

## Receipts

| file | what it certifies |
|---|---|
| shield-laneC-0-carriers.{json,md} | 59 carriers ≤ 10^6 (exact census, 2 independent routes + 2 more cross-checks) |
| shield-laneC-orders-cache.npz | (q, d2, d3, H) for all 78,496 primes 3 < q ≤ 10^6 |
| shield-laneC-1-diagonal-law.{json,md} | D(m) at 10^6/10^9/10^12/10^15 (128 m) + 50,000-m mass sweep |
| shield-laneC-2-cbh-fresh-boxes.{json,md} | 10 fresh (m,D) boxes, exact π_V, BH ratios, drift |
| shield-laneC-2-recount-xcheck.json | independent pure-sympy full recounts of 3 boxes |
| shield-laneC-3-survivor-density.{json,md} | 200 m exact survivor fractions on 2520×5040 |
| shield-laneC-3b-pairwise-E.json | 843 exact pairwise joint densities vs lattice algebra |
| shield_laneC_{common,task1,task2,task3,task3b}.py | reproduce-by-a-stranger scripts (seeded) |

## The three lane questions, answered

**C1 — diagonal law.** The renormalized-BH waiting-time model
P(D(m) > D) = exp(−3·C_BH(m)·Σ_{cells≤D} 1/log V) is statistically indistinguishable
from 128 fresh m across 9 decades (randomized-PIT KS p = 0.53 avg / 0.34 sieve-refined).
Typical D grows like **sqrt(log m)** (observed growth 1.68 from 10^6→10^15 vs sqrt-law
1.58; a linear-in-log-m law predicts 2.50 — refuted for typical D). 50,000-m sweep:
max D = 16 at m = 1,619,311, landing at the model's 21% quantile; **0/50,128 fresh m
violate the envelope D ≤ 2·log m/log 3** (which is loose by ~e^29 at these sample sizes).

**C2 — C_BH at fresh boxes.** 10 fresh boxes (prior m excluded; D = 120/150 never used
before): ratios actual/predicted 0.946–1.153, mean 1.040. **The blanket "±12% on every
box" phrasing fails out of sample (8/10)** — but the two violators are Z = +2.08/+2.28
Poisson fluctuations at π_V ≈ 250 where ±12% is only a 1.9σ band. The surviving honest
law: **π̂ = 3·C_BH·Σ1/log V predicts fresh boxes to within Poisson noise with zero free
parameters** (max |Z| = 2.28; pooled +3.5% at 2.0σ — flagged OPEN, watch). No drift
with D up to 150. π_V counts exact, dual-engine, independently recounted (3/3 match).

**C3 — survivor-density law.** REFUTES the "entanglement helps survivors" surplus:
ratio actual/independence has mean 1.0005, geomean 0.9998, with 106/200 m BELOW
independence (range 0.914–1.147). The pairwise mechanism is nonetheless real and
EXACT: joint density = 0 or E/(H1·H2) with E = [Z²:Λ1+Λ2], verified 843/843 with two
independent implementations, E ∈ {1:590, 2:106, 3:20, 4:8, 6:1, 8:1}, zeros (117) only
at E ≥ 2. The shield's actual shape: a fat independence floor (min sampled survivor
fraction 0.2343 even at Σ1/H = 1.376) plus a signed, mean-zero, ±15%-bounded
entanglement modulation. All 200 m have survivors.

## What changed tonight

- The "entanglement shield = survivors get a boost" story is dead as a proof route
  (no surplus exists on average). What replaces it: the union stays below 1 because
  Σ1/H stays small (carriers are scarce: exactly 59 below 10^6) and the entanglement
  correction is bounded both ways. Bounding that correction (via the E-dichotomy,
  which is exact and formalizable) is the new, sharper target.
- ±12% was never a guarantee, only a Poisson-noise-limited fit. State it as
  "within Poisson noise, zero free parameters" from now on.
- D(m) prediction machinery is quantitatively trustworthy (KS-clean at n=128,
  record-tail calibrated at n=50k) — usable to schedule future deep sweeps.
