# Lane C receipt 1 — the first-prime-diagonal law D(m) at fresh scales

Date: 2026-06-10. Script: `shield_laneC_task1.py` (seed 20260611).
JSON: `shield-laneC-1-diagonal-law.json`. All m freshly sampled tonight; no prior data reused.

## The derivation (stated before it was run)

The renormalized Bateman–Horn local model (lane4 F3 convention, reproduced from scratch:
f_q = (1-1/H_q)/(1-1/q) if triggered else 1/(1-1/q); C_BH(m) = prod_{3<q<=10^6} f_q) says an
admissible cell (2 not| V, 3 not| V) is prime with probability p ~ 3·C_BH(m)/log V. Under
cell-independence (the assumption under test):

    P(D(m) > D) ~ exp(-Lambda(m,D)),   Lambda(m,D) = 3·C_BH(m) · sum_{adm cells, k+l<=D} 1/log V.

Predicted median = min{D : Lambda >= ln 2}; predicted mean = sum_d exp(-Lambda(m,d)).
For log m >> D the cell sum is ~ D^2/(2 log m), giving the scaling law

    D_typ ~ sqrt( 2 ln 2 · log m / (3 C_BH(m)) )      — a SQRT-log-m law.

The prompt's suggested shape "D ~ log m/(c·C_BH·...)" is NOT the typical value; anything
linear in log m is an extreme-value envelope over very many m (cf. D_max ~ 2 log m/log 3),
not the per-m law. The data below adjudicates: sqrt wins.

A second, sieve-refined variant applies the 59 carriers' cosets EXACTLY (covered cells get
probability 0; C_sieve = C_BH / prod_{triggered carriers}(1-1/H_q) on survivors).

## Fresh samples: 40 m at each of 10^6, 10^9, 10^12; 8 at 10^15 (uniform in [X,2X), seeded)

Every found prime V(m,k,l) was independently confirmed by sympy BPSW on top of
gmpy2.is_prime(·,25). Search exact (every smaller diagonal exhausted; k=0 and 3|V cells
are composite by construction and excluded as candidates).

| scale | n | obs mean D | obs med | obs max | pred mean (avg model) | pred mean (sieve) | sqrt-law med | envelope 2ln m/ln3 |
|---|---|---|---|---|---|---|---|---|
| 10^6  | 40 | 3.275 (se 0.24) | 3 | 7  | 3.385 | 3.993 | 2.55 | 25.2 |
| 10^9  | 40 | 3.825 (se 0.34) | 4 | 10 | 4.168 | 4.298 | 3.22 | 37.7 |
| 10^12 | 40 | 5.075 (se 0.35) | 5 | 10 | 4.558 | 5.156 | 3.64 | 50.3 |
| 10^15 | 8  | 5.500 (se 1.02) | 5.5 | 9 | 5.141 | 5.016 | 4.22 | 62.9 |

- Observed growth 10^6 -> 10^15: ratio 1.68. Sqrt-law predicts 1.58; a linear-in-log-m
  law would predict 2.50. **The sqrt law is the right shape; the linear shape is refuted
  for typical D(m).**
- Distributional test (the sharp one): randomized probability-integral-transform of each
  D_i through its own Lambda(m_i, ·) curve, KS against Uniform(0,1), n = 128:
  **KS p = 0.528 (avg model), p = 0.337 (sieve model).** PIT mean 0.487 / 0.536, tails
  balanced. The independent-cell BH model is statistically indistinguishable from the
  fresh data at n = 128.
- Envelope: all 128 D(m) are far below 2·log m/log 3 (max observed 10 vs envelopes 25–63).

## Bonus: 50,000-m mass sweep at [10^6, 2·10^6) (seed 20260611+99, all fresh)

Histogram of D (50,000 m): 1:6696, 2:11091, 3:13668, 4:9033, 5:5475, 6:2477, 7:1017,
8:374, 9:113, 10:35, 11:15, 12:5, 16:1.

- **Max D = 16 at m = 1,619,311** (prime at (k,l) = (14,2): V = 1619311·2^14·3^2 + 1;
  confirmed by sympy BPSW independently). Model plug-in tail (mean of the 40 per-m
  exp(-Lambda_sieve) curves at this scale): P(max >= 16 over 50k) = 0.21 — the record is
  exactly where the model says records live. Expected # m with D >= 15 was 2.9; observed 1
  (p ~ 0.2, unremarkable).
- **Envelope check: 0 of 50,000 fresh m violate D <= 2·log m/log 3** (envelope = 26.4 at 2·10^6).
- Wrinkle, disclosed: no m landed in D ∈ {13,14,15} while one hit 16; the observed extreme
  tail is if anything slightly THINNER than the independent-cell model. Directionally this
  is what the entanglement shield predicts (overlap-forced extra survivors -> primes arrive
  on or before schedule), but at this sample size it is **not significant** (p between 0.02
  and 0.2 depending on the cut) — recorded as a direction to watch, not a finding.

## Verdicts

- "D(m) follows the renormalized-BH waiting-time law with Lambda = 3 C_BH Σ 1/log V":
  **SUPPORTED-SAMPLED** (KS p = 0.53/0.34 at n = 128 fresh m across 9 decades; 50k-sweep
  record at the model's 21% quantile). Not a theorem; a 128+50,000-point out-of-sample fit.
- "Typical D grows like sqrt(log m), not log m": **SUPPORTED-SAMPLED** (1.68 vs 1.58 vs 2.50).
- "D_max <= 2 log m/log 3 (empirical envelope)": **SUPPORTED-SAMPLED, 50,128/50,128 fresh m
  comply**; the envelope is loose by design at these sample sizes (model says reaching it
  needs ~e^29 samples at 10^6 scale, so compliance is expected and is NOT strong evidence
  for the constant 2/ln 3 itself).
- Nothing here is VERIFIED in the kernel sense; all conclusions are sampled statistics with
  exact integer inputs and dual-engine primality.
