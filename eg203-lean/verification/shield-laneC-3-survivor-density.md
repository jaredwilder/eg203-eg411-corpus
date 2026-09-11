# Lane C receipt 3 — the survivor-density law (200 fresh m, exact box counts)

Date: 2026-06-10. Scripts: `shield_laneC_task3.py` (seed 20260613), `shield_laneC_task3b.py`.
JSON: `shield-laneC-3-survivor-density.json`, `shield-laneC-3b-pairwise-E.json`.

## What was computed (exact integers)

For 200 fresh random ordinary m (log-uniform 10^2..10^12, seeded, all listed in JSON):
the EXACT number of cells in [0,2520) x [0,5040) (12,700,800 cells) dodging ALL
triggered carriers (the 59 verified carriers, receipt 0), vs the independence
prediction prod_{triggered}(1 - 1/H_q).

**Cross-implementation (PROCESS-GOLD §3):** for 3 of the 200 m, the 504x504 sub-box
recounted by an independent pure-Python per-cell modular-exponentiation loop (no
numpy, no lookup tables): 84,975 / 63,283 / 75,279 survivors — **exact match 3/3**.

## Headline numbers

| quantity | value |
|---|---|
| triggered carriers per m | mean 44.5, max 51 (of 59) |
| Σ 1/H_q (triggered) | mean 1.149, max 1.376 |
| survivor fraction (actual) | min 0.2343, mean 0.3020, max 0.4950 |
| independence prediction | min 0.2342, mean 0.3019, max 0.4939 |
| ratio actual/independence | **mean 1.0005, geomean 0.9998, median 0.9984** |
| ratio range | [0.9143, 1.1472], sd(log) = 0.0377 |
| m with ratio < 1 | **106 of 200** (94 above) |
| corr(ratio, #triggered) | +0.09 (none) |
| m with zero survivors | **0 of 200** |

## Finding 1 — the hypothesis AS STATED is REFUTED

"The survivor density is BIGGER than independence predicts (entanglement helps
survivors)": **REFUTED in expectation.** The mean ratio is 1.0005, the geometric mean
0.9998, and MORE m sit below independence (106) than above (94). Entanglement is a
real per-m modulation (up to ±15%) but it is SIGNED — it helps some m (max +14.7%,
m = 6,820,067) and hurts others (min −8.6%, m = 133,974,061) and nets to zero on
random m to 3 decimal places.

## Finding 2 — the pairwise mechanism IS real, and it is an EXACT integer law

Pre-registered before the box counts finished, then cross-implemented
(`shield_laneC_task3b.py`): for triggered carriers q1, q2 the joint covered density
on the exact lcm-period torus is

    joint = 0   (incompatible cosets)   or   joint = E / (H_{q1} H_{q2}) exactly,

with E = [Z^2 : Lambda_{q1} + Lambda_{q2}] computed INDEPENDENTLY by lattice algebra
(gcd of all 2x2 minors of the joined basis matrix; basis (d2,0),(b,H/d2) with
2^b 3^{H/d2} = 1 mod q). Tested on all triggered pairs among carriers q < 100 for
m in {1, 982367, 6820067, 133974061}:

  **843/843 pairs satisfy the dichotomy exactly (Fraction arithmetic, zero violations).**
  E histogram: E=1: 590, E=2: 106, E=3: 20, E=4: 8, E=6: 1, E=8: 1; zeros: 117.
  All 117 incompatible (zero) cases occur at E >= 2, never at E = 1 — exactly as the
  lattice theorem demands (E = 1 means Lambda_1 + Lambda_2 = Z^2, cosets always meet).

## Finding 3 — what the shield actually is (corrected shape)

The union of triggered cosets saturates below 1 for every tested m, but NOT because
entanglement nets in the survivors' favor. The honest mechanism visible in the data:

1. **The independence floor is already positive and fat:** even the worst sampled m
   (Σ 1/H = 1.376) has Π(1−1/H) = 0.2342, and the actual fraction tracked it (0.2343).
   First-order Bonferroni (Σ 1/H, mean 1.149) exceeds the actual union (mean 0.698)
   massively; almost all of that reduction is captured by the INDEPENDENCE product.
2. **Entanglement is a bounded, mean-zero modulation on top** (±15% max, sd 3.8% in
   log, no correlation with the number of triggered carriers). 70% of carrier pairs
   have E = 1 (exactly independent, forced); the E>=2 minority splits between
   overlap-boosts (joint = E·indep > indep) and hard exclusions (joint = 0) whose
   net effect cancels on average over random m.
3. Every one of the 200 fresh m has survivors — consistent with the universal-survivor
   observation (16,666 + 43 adversarial m upstream), now with the exact box fractions
   attached.

## Verdicts

- "Survivor density exceeds independence for every (or typical) m": **REFUTED**
  (106/200 below 1; geomean 0.9998).
- "Joint density of two triggered carriers is 0 or E/(H1·H2), E = [Z²:Λ1+Λ2] ≥ 1":
  **VERIFIED-EXACT on 843/843 sampled triples, cross-implemented** (enumeration vs
  lattice algebra). As a general statement it is standard lattice/coset arithmetic;
  the receipts make it checkable integer-by-integer.
- "Union of triggered cosets stays below 1 for every m" (the shield itself): holds in
  every sample ever taken (here min survivor fraction 0.2343), driven by the
  independence floor, **SUPPORTED-SAMPLED** — NOT proven; the entanglement-surplus
  route to proving it is now closed by Finding 1 (there is no surplus to lean on).
