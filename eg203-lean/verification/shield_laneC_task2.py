"""
shield_laneC_task2.py — LANE C #2: C_BH at FRESH boxes (out-of-sample test of the
+-12% renormalized Bateman-Horn law from lane4 F3).

Prior 15 boxes used m in {5, 35, 65, 95, 115} (lane4 receipt). Those m are EXCLUDED.
Fresh boxes (seeded): 4x (m <= 200, D = 120), 3x (m <= 200, D = 150),
                      3x (m ~ 10^4, D = 100).

Convention reproduced exactly from lane4 F3:
  f_q(m) = (1 - 1/H_q)/(1 - 1/q) if q triggered, else 1/(1 - 1/q)   [incl. q | m]
  C_BH(m; P) = prod_{3 < q <= P} f_q(m)
  pi_hat(m, D) = 3 * C_BH(m) * sum_{k+l<=D, 2 !| V, 3 !| V} 1/log V
  (the 3 = exact local factors at p = 2 [k>=1 => V odd] and p = 3 [3 !| V]).

Variants reported per box:
  P = 10^5 full-prime product       (the workhorse)
  P = 10^6 full-prime product       (stability check, lane4 used this)
  P = 10^5 carriers-only product    (the task's literal "carriers to 10^5" reading)
  sieve-refined: cells covered by a triggered carrier are zeroed exactly and the
    carrier factors are replaced by the conditional 1/(1-1/q) on survivors
    (i.e. C_sieve = C_BH / prod_{trig carriers}(1 - 1/H_q), summed over uncovered cells).

Actual pi_V is exact: every cell's V is tested; composites certified by
gcd(V, primorial(10^5)) > 1 where applicable; every remaining cell decided by BOTH
gmpy2.is_prime(V, 25) and sympy.isprime(V) (BPSW) with agreement asserted.

Drift diagnostic: cumulative actual/predicted ratio at D' = 40,50,...,D.
"""
import json
import math
import os
import time

import gmpy2
import numpy as np
import sympy

from shield_laneC_common import (
    LN2,
    LN3,
    VERIF_DIR,
    build_orders,
    c_bh,
    carriers,
    env_meta,
    pow_table,
    trig_carriers_for_m,
    triggered,
)

SEED = 20260612
PRIOR_M = {5, 35, 65, 95, 115}
OUT = os.path.join(VERIF_DIR, "shield-laneC-2-cbh-fresh-boxes.json")
PRIM = gmpy2.primorial(10**5)


def adm_l0(m, k):
    """Admissible on the l=0 row: 3 !| V(m,k,0)."""
    return ((m % 3) * (2 if k % 2 else 1)) % 3 != 2


def count_box(m, D):
    """Exact prime count per diagonal + dual-engine agreement bookkeeping."""
    per_diag = [0] * (D + 1)
    tested = agree = 0
    primes_found = []
    for d in range(D + 1):
        for k in range(1, d + 1):  # k=0 => V even => composite (V > 2)
            l = d - k
            if l == 0 and not adm_l0(m, k):
                continue  # 3 | V, V > 3 => composite
            V = gmpy2.mpz(m) * (gmpy2.mpz(2) ** k) * (gmpy2.mpz(3) ** l) + 1
            if V < 10**6:
                isp = bool(gmpy2.is_prime(V, 25))
                assert isp == sympy.isprime(int(V))
            else:
                if gmpy2.gcd(V, PRIM) > 1:
                    continue  # certified composite (a prime <= 1e5 divides V < ... V > 1e6)
                tested += 1
                isp1 = bool(gmpy2.is_prime(V, 25))
                isp2 = bool(sympy.isprime(int(V)))
                assert isp1 == isp2, (m, k, l)
                agree += 1
                isp = isp1
            if isp:
                per_diag[d] += 1
                primes_found.append([k, l])
    return per_diag, tested, agree, primes_found


def prediction_sums(m, D, trigs):
    """sum 1/log V over admissible cells, total and per diagonal; also the
    sieve-refined sum restricted to cells uncovered by triggered carriers."""
    tables = []
    for q, d2, d3, H, T in trigs:
        tables.append((q, d2, d3, T, pow_table(2, d2, q), pow_table(3, d3, q)))
    lm = math.log(m)
    s_all_per_d = [0.0] * (D + 1)
    s_unc_per_d = [0.0] * (D + 1)
    for d in range(D + 1):
        sa = su = 0.0
        for k in range(1, d + 1):
            l = d - k
            if l == 0 and not adm_l0(m, k):
                continue
            w = 1.0 / (lm + k * LN2 + l * LN3)
            sa += w
            cov = False
            for q, d2, d3, T, p2, p3 in tables:
                if (p2[k % d2] * p3[l % d3]) % q == T:
                    cov = True
                    break
            if not cov:
                su += w
        s_all_per_d[d] = sa
        s_unc_per_d[d] = su
    return s_all_per_d, s_unc_per_d


def main():
    t0 = time.time()
    qa, d2a, d3a, Ha = build_orders()
    cq, cd2, cd3, cH = carriers(qa, d2a, d3a, Ha)
    qlist = [int(x) for x in qa]
    Hlist = [int(x) for x in Ha]
    # carriers-only arrays for the literal "carriers to 1e5" C variant
    carr5 = [(int(q), int(h)) for q, h in zip(cq, cH) if int(q) <= 10**5]

    rng = np.random.default_rng(SEED)
    small_pool = [m for m in range(7, 200, 2) if math.gcd(m, 6) == 1 and m not in PRIOR_M]
    small_pick = [int(small_pool[i]) for i in rng.choice(len(small_pool), size=7, replace=False)]
    boxes = [(m, 120) for m in small_pick[:4]] + [(m, 150) for m in small_pick[4:]]
    mid = set()
    while len(mid) < 3:
        m = int(rng.integers(10**4, 2 * 10**4))
        while math.gcd(m, 6) != 1:
            m += 1
        mid.add(m)
    boxes += [(m, 100) for m in sorted(mid)]

    rows = []
    for m, D in boxes:
        tb0 = time.time()
        per_diag, tested, agree, primes_found = count_box(m, D)
        actual = sum(per_diag)

        C5, ntrig5 = c_bh(m, qlist, Hlist, 10**5)
        C6, ntrig6 = c_bh(m, qlist, Hlist, 10**6)
        logc = 0.0
        for q, H in carr5:
            if triggered(m, q, H):
                logc += math.log1p(-1.0 / H) - math.log1p(-1.0 / q)
            else:
                logc += -math.log1p(-1.0 / q)
        C5_carriers_only = math.exp(logc)

        trigs = trig_carriers_for_m(m, cq, cd2, cd3, cH)
        s_all_per_d, s_unc_per_d = prediction_sums(m, D, trigs)
        S_all = sum(s_all_per_d)
        S_unc = sum(s_unc_per_d)
        C_sieve = C6
        for q, d2, d3, H, T in trigs:
            C_sieve /= 1.0 - 1.0 / H

        pred5 = 3.0 * C5 * S_all
        pred6 = 3.0 * C6 * S_all
        pred5c = 3.0 * C5_carriers_only * S_all
        pred_sv = 3.0 * C_sieve * S_unc

        # drift: cumulative ratio (actual/pred6) at D' = 40..D step 10
        drift = []
        ca = 0
        cs = 0.0
        for d in range(D + 1):
            ca += per_diag[d]
            cs += s_all_per_d[d]
            if d >= 40 and d % 10 == 0:
                drift.append({"D": d, "actual": ca, "pred": 3.0 * C6 * cs, "ratio": ca / (3.0 * C6 * cs)})

        rows.append(
            {
                "m": m,
                "D": D,
                "n_cells": (D + 1) * (D + 2) // 2,
                "pi_V_actual": actual,
                "dual_engine_tested": tested,
                "dual_engine_agree": agree,
                "C_BH_1e5": C5,
                "C_BH_1e6": C6,
                "C_BH_1e5_carriers_only": C5_carriers_only,
                "C_sieve_1e6": C_sieve,
                "n_triggered_1e5": ntrig5,
                "n_triggered_carriers": len(trigs),
                "sum_invlog_all": S_all,
                "sum_invlog_uncovered": S_unc,
                "pred_1e5": pred5,
                "pred_1e6": pred6,
                "pred_1e5_carriers_only": pred5c,
                "pred_sieve": pred_sv,
                "ratio_1e5": actual / pred5,
                "ratio_1e6": actual / pred6,
                "ratio_carriers_only": actual / pred5c,
                "ratio_sieve": actual / pred_sv,
                "drift": drift,
                "per_diag_actual": per_diag,
                "runtime_s": round(time.time() - tb0, 1),
            }
        )
        print(
            f"[task2] m={m} D={D} pi_V={actual} ratio6={actual/pred6:.4f} "
            f"ratio_sieve={actual/pred_sv:.4f} ({rows[-1]['runtime_s']}s)",
            flush=True,
        )

    r6 = np.array([r["ratio_1e6"] for r in rows])
    rsv = np.array([r["ratio_sieve"] for r in rows])
    rco = np.array([r["ratio_carriers_only"] for r in rows])
    summary = {
        "n_boxes": len(rows),
        "boxes": [[r["m"], r["D"]] for r in rows],
        "ratio_1e6_min": float(r6.min()),
        "ratio_1e6_max": float(r6.max()),
        "ratio_1e6_mean": float(r6.mean()),
        "all_within_12pct_1e6": bool(np.all(np.abs(r6 - 1) <= 0.12)),
        "ratio_sieve_min": float(rsv.min()),
        "ratio_sieve_max": float(rsv.max()),
        "ratio_sieve_mean": float(rsv.mean()),
        "all_within_12pct_sieve": bool(np.all(np.abs(rsv - 1) <= 0.12)),
        "ratio_carriers_only_min": float(rco.min()),
        "ratio_carriers_only_max": float(rco.max()),
        "ratio_carriers_only_mean": float(rco.mean()),
        "all_dual_engine_agree": bool(all(r["dual_engine_tested"] == r["dual_engine_agree"] for r in rows)),
    }
    out = {
        "meta": env_meta(os.path.abspath(__file__)),
        "seed": SEED,
        "prior_m_excluded": sorted(PRIOR_M),
        "summary": summary,
        "rows": rows,
        "runtime_s": round(time.time() - t0, 1),
    }
    with open(OUT, "w") as f:
        json.dump(out, f, indent=1)
    print(
        f"[task2] DONE mean ratio6={summary['ratio_1e6_mean']:.4f} "
        f"range [{summary['ratio_1e6_min']:.4f},{summary['ratio_1e6_max']:.4f}] "
        f"within12={summary['all_within_12pct_1e6']} ({out['runtime_s']}s)",
        flush=True,
    )


if __name__ == "__main__":
    main()
