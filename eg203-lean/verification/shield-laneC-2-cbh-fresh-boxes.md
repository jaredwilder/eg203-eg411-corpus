# Lane C receipt 2 — C_BH at 10 FRESH boxes (out-of-sample test of the ±12% law)

Date: 2026-06-10. Script: `shield_laneC_task2.py` (seed 20260612).
JSON: `shield-laneC-2-cbh-fresh-boxes.json`, recount cross-check in
`shield-laneC-2-recount-xcheck.json`.

## Freshness

The prior 15-box result (lane4 F3) used m ∈ {5, 35, 65, 95, 115} — all EXCLUDED here.
Fresh seeded boxes: (149,120), (139,120), (73,120), (49,120), (109,150), (59,150),
(71,150), (14681,100), (15907,100), (18947,100). D ∈ {120,150} were never used before
(prior used D ≤ 100).

## Method (exact integers)

- π_V(m,D) counted exactly over all cells k+l ≤ D: composites certified by
  gcd(V, primorial(10^5)) > 1 where applicable; every surviving cell decided by BOTH
  gmpy2.is_prime(V,25) AND sympy BPSW with agreement asserted (10/10 boxes: zero
  disagreements across all dual-tested cells).
- **Cross-implementation (PROCESS-GOLD §3):** three boxes — including BOTH ±12%
  violators — fully recounted by an independent pure-sympy loop with no gcd sieve and
  no gmpy2: m=15907 D=100 → 257, m=14681 D=100 → 249, m=149 D=120 → 278. **Exact match.**
- Prediction (lane4 F3 convention, zero free parameters):
  π̂ = 3·C_BH(m)·Σ_{2∤V,3∤V} 1/log V, with C_BH = Π_{3<q≤P} f_q.

## Results

| m | D | π_V | π̂ (P=10^6) | ratio | ratio (carriers-only ≤10^5) | ratio (sieve-refined) | Poisson Z |
|---|---|---|---|---|---|---|---|
| 149   | 120 | 278 | 293.8 | 0.946 | 0.954 | 0.941 | −0.92 |
| 139   | 120 | 304 | 315.7 | 0.963 | 0.961 | 0.957 | −0.66 |
| 73    | 120 | 352 | 328.8 | 1.071 | 1.078 | 1.057 | +1.28 |
| 49    | 120 | 411 | 413.8 | 0.993 | 1.015 | 1.029 | −0.14 |
| 109   | 150 | 375 | 373.1 | 1.005 | 1.009 | 0.998 | +0.10 |
| 59    | 150 | 484 | 442.1 | 1.095 | 1.120 | 1.021 | +1.99 |
| 71    | 150 | 445 | 428.8 | 1.038 | 1.035 | 1.028 | +0.78 |
| 14681 | 100 | 249 | 218.3 | **1.141** | 1.128 | 1.032 | +2.08 |
| 15907 | 100 | 257 | 223.0 | **1.153** | 1.162 | **1.136** | +2.28 |
| 18947 | 100 | 238 | 239.6 | 0.993 | 0.994 | 0.954 | −0.10 |

Mean ratios: 1.0397 (P=10^6), 1.0456 (carriers-only), 1.0153 (sieve-refined).

## Findings

1. **The literal "±12% on every box" phrasing FAILS out of sample: 8/10 within, two
   boxes at +14.1% and +15.3%.** But the failure is exactly Poisson-shaped: at
   π_V ≈ 250, one box carries ~6.3% noise, so ±12% is only a ±1.9σ band; the two
   violators sit at Z = +2.08 and +2.28, and observing ≥2 such boxes in 10 has
   probability ≈ 11% under the model. The honest restatement of the law is:
   **π̂ predicts fresh boxes to within Poisson noise (max |Z| = 2.28 over 10 fresh
   boxes, zero free parameters)** — that survives; a fixed ±12% guarantee does not.
2. **Sieve-refined prediction is better centered** (mean 1.015 vs 1.040): applying
   the 59 carriers' cosets exactly instead of on average absorbs part of the
   m=14681 overshoot (1.141 → 1.032). m=15907 stays high (1.136) — pure noise per Z.
3. **Mild pooled overshoot, flagged OPEN:** Σ actual = 3393 vs Σ π̂(10^6) = 3277,
   pooled Z = +2.03 (+3.5%). Same sign in the carriers-only variant; reduced (+1.5%)
   in the sieve-refined variant. Either a ~2σ fluctuation or a small real
   underprediction (e.g. truncation tail of C_BH); 10 boxes cannot distinguish.
   No action — watch in future fresh boxes.
4. **No systematic drift with D:** cumulative ratio tracked at D′ = 40…D per box
   wobbles within Poisson bands around its final value (e.g. m=59: 0.98 → 1.10 →
   stable 1.09–1.13 from D′=50 onward; m=109 D=150: 1.04→1.005 flat). Mean ratio at
   D′=40 is 1.017 vs 1.040 at full D — inside noise. Per-diagonal flattening
   (asymptote 3·C_BH·1.135883/diagonal, 1.135883 = ln(ln3/ln2)/(ln3−ln2)): executed
   on the last-30-diagonal band of each box — ratios 0.83–1.14, mean 0.958, i.e. the
   band sits slightly BELOW the d→∞ asymptote as it must at finite D (log V > k·ln2
   + l·ln3), matching the prior receipt's 0.86–0.96.
5. Carriers-only C_BH (the task's literal truncation) differs from the full prime
   product by ≲ 2.5% on these m — for m of this size the carriers dominate C_BH.

## Verdicts

- "π̂ = 3·C_BH·Σ 1/log V predicts fresh boxes with zero free parameters to within
  Poisson noise": **SUPPORTED-SAMPLED** (10/10 fresh boxes |Z| ≤ 2.28; counts exact,
  recounts cross-implemented).
- "±12% holds on every box, out of sample": **REFUTED as stated** (2/10 fresh boxes
  outside; the band was always noise-limited, the prior 15/15 was partly luck).
- "Systematic drift with D": **none detected** (REFUTED at current power, D up to 150).
- π_V counts themselves: exact integers, dual-engine + independent recount —
  **VERIFIED** (as computations; BPSW/MR-25 primality, not kernel certificates).
