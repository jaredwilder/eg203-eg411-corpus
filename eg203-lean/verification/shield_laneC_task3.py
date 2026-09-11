"""
shield_laneC_task3.py — LANE C #3: the survivor-density law.

For 200 random ordinary m (log-uniform across 10^2..10^12, seeded):
  - exact count of cells (k,l) in the box [0,2520) x [0,5040) that dodge ALL
    triggered carriers (primes q <= 10^6 with H_q <= 200),
  - vs the independence prediction prod_{triggered carriers} (1 - 1/H_q).
Quantifies how much BIGGER the actual survivor density is than independence
predicts (the shield's positive face: entanglement helps survivors too).

Coverage rule (verified local law): triggered q covers (k,l) iff
  2^k * 3^l == -m^{-1} (mod q); the covered set is periodic with periods (d2, d3).

Cross-implementation: for 3 of the 200 m, the numpy mask count on the 504x504
sub-box is recomputed with an independent pure-Python per-cell modular
exponentiation loop (no numpy, no shared tables).
"""
import json
import math
import os
import time

import numpy as np

from shield_laneC_common import (
    VERIF_DIR,
    build_orders,
    carriers,
    env_meta,
    pow_table,
    trig_carriers_for_m,
)

SEED = 20260613
KDIM, LDIM = 2520, 5040
NCELLS = KDIM * LDIM
NM = 200
OUT = os.path.join(VERIF_DIR, "shield-laneC-3-survivor-density.json")


def survivor_count_numpy(trigs):
    covered = np.zeros((KDIM, LDIM), dtype=bool)
    for q, d2, d3, H, T in trigs:
        p2 = np.array(pow_table(2, d2, q), dtype=np.int64)
        p3 = np.array(pow_table(3, d3, q), dtype=np.int64)
        A = np.resize(p2, KDIM)  # 2^k mod q, periodic d2
        B = np.resize(p3, LDIM)  # 3^l mod q, periodic d3
        covered |= (A[:, None] * B[None, :]) % q == T
    return int(covered.size - covered.sum()), covered


def survivor_count_python_subbox(m, trigs, kdim, ldim):
    """Independent path: per-cell pow(); no numpy, no shared tables."""
    count = 0
    for k in range(kdim):
        for l in range(ldim):
            ok = True
            for q, d2, d3, H, T in trigs:
                if (pow(2, k, q) * pow(3, l, q)) % q == T:
                    ok = False
                    break
            if ok:
                count += 1
    return count


def main():
    t0 = time.time()
    qa, d2a, d3a, Ha = build_orders()
    cq, cd2, cd3, cH = carriers(qa, d2a, d3a, Ha)

    rng = np.random.default_rng(SEED)
    ms = []
    seen = set()
    while len(ms) < NM:
        m = int(10 ** rng.uniform(2.0, 12.0))
        while math.gcd(m, 6) != 1:
            m += 1
        if m not in seen:
            seen.add(m)
            ms.append(m)

    rows = []
    for i, m in enumerate(ms):
        trigs = trig_carriers_for_m(m, cq, cd2, cd3, cH)
        surv, covered = survivor_count_numpy(trigs)
        frac = surv / NCELLS
        indep = 1.0
        sum_inv_h = 0.0
        for q, d2, d3, H, T in trigs:
            indep *= 1.0 - 1.0 / H
            sum_inv_h += 1.0 / H
        rows.append(
            {
                "m": m,
                "n_triggered_carriers": len(trigs),
                "triggered_q": [t[0] for t in trigs],
                "triggered_H": [t[3] for t in trigs],
                "sum_inv_H": sum_inv_h,
                "survivors_exact": surv,
                "survivor_fraction": frac,
                "independence_pred": indep,
                "ratio_actual_over_indep": frac / indep if indep > 0 else None,
                "union_density": 1.0 - frac,
                "bonferroni_sum_singles": sum_inv_h,
            }
        )
        if (i + 1) % 25 == 0:
            print(f"[task3] {i+1}/{NM} ({time.time()-t0:.0f}s)", flush=True)

    # --- cross-implementation on 3 m's, 504x504 sub-box ---
    xchecks = []
    for i in [0, 99, 199]:
        m = ms[i]
        trigs = trig_carriers_for_m(m, cq, cd2, cd3, cH)
        _, covered = survivor_count_numpy(trigs)
        np_sub = int(504 * 504 - covered[:504, :504].sum())
        py_sub = survivor_count_python_subbox(m, trigs, 504, 504)
        xchecks.append({"m": m, "numpy_subbox": np_sub, "python_subbox": py_sub, "match": np_sub == py_sub})

    ratios = np.array([r["ratio_actual_over_indep"] for r in rows])
    fr = np.array([r["survivor_fraction"] for r in rows])
    nt = np.array([r["n_triggered_carriers"] for r in rows])
    summary = {
        "n_m": NM,
        "box": [KDIM, LDIM],
        "ratio_min": float(ratios.min()),
        "ratio_max": float(ratios.max()),
        "ratio_mean": float(ratios.mean()),
        "ratio_median": float(np.median(ratios)),
        "ratio_geomean": float(np.exp(np.log(ratios).mean())),
        "n_ratio_below_1": int((ratios < 1.0).sum()),
        "n_ratio_above_1": int((ratios > 1.0).sum()),
        "min_survivor_fraction": float(fr.min()),
        "min_survivor_fraction_m": int(ms[int(fr.argmin())]),
        "max_sum_inv_H": float(max(r["sum_inv_H"] for r in rows)),
        "n_triggered_mean": float(nt.mean()),
        "n_triggered_max": int(nt.max()),
        "pearson_ratio_vs_ntrig": float(np.corrcoef(nt, ratios)[0, 1]),
        "all_m_have_survivors": bool(all(r["survivors_exact"] > 0 for r in rows)),
        "crosschecks_pass": all(x["match"] for x in xchecks),
    }
    out = {
        "meta": env_meta(os.path.abspath(__file__)),
        "seed": SEED,
        "summary": summary,
        "crosschecks": xchecks,
        "rows": rows,
        "runtime_s": round(time.time() - t0, 1),
    }
    with open(OUT, "w") as f:
        json.dump(out, f, indent=1)
    print(
        f"[task3] DONE ratio mean={summary['ratio_mean']:.4f} "
        f"min={summary['ratio_min']:.4f} max={summary['ratio_max']:.4f} "
        f"below1={summary['n_ratio_below_1']} xcheck={summary['crosschecks_pass']} "
        f"({out['runtime_s']}s)",
        flush=True,
    )


if __name__ == "__main__":
    main()
