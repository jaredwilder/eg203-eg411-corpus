"""
shield_laneC_task1.py — LANE C #1: the first-prime-diagonal law D(m) at fresh scales.

D(m) = min{k+l : V(m,k,l) prime}.  Samples (seeded, fresh): 40 ordinary m at each of
10^6, 10^9, 10^12 (uniform in [X, 2X)), and 8 at 10^15.

DERIVATION OF THE PREDICTION (stated, then executed exactly):
  The renormalized Bateman-Horn local model (lane4 F3, verified +-12% in-sample) says
  an admissible cell (2 !| V, 3 !| V) is prime with probability
      p(k,l) ~= 3 * C_BH(m) / log V(m,k,l).
  Treating cells as independent (precisely the assumption under test):
      P(D(m) > D) ~= prod_{adm cells, k+l <= D} (1 - p) ~= exp(-Lambda(m,D)),
      Lambda(m,D) = 3 * C_BH(m) * sum_{adm cells, k+l <= D} 1/log V.
  Predicted median D = min{D : Lambda >= ln 2};  E[D] = sum_{d>=0} exp(-Lambda(m,d)).
  For log m >> D the cell sum is ~ (D^2/2)/log m, so
      D_typ ~= sqrt(2 ln 2 * log m / (3 C_BH(m)))  — a SQRT-log-m law.
  (The suggested form "D ~ log m / (c * C_BH)" is NOT the typical value; linear-in-log-m
  is the extreme-value envelope over astronomically many m, cf. D_max ~= 2 log m/log 3.)
  Sieve-refined variant: carrier cosets applied exactly instead of on average:
      Lambda_sieve = 3 * C_sieve * sum_{adm & uncovered} 1/log V,
      C_sieve = C_BH / prod_{triggered carriers} (1 - 1/H_q).

  Test statistic: randomized probability integral transform
      U_i = v_i + w_i (u_i - v_i),  u_i = exp(-Lambda(D_i - 1)), v_i = exp(-Lambda(D_i)),
  which is Uniform(0,1) iid under the model; Kolmogorov-Smirnov against uniform.

BONUS (1d): mass sweep of 50,000 fresh ordinary m in [10^6, 2*10^6): empirical D
distribution, max, and the envelope check D <= 2 log m / log 3 for every m.
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
)

SEED = 20260611
OUT = os.path.join(VERIF_DIR, "shield-laneC-1-diagonal-law.json")
SCALES = [(10**6, 40), (10**9, 40), (10**12, 40), (10**15, 8)]
DCAP = 250
MASS_N = 50000


def adm_l0(m, k):
    return ((m % 3) * (2 if k % 2 else 1)) % 3 != 2


def find_D(m, cap=DCAP, reps=25):
    """Exact first-prime diagonal; returns (D, k, l, n_tested)."""
    mz = gmpy2.mpz(m)
    tested = 0
    for d in range(cap + 1):
        # walk the diagonal: start at (k,l)=(1,d-1): V0 = m*2*3^(d-1)+1
        for k in range(1, d + 1):
            l = d - k
            if l == 0 and not adm_l0(m, k):
                continue
            V = mz * (1 << k) * gmpy2.mpz(3) ** l + 1
            tested += 1
            if gmpy2.is_prime(V, reps):
                return d, k, l, tested
    return None, None, None, tested


def lambda_curves(m, C_avg, C_sieve, trigs, dmax):
    """Cumulative Lambda_avg[d], Lambda_sieve[d] for d = 0..dmax."""
    tables = [(q, d2, d3, T, pow_table(2, d2, q), pow_table(3, d3, q)) for q, d2, d3, H, T in trigs]
    lm = math.log(m)
    lamA = np.zeros(dmax + 1)
    lamS = np.zeros(dmax + 1)
    accA = accS = 0.0
    for d in range(dmax + 1):
        for k in range(1, d + 1):
            l = d - k
            if l == 0 and not adm_l0(m, k):
                continue
            w = 1.0 / (lm + k * LN2 + l * LN3)
            accA += 3.0 * C_avg * w
            cov = False
            for q, d2, d3, T, p2, p3 in tables:
                if (p2[k % d2] * p3[l % d3]) % q == T:
                    cov = True
                    break
            if not cov:
                accS += 3.0 * C_sieve * w
        lamA[d] = accA
        lamS[d] = accS
    return lamA, lamS


def ks_uniform(u):
    """KS statistic + asymptotic p-value vs U(0,1)."""
    u = np.sort(np.asarray(u))
    n = len(u)
    i = np.arange(1, n + 1)
    dplus = np.max(i / n - u)
    dminus = np.max(u - (i - 1) / n)
    dn = max(dplus, dminus)
    lam = (math.sqrt(n) + 0.12 + 0.11 / math.sqrt(n)) * dn
    p = 2.0 * sum((-1) ** (j - 1) * math.exp(-2.0 * j * j * lam * lam) for j in range(1, 101))
    return float(dn), float(min(max(p, 0.0), 1.0))


def main():
    t0 = time.time()
    qa, d2a, d3a, Ha = build_orders()
    cq, cd2, cd3, cH = carriers(qa, d2a, d3a, Ha)
    qlist = [int(x) for x in qa]
    Hlist = [int(x) for x in Ha]

    rng = np.random.default_rng(SEED)
    samples = []
    for X, n in SCALES:
        seen = set()
        while len(seen) < n:
            m = int(rng.integers(X, 2 * X))
            while math.gcd(m, 6) != 1:
                m += 1
            seen.add(m)
        for m in sorted(seen):
            samples.append((X, m))

    rows = []
    for i, (X, m) in enumerate(samples):
        D, kk, ll, ntested = find_D(m)
        assert D is not None, f"no prime found below diagonal {DCAP} for m={m}"
        Vp = int(m) * 2**kk * 3**ll + 1
        assert sympy.isprime(Vp), (m, kk, ll)  # independent BPSW confirmation

        C6, _ = c_bh(m, qlist, Hlist, 10**6)
        trigs = trig_carriers_for_m(m, cq, cd2, cd3, cH)
        C_sieve = C6
        for q, d2, d3, H, T in trigs:
            C_sieve /= 1.0 - 1.0 / H
        dmax = max(D + 5, 40)
        lamA, lamS = lambda_curves(m, C6, C_sieve, trigs, dmax)
        while lamA[-1] < 14.0 and len(lamA) - 1 < 400:
            dmax = min(400, dmax + 30)
            lamA, lamS = lambda_curves(m, C6, C_sieve, trigs, dmax)

        med_pred_A = int(np.argmax(lamA >= math.log(2.0)))
        med_pred_S = int(np.argmax(lamS >= math.log(2.0)))
        mean_pred_A = float(np.exp(-lamA).sum())  # sum_{d>=0} P(D>d); tail < 1e-6
        mean_pred_S = float(np.exp(-lamS).sum())
        uA = float(np.exp(-lamA[D - 1])) if D >= 1 else 1.0
        vA = float(np.exp(-lamA[D]))
        uS = float(np.exp(-lamS[D - 1])) if D >= 1 else 1.0
        vS = float(np.exp(-lamS[D]))
        envelope = 2.0 * math.log(m) / LN3
        rows.append(
            {
                "scale": X,
                "m": m,
                "D": D,
                "k": kk,
                "l": ll,
                "cells_tested": ntested,
                "C_BH_1e6": C6,
                "C_sieve": C_sieve,
                "n_triggered_carriers": len(trigs),
                "pred_median_avg": med_pred_A,
                "pred_median_sieve": med_pred_S,
                "pred_mean_avg": mean_pred_A,
                "pred_mean_sieve": mean_pred_S,
                "pit_u_avg": uA,
                "pit_v_avg": vA,
                "pit_u_sieve": uS,
                "pit_v_sieve": vS,
                "envelope_2lnm_ln3": envelope,
                "within_envelope": bool(D <= envelope),
            }
        )
        if (i + 1) % 16 == 0:
            print(f"[task1] {i+1}/{len(samples)} ({time.time()-t0:.0f}s)", flush=True)

    # randomized PIT + KS (seeded)
    rng2 = np.random.default_rng(SEED + 7)
    w = rng2.uniform(size=len(rows))
    UA = [r["pit_v_avg"] + wi * (r["pit_u_avg"] - r["pit_v_avg"]) for r, wi in zip(rows, w)]
    US = [r["pit_v_sieve"] + wi * (r["pit_u_sieve"] - r["pit_v_sieve"]) for r, wi in zip(rows, w)]
    ksA, pA = ks_uniform(UA)
    ksS, pS = ks_uniform(US)

    per_scale = []
    for X, n in SCALES:
        sub = [r for r in rows if r["scale"] == X]
        Ds = np.array([r["D"] for r in sub], dtype=float)
        per_scale.append(
            {
                "scale": X,
                "n": len(sub),
                "obs_mean_D": float(Ds.mean()),
                "obs_median_D": float(np.median(Ds)),
                "obs_max_D": int(Ds.max()),
                "obs_min_D": int(Ds.min()),
                "pred_mean_D_avg": float(np.mean([r["pred_mean_avg"] for r in sub])),
                "pred_mean_D_sieve": float(np.mean([r["pred_mean_sieve"] for r in sub])),
                "pred_median_D_avg_mean": float(np.mean([r["pred_median_avg"] for r in sub])),
                "envelope_at_scale": 2.0 * math.log(X) / LN3,
                "all_within_envelope": bool(all(r["within_envelope"] for r in sub)),
                "sqrtlaw_pred_median": float(
                    np.mean([math.sqrt(2 * math.log(2) * math.log(r["m"]) / (3 * r["C_BH_1e6"])) for r in sub])
                ),
            }
        )

    # ---------- BONUS 1d: mass sweep at 10^6 ----------
    tm = time.time()
    rng3 = np.random.default_rng(SEED + 99)
    mass_max = -1
    mass_argmax = None
    hist = {}
    mass_seen = set()
    envelope_violations = []
    n_done = 0
    while n_done < MASS_N:
        m = int(rng3.integers(10**6, 2 * 10**6))
        while math.gcd(m, 6) != 1:
            m += 1
        if m in mass_seen:
            continue
        mass_seen.add(m)
        D, kk, ll, _ = find_D(m, cap=80, reps=25)
        n_done += 1
        hist[D] = hist.get(D, 0) + 1
        if D > mass_max:
            mass_max, mass_argmax = D, (m, kk, ll)
        if D >= 12:  # tail: confirm with independent BPSW
            assert sympy.isprime(m * 2**kk * 3**ll + 1), (m, kk, ll)
        if D > 2.0 * math.log(m) / LN3:
            envelope_violations.append(m)
        if n_done % 10000 == 0:
            print(f"[task1-mass] {n_done}/{MASS_N} max={mass_max} ({time.time()-tm:.0f}s)", flush=True)

    # model plug-in tail from the 40 curves at the 1e6 scale
    sub6 = [r for r in rows if r["scale"] == 10**6]
    lam_curves_6 = []
    for r in sub6:
        m = r["m"]
        trigs = trig_carriers_for_m(m, cq, cd2, cd3, cH)
        lamA, lamS = lambda_curves(m, r["C_BH_1e6"], r["C_sieve"], trigs, 40)
        lam_curves_6.append(lamS)
    lam_stack = np.vstack(lam_curves_6)
    pbar = np.exp(-lam_stack).mean(axis=0)  # mean P(D > d)
    pred_max_quantiles = {}
    for d in range(10, 41):
        pexceed = 1.0 - (1.0 - pbar[d]) ** MASS_N if pbar[d] < 1 else 1.0
        pred_max_quantiles[d] = float(pexceed)

    out = {
        "meta": env_meta(os.path.abspath(__file__)),
        "seed": SEED,
        "derivation": __doc__,
        "ks_avg": {"stat": ksA, "p": pA, "n": len(rows)},
        "ks_sieve": {"stat": ksS, "p": pS, "n": len(rows)},
        "pit_avg_values": UA,
        "pit_sieve_values": US,
        "per_scale": per_scale,
        "rows": rows,
        "mass_sweep": {
            "n": MASS_N,
            "scale": [10**6, 2 * 10**6],
            "histogram_D": {str(k): v for k, v in sorted(hist.items())},
            "max_D": mass_max,
            "argmax": {"m": mass_argmax[0], "k": mass_argmax[1], "l": mass_argmax[2]},
            "envelope_violations": envelope_violations,
            "envelope_at_2e6": 2.0 * math.log(2 * 10**6) / LN3,
            "model_P_maxD_exceeds_d": pred_max_quantiles,
        },
        "runtime_s": round(time.time() - t0, 1),
    }
    with open(OUT, "w") as f:
        json.dump(out, f, indent=1)
    print(
        f"[task1] DONE KS_avg p={pA:.3f} KS_sieve p={pS:.3f} mass_max={mass_max} "
        f"env_viol={len(envelope_violations)} ({out['runtime_s']}s)",
        flush=True,
    )


if __name__ == "__main__":
    main()
