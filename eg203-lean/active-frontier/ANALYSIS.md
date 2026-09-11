# L6_D0_BV_THRESHOLD — Production-Scale Attack Analysis

- Run timestamp (UTC): `2026-06-03T17:27:33Z`
- Attack ID: `L6_attack_prod_20260603T172733Z`
- Variance JSONL (6 rows total): `sieve_variance/variance.jsonl`
- Optimizer report: `D0_OPTIMIZATION_PROD.md` + `D0_OPTIMIZATION_PROD.json`
- Prior toy dispatch: `runs/brain_dispatch_L6_20260603T170712Z/`

## 1. variance.jsonl summary (6 records)

| x      | Q   | #primes | max_q | total_V         | budget_ratio | source                      |
|--------|-----|---------|-------|-----------------|--------------|-----------------------------|
| 1e+06  | 5   | 3       | 5     | 2,999,924       | **170.15**   | toy (20260603T170712Z)      |
| 1e+07  | 12  | 5       | 11    | 29,999,897      | **257.77**   | toy                         |
| 1e+08  | 30  | 10      | 29    | 299,999,854     | **326.25**   | toy                         |
| 1e+09  | 79  | 22      | 79    | 2,999,999,813   | **402.78**   | prod (this run)             |
| 1e+10  | 189 | 42      | 181   | 29,999,999,800  | **532.67**   | prod                        |
| 1e+11  | 505 | 96      | 503   | 299,999,999,767 | **629.34**   | prod                        |

Wall time per prod call (E12 prime cache amortised): 2.16 s / 1.71 s / 2.55 s. Q at 1e11 saturated to 505 from policy formula naturally (no `--q-cap` hit).

## 2. budget_ratio trend

Decade-over-decade increment in log10(ratio):

| transition       | delta log10(ratio) | ratio multiplier |
|------------------|--------------------|------------------|
| 1e6  -> 1e7      | +0.180             | x1.515           |
| 1e7  -> 1e8      | +0.102             | x1.266           |
| 1e8  -> 1e9      | +0.092             | x1.235           |
| 1e9  -> 1e10     | +0.121             | x1.323           |
| 1e10 -> 1e11     | +0.072             | x1.182           |

Mean 2nd-diff log10(ratio) = -0.027 (signs: -, -, +, -). **Decelerating on log-log but UP every decade.** No asymptote in sight.

### Best fits

- **Power law (log-log linear):** `ratio = 40.37 * x^0.1108`, RMSE on log10 scale = 0.025 (each point within 9% of fit).
  - Forecast: 1e12 -> 862, 1e13 -> 1112, 1e14 -> 1435, 1e15 -> 1853, 1e20 -> 6633.
- **Raw vs log10(x):** `ratio = -390.0 + 91.35 * log10(x)`, RMSE = 16.2.
  - Forecast: 1e12 -> 706, 1e15 -> 980. Worse fit; consistent with mild concavity.

## 3. Optimizer verdict at production scale

`forge_bv_constant_optimizer.py` ingested all 6 records:

- **All five D0 targets {1e87, 1e60, 1e40, 1e25, 1e15} remain INFEASIBLE.**
- Binding constraint moved from (x=1e8, ratio=326) to **(x=1e11, ratio=629)**.
- Worst-case max_a still `0`. Same structural witness as toy; only magnitude grew.
- Achievable D0 estimate stayed at order 10^89 because worst_ratio went 326 -> 629.
- Exit code 0; Fraction arithmetic clean (numerators up to 530 digits).

## 4. Diagnosis: structural-obstruction or attackable-via-larger-Q?

**Verdict: STRUCTURAL OBSTRUCTION at the chosen Q policy. Q is NOT the lever.**

Reasoning:
1. Budget grows ~`x^2 / log(x)^2`; V-family variance dominated by a=0 class with per-prime worst error ~`x/2` (`max_error_num` at 1e11 = `149,999,999,761/2 ~ 0.75 x`). V_total grows ~`x^2 * q_count`, budget grows ~`x^2`. q_count: 3 -> 5 -> 10 -> 22 -> 42 -> 96. That growth dominates the budget tightening.
2. Power-law exponent 0.1108 is consistent with `q_count ~ log(x)` mass piling at the a=0 class.
3. `enumerate_V_residues` (`forge_brain/constants/forge_sieve_variance.py:98-101`) collapses V to `1 mod q` whenever `pow23 mod q == 0`, i.e. for q | 6 (q in {2,3}). Pure concentration, no smoothing.
4. **Larger Q cannot help.** Adding more primes adds non-negative terms to V_total. The trend `max_q` 5 -> 11 -> 29 -> 79 -> 181 -> 503 confirms the binding prime climbs with Q rather than diminishes.
5. Mean 2nd-diff -0.027 = slow but unbounded log-power growth, not asymptote. Bending DOWN requires either (a) a V-tailored Hooley budget in the denominator, or (b) smoothed-coefficient sieve subtracting the trivial-class mass before variance.

## 5. Recommended next dispatch

**`gap_id = L6_D0_BV_THRESHOLD` (continue) with REFRAMED kill_metric.**

### Primary recommendation: L6-RW (budget reweight)

- **New script:** `forge_brain/constants/forge_v_family_hooley_budget.py`
- **Mechanism:** replace `generic_bv_budget(x, Q) = x^2 / log(x)^2` with V-family Hooley budget `V_hooley(x, Q) = x^2 * sum_{q <= Q} (1 / phi(q))`. Scales like `x^2 * log(Q)` and absorbs q_count growth.
- **Params:** `--x-grid 1e9,1e10,1e11 --q-policy sqrt_x_over_logA --family V`
- **Expected:** budget_ratio collapses from O(log(x)^k) toward O(1). 1e15 target PROMOTABLE.
- **dispatch.jsonl:** `{"gap_id":"L6_D0_BV_THRESHOLD","subgap":"L6-RW","script":"forge_brain/constants/forge_v_family_hooley_budget.py","argv":["--x-grid","1e9,1e10,1e11","--q-policy","sqrt_x_over_logA","--family","V","--out","runs/L6_RW_<ts>/"]}`

### Secondary: L6-RES (a=0 class smoothing)

- **Patch:** add `--subtract-trivial-class` to `forge_sieve_variance.py`. In `enumerate_V_residues`, subtract `total // q` from each class before variance (Heath-Brown smoothed sieve).
- **Expected:** `max_error_num` drops O(x) -> O(x / log(x)); budget_ratio in 10s instead of 100s.

### Anti-recommendations
- **Do NOT scale x to 1e12+** under current config. Trend says it gets worse.
- **Do NOT raise `--q-cap`.** Q is policy-bound, not cap-bound.
- **Do NOT change family.** V-family is the right substrate; obstruction is in the budget.

## 6. Verification

- [x] variance.jsonl has 6 rows (1e6, 1e7, 1e8, 1e9, 1e10, 1e11) — `wc -l` confirmed.
- [x] All 6 rows have `budget_ratio` populated (string + exact `_num`/`_den`).
- [x] `forge_bv_constant_optimizer.py` exit code 0.
- [x] D0_OPTIMIZATION_PROD.md + .json + ANALYSIS.md all present in this dir.
