# -*- coding: utf-8 -*-
"""
LANE 4 verification: §6 almost-prime -> prime conversion (sec:almost-prime)
of wilder-2026-V-family-rosser-iwaniec.tex, plus the §4 Brun output it
consumes (eq:S-bound-DD) and the §6 asymptotic claim (eq:asymp-sieve).

Everything exact-integer where possible. Ground truth for local densities
(per Lane 0, re-derived here): for prime p ∤ 6m, H_p = lcm(ord_p(2), ord_p(3));
p is TRIGGERED for m iff (-m^{-1} mod p) is in the subgroup <2,3> mod p,
equivalently pow(-m^{-1}, H_p, p) == 1; if triggered, the density of cells
(k,l) with p | V(m,k,l) is exactly 1/H_p per (ord2 x ord3) period.

Outputs:
  lane4-almost-prime-receipts.json
  lane4-almost-prime-receipts.md
"""
import json, math, os, sys, time
from sympy import isprime

T0 = time.time()
OUTDIR = r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification"
M_LIST = [5, 35, 65, 95, 115]
D_LIST = [30, 60, 100]
LOG6 = math.log(6.0)

# ---------------------------------------------------------------
# 1. prime infrastructure: SPF sieve to 1e6, orders, H_p, triggers
# ---------------------------------------------------------------
LIM = 10**6
spf = list(range(LIM + 1))
i = 2
while i * i <= LIM:
    if spf[i] == i:
        for j in range(i * i, LIM + 1, i):
            if spf[j] == j:
                spf[j] = i
    i += 1
PRIMES = [p for p in range(2, LIM + 1) if spf[p] == p]
print(f"[{time.time()-T0:6.1f}s] sieve done, {len(PRIMES)} primes <= 1e6", flush=True)

def distinct_prime_factors(n):
    out = []
    while n > 1:
        q = spf[n]
        out.append(q)
        while n % q == 0:
            n //= q
    return out

def mult_order(a, p, pm1_factors):
    n = p - 1
    for q in pm1_factors:
        while n % q == 0 and pow(a, n // q, p) == 1:
            n //= q
    return n

# ---------------------------------------------------------------
# 2. C_BH(m) partial products, paper-S(m) partial products,
#    sum of 1_trig/H_p, all to 1e6 with checkpoints.
#    C_BH(m)   = prod_{3<p<=P} f_p,
#       f_p = (1 - 1/H_p)/(1 - 1/p)  if p triggered for m
#           = 1/(1 - 1/p)            if p not triggered or p | m
#    S_paper(m)= prod_{3<p<=P, trig} (1 - p/((p-1) H_p))   [eq:S-defn]
# ---------------------------------------------------------------
CHECKPOINTS = [10**3, 10**4, 10**5, 10**6]
logC = {m: 0.0 for m in M_LIST}
logS = {m: 0.0 for m in M_LIST}
sum_invH = {m: 0.0 for m in M_LIST}
CBH_partial = {m: {} for m in M_LIST}
Spaper_partial = {m: {} for m in M_LIST}
sum_invH_partial = {m: {} for m in M_LIST}
Hdata_small = {}          # p <= 1e4 -> H_p
trig_small = {m: {} for m in M_LIST}   # p <= 1e4 -> bool

cp_idx = 0
for p in PRIMES:
    if p <= 3:
        continue
    while cp_idx < len(CHECKPOINTS) and p > CHECKPOINTS[cp_idx]:
        for m in M_LIST:
            CBH_partial[m][CHECKPOINTS[cp_idx]] = math.exp(logC[m])
            Spaper_partial[m][CHECKPOINTS[cp_idx]] = math.exp(logS[m])
            sum_invH_partial[m][CHECKPOINTS[cp_idx]] = sum_invH[m]
        cp_idx += 1
    fac = distinct_prime_factors(p - 1)
    d2 = mult_order(2, p, fac)
    d3 = mult_order(3, p, fac)
    H = d2 * d3 // math.gcd(d2, d3)   # lcm = |<2,3>| in cyclic group
    if p <= 10**4:
        Hdata_small[p] = H
    base = -math.log(1.0 - 1.0 / p)   # log of 1/(1-1/p)
    for m in M_LIST:
        if m % p == 0:
            trig = False
        else:
            t = (-pow(m, -1, p)) % p
            trig = (pow(t, H, p) == 1)
        if p <= 10**4:
            trig_small[m][p] = trig
        if trig:
            logC[m] += math.log(1.0 - 1.0 / H) + base
            logS[m] += math.log(1.0 - p / ((p - 1.0) * H))
            sum_invH[m] += 1.0 / H
        else:
            logC[m] += base
for cp in CHECKPOINTS[cp_idx:]:
    for m in M_LIST:
        CBH_partial[m][cp] = math.exp(logC[m])
        Spaper_partial[m][cp] = math.exp(logS[m])
        sum_invH_partial[m][cp] = sum_invH[m]
print(f"[{time.time()-T0:6.1f}s] C_BH / S_paper partials done", flush=True)

# ---------------------------------------------------------------
# 3. Box analysis per (m, D)
# ---------------------------------------------------------------
PRIMES_1e4 = [p for p in PRIMES if p <= 10**4]
PRIMES_1e3 = [p for p in PRIMES if p <= 10**3]

def analyze_box(m, D):
    z1 = D ** (1.0 / 3.0)
    trial_limit = 10**4 if D >= 100 else 10**3
    trial_primes = PRIMES_1e4 if D >= 100 else PRIMES_1e3
    cells = []
    pow3 = [1] * (D + 1)
    for l in range(1, D + 1):
        pow3[l] = pow3[l - 1] * 3
    for k in range(0, D + 1):
        mk = m << k  # m * 2^k
        for l in range(0, D + 1 - k):
            cells.append((k, l, mk * pow3[l] + 1))
    X = len(cells)
    assert X == (D + 1) * (D + 2) // 2

    # smallest prime factor <= trial_limit (0 = none found)
    n = X
    spf_arr = [0] * n
    for p in trial_primes:
        # V mod p, incremental
        m_mod = m % p
        inv_found = 0
        idx = 0
        two_k = 1
        for k in range(0, D + 1):
            base_k = (m_mod * two_k) % p
            v = base_k  # = m*2^k*3^0 mod p
            for l in range(0, D + 1 - k):
                if (v + 1) % p == 0 and spf_arr[idx] == 0:
                    spf_arr[idx] = p
                idx += 1
                v = (v * 3) % p
            two_k = (two_k * 2) % p
    # mark V itself prime <= trial_limit (spf == V): trial division catches p==V
    # (handled automatically: if V <= trial_limit and prime, p=V divides V)

    # primality flags
    prime_flag = [False] * n
    n_isprime_calls = 0
    for i2, (k, l, V) in enumerate(cells):
        s = spf_arr[i2]
        if s == 0:
            n_isprime_calls += 1
            prime_flag[i2] = bool(isprime(V))
        elif s == V:
            prime_flag[i2] = True
        # else composite
    piV = sum(prime_flag)

    # eligibility (lane convention z1 sieve = {2,3} since z1 < 5)
    elig = [spf_arr[i2] not in (2, 3) for i2 in range(n)]
    N0 = sum(elig)
    rough_prime = sum(1 for i2 in range(n) if elig[i2] and prime_flag[i2])
    rough_comp = N0 - rough_prime
    assert rough_prime == piV  # primes always coprime to 6 here (V>=6)

    # mid-prime divisor lists, p in [5, 2D]
    mid_primes = [p for p in PRIMES if 5 <= p <= 2 * D]
    divlists = [[] for _ in range(n)]
    for p in mid_primes:
        m_mod = m % p
        if m_mod == 0:
            continue  # p | m => V ≡ 1 mod p, never divides
        idx = 0
        two_k = 1
        for k in range(0, D + 1):
            v = (m_mod * two_k) % p
            for l in range(0, D + 1 - k):
                if (v + 1) % p == 0:
                    divlists[idx].append(p)
                idx += 1
                v = (v * 3) % p
            two_k = (two_k * 2) % p

    # Theorem 6.1 (thm:buchstab) test for z2 = cD, c in {0.5, 1, 2}
    thm61 = []
    for cc in (0.5, 1.0, 2.0):
        z2 = int(cc * D)
        # paper convention: P_{z1} = primes in (3, z1], empty since z1 < 5
        S_z1_paper = X
        S_z1_lane = N0
        sum_SAp_paper = 0
        sum_SAp_lane = 0
        per_p = {}
        for p in mid_primes:
            if p > z2:
                break
            cnt_all = 0
            cnt_elig = 0
            for i2 in range(n):
                if p in divlists[i2]:
                    cnt_all += 1
                    if elig[i2]:
                        cnt_elig += 1
            per_p[p] = cnt_all
            sum_SAp_paper += cnt_all
            sum_SAp_lane += cnt_elig
        RHS_paper = S_z1_paper - sum_SAp_paper
        RHS_lane = S_z1_lane - sum_SAp_lane
        # true z2-rough counts
        S_z2_paper = sum(1 for i2 in range(n)
                         if not any(q <= z2 for q in divlists[i2]))
        S_z2_lane = sum(1 for i2 in range(n)
                        if elig[i2] and not any(q <= z2 for q in divlists[i2])
                        and not (spf_arr[i2] != 0 and spf_arr[i2] <= z2))
        primes_le_z2 = sum(1 for i2 in range(n)
                           if prime_flag[i2] and cells[i2][2] <= z2)
        thm61.append({
            "c": cc, "z2": z2,
            "S_z1_paper(=X, P_z1 empty)": S_z1_paper,
            "S_z1_lane(no factor 2,3)": S_z1_lane,
            "sum_S_Ap_paper": sum_SAp_paper,
            "sum_S_Ap_lane": sum_SAp_lane,
            "RHS_paper": RHS_paper,
            "RHS_lane": RHS_lane,
            "pi_V": piV,
            "thm61_holds_paper(pi_V>=RHS)": bool(piV >= RHS_paper),
            "thm61_holds_lane(pi_V>=RHS)": bool(piV >= RHS_lane),
            "RHS_paper_over_piV": (RHS_paper / piV) if piV else None,
            "S_z2_rough_paper": S_z2_paper,
            "S_z2_rough_lane": S_z2_lane,
            "primes_among_V_le_z2": primes_le_z2,
            "per_p_counts_S_Ap_paper": per_p,
        })

    # sum 1/log V over eligible cells; per-diagonal stats
    sum_invlogV = 0.0
    diag = {}
    for i2, (k, l, V) in enumerate(cells):
        t = k + l
        d = diag.setdefault(t, {"cells": 0, "elig": 0, "primes": 0,
                                "sum_invlogV_elig": 0.0})
        d["cells"] += 1
        if elig[i2]:
            d["elig"] += 1
            lv = 1.0 / math.log(V)
            d["sum_invlogV_elig"] += lv
            sum_invlogV += lv
        if prime_flag[i2]:
            d["primes"] += 1

    # predictions
    CBH = CBH_partial[m][10**6]
    Sp6 = Spaper_partial[m][10**6]
    logmax = math.log(m) + D * LOG6
    paper_thm_main_bound = 0.25 * 6.6e-4 * D                      # c * c0 * D
    paper_brun_DD_bound = (0.999 / 2.0) * 6.6e-4 * D * D          # eq:S-bound-DD w/ c0
    paper_asymp_c0 = X * 6.6e-4 / logmax                          # eq:asymp-sieve w/ c0
    paper_asymp_Spartial = X * Sp6 / logmax                       # eq:asymp-sieve w/ S_paper(1e6)
    corrected_BH_pred = 3.0 * CBH * sum_invlogV                   # renormalized BH heuristic

    rough_at_z1_paper = X      # P_{z1} empty
    pred_rough_z1_paper = X    # X * W(z1), W = empty product = 1

    return {
        "m": m, "D": D, "z1=D^(1/3)": round(z1, 4),
        "sieving_primes_le_z1_paper_convention(3<p<=z1)": [],
        "sieving_primes_le_z1_lane_convention(p<=z1)": [2, 3],
        "X=|T_D|": X,
        "counts": {
            "pi_V_exact": piV,
            "sifted_by_{2,3}": X - N0,
            "rough_lane_S(A,z1)": N0,
            "rough_lane_primes": rough_prime,
            "rough_lane_composites": rough_comp,
            "rough_paper_S(A,P_z1,z1)": rough_at_z1_paper,
            "prime_fraction_among_rough_lane": rough_prime / N0,
        },
        "rough_vs_XW_prediction": {
            "paper_W(z1)": 1.0,
            "paper_pred_X*W(z1)": pred_rough_z1_paper,
            "actual_rough_paper": rough_at_z1_paper,
            "note": "z1=D^(1/3)<5 for all tested D, so the paper's sieving set P_z1={3<p<=z1, p∤m} is EMPTY; the Brun stage sifts nothing at these scales.",
        },
        "eq_S_bound_DD_check": {
            "claimed_lower_bound_with_c0": paper_brun_DD_bound,
            "actual_S_lane": N0, "actual_S_paper": X,
            "holds": bool(min(N0, X) >= paper_brun_DD_bound),
            "slack_factor": min(N0, X) / paper_brun_DD_bound,
        },
        "thm61_buchstab_tests": thm61,
        "asymp_sieve_eq_asymp": {
            "actual_pi_V": piV,
            "paper_thm_main_c_c0_D": paper_thm_main_bound,
            "paper_eq_asymp_with_c0_6.6e-4": paper_asymp_c0,
            "paper_eq_asymp_with_Spaper_partial_1e6": paper_asymp_Spartial,
            "S_paper_partial_1e6": Sp6,
            "corrected_BH_pred_3*C_BH*sum_invlogV": corrected_BH_pred,
            "C_BH_partial_1e6": CBH,
            "sum_invlogV_elig": sum_invlogV,
            "ratio_actual_over_corrected": piV / corrected_BH_pred,
            "ratio_actual_over_paper_asymp_c0": piV / paper_asymp_c0,
        },
        "per_diagonal": {str(t): {
            "cells": diag[t]["cells"], "elig": diag[t]["elig"],
            "primes": diag[t]["primes"],
            "pred_3CBH_sum_invlogV": 3.0 * CBH * diag[t]["sum_invlogV_elig"],
        } for t in sorted(diag)},
        "_internals": {"spf": spf_arr, "elig": elig,
                       "prime_flag": prime_flag, "trial_limit": trial_limit},
        "n_isprime_calls": n_isprime_calls,
    }

results = []
zcurves = {}
for m in M_LIST:
    for D in D_LIST:
        r = analyze_box(m, D)
        print(f"[{time.time()-T0:6.1f}s] m={m} D={D}: pi_V={r['counts']['pi_V_exact']} "
              f"rough={r['counts']['rough_lane_S(A,z1)']} "
              f"corrected_pred={r['asymp_sieve_eq_asymp']['corrected_BH_pred_3*C_BH*sum_invlogV']:.1f}",
              flush=True)
        # z-curve for D=100 (kappa discriminant)
        if D == 100:
            spf_a = r["_internals"]["spf"]
            elig_a = r["_internals"]["elig"]
            pf_a = r["_internals"]["prime_flag"]
            N0 = sum(elig_a)
            curve = []
            for z in (5, 10, 30, 100, 300, 1000, 3000, 10000):
                S_z = sum(1 for i2 in range(len(spf_a))
                          if (spf_a[i2] == 0 or spf_a[i2] > z))
                P_z = sum(1 for i2 in range(len(spf_a))
                          if (spf_a[i2] == 0 or spf_a[i2] > z) and pf_a[i2])
                lw = 0.0
                for p, H in Hdata_small.items():
                    if p <= z and trig_small[m].get(p, False):
                        lw += math.log(1.0 - 1.0 / H)
                Wz = math.exp(lw)
                curve.append({
                    "z": z, "S_lane_z_rough": S_z,
                    "primes_among_z_rough": P_z,
                    "prime_fraction": P_z / S_z if S_z else None,
                    "W_pred(prod_{3<p<=z}(1-1_trig/H))": Wz,
                    "pred_count_N0*W": N0 * Wz,
                    "actual_over_pred": S_z / (N0 * Wz),
                    "W_times_log_z": Wz * math.log(z),
                })
            zcurves[str(m)] = curve
        del r["_internals"]
        results.append(r)

# ---------------------------------------------------------------
# 4. Write receipts
# ---------------------------------------------------------------
out = {
    "lane": "LANE 4 — §6 almost-prime separation / rough->prime conversion",
    "date": "2026-06-10",
    "definitions": {
        "V": "m*2^k*3^l+1", "T_D": "k,l>=0, k+l<=D",
        "z1": "D^(1/3)", "ground_truth_gV": "1/H_p if triggered else 0, H_p=lcm(ord_p2,ord_p3)",
        "lane_rough": "no prime factor <= z (includes 2,3)",
        "paper_rough": "gcd(V, P(z))=1 with P(z)=prod primes in (3,z], p∤m (paper §4 eq:S-sieve-defn)",
        "C_BH": "prod_{3<p<=P} (1-1_trig/H_p)/(1-1/p), the Bateman-Horn renormalized singular series",
        "corrected_prediction": "pi_V ≈ 3*C_BH(m)*sum_{cells, 2∤V, 3∤V} 1/log V  (factor 3 = local factors at p=2 and p=3 on eligible cells: 2 * 3/2)",
    },
    "CBH_partials": CBH_partial,
    "Spaper_partials": Spaper_partial,
    "Spaper_partials_times_logP": {
        str(m): {str(P): Spaper_partial[m][P] * math.log(P) for P in CHECKPOINTS}
        for m in M_LIST},
    "sum_1trig_over_H_partials": sum_invH_partial,
    "boxes": results,
    "z_curves_D100": zcurves,
    "runtime_seconds": round(time.time() - T0, 1),
}
with open(os.path.join(OUTDIR, "lane4-almost-prime-receipts.json"), "w") as f:
    json.dump(out, f, indent=1, default=str)
print(f"[{time.time()-T0:6.1f}s] JSON written", flush=True)
