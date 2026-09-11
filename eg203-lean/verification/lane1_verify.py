#!/usr/bin/env python3
"""
LANE 1 verification: kappa_V = 0 claim (sec:kappa of
wilder-2026-V-family-rosser-iwaniec).

Exact-integer computation of H_q = |<2,3> mod q| for all primes
5 <= q <= 10^6, with brute-force method verification for q < 10^4,
plus brute-force local-density g_V cross-checks.

Receipts written next to this script:
  lane1-kappa-sums.json
  lane1-kappa-sums.md

Definitions (from the paper, recomputed from scratch):
  d2 = ord_q(2), d3 = ord_q(3), H_q = |<2,3> mod q| (= lcm(d2,d3),
  verified by explicit subgroup generation below).
  q triggered for m  iff  -m^{-1} mod q in <2,3> mod q
                     iff  pow(-m^{-1}, H_q, q) == 1   (unique subgroup
                     of order H in a cyclic group = H-th roots of unity).
  g_V(q,m) = #{(k mod d2, l mod d3): 2^k 3^l = -m^{-1}} / (d2*d3).
"""

import json
import math
import os
import sys
import time
from math import gcd, lcm, log

from sympy import factorint, n_order

HERE = os.path.dirname(os.path.abspath(__file__))
LIMIT = 10 ** 6
BRUTE_LIMIT = 10 ** 4        # subgroup brute force below this
G_BRUTE_LIMIT = 3000         # g_V per-l brute force below this
G_FULL_LIMIT = 300           # g_V full double-loop brute force below this
MS = [5, 7, 11, 25, 35, 49]  # ordinary m values for triggered sums

T0 = time.time()


def log_msg(s):
    print(f"[{time.time()-T0:7.1f}s] {s}", flush=True)


# ---------------------------------------------------------------- sieve
def spf_sieve(n):
    spf = list(range(n + 1))
    i = 2
    while i * i <= n:
        if spf[i] == i:
            for j in range(i * i, n + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


log_msg("sieving smallest prime factors to 10^6 ...")
SPF = spf_sieve(LIMIT)
PRIMES = [p for p in range(2, LIMIT + 1) if SPF[p] == p]
log_msg(f"{len(PRIMES)} primes <= 10^6")


def factor_via_spf(n):
    fac = {}
    while n > 1:
        p = SPF[n]
        fac[p] = fac.get(p, 0) + 1
        n //= p
    return fac


def mult_order(a, q, qm1_primes):
    """multiplicative order of a mod q, q prime, given prime factors of q-1"""
    e = q - 1
    for p in qm1_primes:
        while e % p == 0 and pow(a, e // p, q) == 1:
            e //= p
    return e


# ------------------------------------------- method verification q < 10^4
def subgroup_order_bruteforce(q):
    """|<2,3> mod q| by explicit closure (cosets of <2> by powers of 3)."""
    base = []
    x = 1
    while True:
        base.append(x)
        x = (x * 2) % q
        if x == 1:
            break
    S = set(base)
    x = 1
    while True:
        x = (x * 3) % q
        if x in S:
            break
        S.update((x * b) % q for b in base)
    return len(S)


log_msg("verifying H_q = lcm(ord_q(2), ord_q(3)) by brute force for q < 10^4 ...")
method_checked = 0
for q in PRIMES:
    if q < 5:
        continue
    if q >= BRUTE_LIMIT:
        break
    fq = list(factor_via_spf(q - 1).keys())
    d2 = mult_order(2, q, fq)
    d3 = mult_order(3, q, fq)
    H_formula = lcm(d2, d3)
    H_bf = subgroup_order_bruteforce(q)
    assert H_formula == H_bf, (q, d2, d3, H_formula, H_bf)
    method_checked += 1
log_msg(f"  PASS: {method_checked} primes, lcm formula == brute-force subgroup order")

# g_V brute force, two independent ways
log_msg("brute-force g_V cross-check (per-l method, q < 3000) ...")
gv_checked = 0
gv_lemma22_violations = 0   # g_V > 1/(d2*d3)  (paper Lemma 2.2 first ineq)
gv_lemma22_H2_violations = 0  # g_V > 1/H^2     (paper Lemma 2.2 second ineq)
gv_equals_1_over_H = 0
smallest_ce = None
for q in PRIMES:
    if q < 5:
        continue
    if q >= G_BRUTE_LIMIT:
        break
    fq = list(factor_via_spf(q - 1).keys())
    d2 = mult_order(2, q, fq)
    d3 = mult_order(3, q, fq)
    H = lcm(d2, d3)
    for m in MS:
        if m % q == 0:
            continue
        t = (-pow(m, -1, q)) % q
        triggered = pow(t, H, q) == 1
        # count solutions in the d2 x d3 period: for each l, c_l = t * 3^{-l};
        # c_l in <2>  iff  c_l^{d2} == 1; then exactly one k.
        inv3 = pow(3, -1, q)
        c = t
        count = 0
        for _ in range(d3):
            if pow(c, d2, q) == 1:
                count += 1
            c = (c * inv3) % q
        expected = (d2 * d3) // H if triggered else 0
        assert count == expected, (q, m, d2, d3, H, triggered, count, expected)
        gv_checked += 1
        if count > 0:
            gv_equals_1_over_H += 1  # g = count/(d2 d3) = 1/H exactly
            # Lemma 2.2 claims  g <= 1/(d2 d3)  i.e. count <= 1
            if count > 1:
                gv_lemma22_violations += 1
            # second claimed ineq  g <= 1/H^2  i.e. count * H^2 <= d2*d3
            if count * H * H > d2 * d3:
                gv_lemma22_H2_violations += 1
                if smallest_ce is None:
                    smallest_ce = dict(q=q, m=m, d2=d2, d3=d3, H=H,
                                       solutions_per_period=count,
                                       g_V=f"{count}/{d2*d3}",
                                       claimed_le=f"1/{d2*d3} and 1/{H*H}")
log_msg(f"  PASS: {gv_checked} (q,m) pairs, g_V == 1_triggered / H_q exactly")
log_msg(f"  Lemma 2.2 violations among triggered pairs: "
        f"g>1/(d2*d3): {gv_lemma22_violations}, g>1/H^2: {gv_lemma22_H2_violations}")

log_msg("brute-force g_V full double-loop (q < 300) ...")
gv_full_checked = 0
for q in PRIMES:
    if q < 5:
        continue
    if q >= G_FULL_LIMIT:
        break
    fq = list(factor_via_spf(q - 1).keys())
    d2 = mult_order(2, q, fq)
    d3 = mult_order(3, q, fq)
    H = lcm(d2, d3)
    pow2 = [pow(2, k, q) for k in range(d2)]
    pow3 = [pow(3, l, q) for l in range(d3)]
    for m in MS:
        if m % q == 0:
            continue
        t = (-pow(m, -1, q)) % q
        count = sum(1 for a in pow2 for b in pow3 if (a * b) % q == t)
        triggered = pow(t, H, q) == 1
        expected = (d2 * d3) // H if triggered else 0
        assert count == expected, (q, m, count, expected)
        gv_full_checked += 1
log_msg(f"  PASS: {gv_full_checked} (q,m) pairs by exhaustive (k,l) double loop")

# ---------------------------------------------------------------- main loop
log_msg("computing H_q for all primes 5 <= q <= 10^6 ...")
CHECKPOINTS = [1000, 1778, 3162, 5623, 10000, 17783, 31623, 56234,
               100000, 177828, 316228, 562341, 1000000]
SCALE = 2 ** 40

acc = dict(S1=0.0, SlogH=0.0, SlogH2=0.0, S1H2=0.0,
           T1_hi=0, T1_lo=0, Tb_hi=0, Tb_lo=0, nprimes=0)
trig = {m: dict(sum_logH=0.0, count=0, nq=0) for m in MS}
snapshots = []
cp_iter = iter(CHECKPOINTS)
next_cp = next(cp_iter)

Hs = []          # parallel to primes >= 5
Qs = []
small_H_list = []   # (q, d2, d3, H) with H <= 100
decade_window = {m: {} for m in MS}   # window sums per decade for defn:kappa attack

for q in PRIMES:
    if q < 5:
        continue
    while q > next_cp:
        snap = dict(z=next_cp, **{k: (v if isinstance(v, int) else round(v, 10))
                                  for k, v in acc.items()})
        snap["trig"] = {m: dict(sum_logH=round(trig[m]["sum_logH"], 8),
                                count=trig[m]["count"]) for m in MS}
        snapshots.append(snap)
        try:
            next_cp = next(cp_iter)
        except StopIteration:
            next_cp = float("inf")
    fq = list(factor_via_spf(q - 1).keys())
    d2 = mult_order(2, q, fq)
    d3 = mult_order(3, q, fq)
    H = lcm(d2, d3)
    Hs.append(H)
    Qs.append(q)
    lq = log(q)
    acc["S1"] += 1.0 / H
    acc["SlogH"] += lq / H
    acc["SlogH2"] += lq / (H * H)
    acc["S1H2"] += 1.0 / (H * H)
    acc["T1_hi"] += -(-SCALE // H)             # ceil(2^40 / H)
    acc["T1_lo"] += SCALE // H
    bits = q.bit_length()
    acc["Tb_hi"] += -(-(SCALE * bits) // H)    # ceil(2^40 * bits / H)
    acc["Tb_lo"] += (SCALE * (bits - 1)) // H
    acc["nprimes"] += 1
    if H <= 100:
        small_H_list.append((q, d2, d3, H))
    dec = len(str(q)) - 1   # q in (10^dec_prev, ...] roughly; use floor(log10)
    for m in MS:
        if m % q == 0:
            continue
        t = (-pow(m, -1, q)) % q
        if pow(t, H, q) == 1:
            trig[m]["sum_logH"] += lq / H
            trig[m]["count"] += 1
            d = int(math.log10(q))
            decade_window[m][d] = decade_window[m].get(d, 0.0) + lq / H
        trig[m]["nq"] += 1

# final snapshot
snap = dict(z=LIMIT, **{k: (v if isinstance(v, int) else round(v, 10))
                        for k, v in acc.items()})
snap["trig"] = {m: dict(sum_logH=round(trig[m]["sum_logH"], 8),
                        count=trig[m]["count"]) for m in MS}
if snapshots[-1]["z"] != LIMIT:
    snapshots.append(snap)
log_msg(f"done: {acc['nprimes']} primes processed")

# ------------------------------------------------------------- slope fits
def lsq(xs, ys):
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    b = sxy / sxx
    a = my - b * mx
    ss_res = sum((y - (a + b * x)) ** 2 for x, y in zip(xs, ys))
    ss_tot = sum((y - my) ** 2 for y in ys)
    r2 = 1 - ss_res / ss_tot if ss_tot > 0 else 1.0
    return b, a, r2


fit_pts = [s for s in snapshots if s["z"] >= 10000]
xs = [log(s["z"]) for s in fit_pts]
fits = {}
fits["SlogH_vs_logz"] = lsq(xs, [s["SlogH"] for s in fit_pts])
fits["S1_vs_loglogz"] = lsq([log(x) for x in xs], [s["S1"] for s in fit_pts])
fits["SlogH2_vs_logz"] = lsq(xs, [s["SlogH2"] for s in fit_pts])
for m in MS:
    fits[f"trig_m{m}_vs_logz"] = lsq(xs, [s["trig"][m]["sum_logH"] for s in fit_pts])

log_msg(f"slope  Sum log q/H_q       vs log z : {fits['SlogH_vs_logz'][0]:.4f}  "
        f"(zeta(2)=1.6449 predicted), R^2={fits['SlogH_vs_logz'][2]:.6f}")
log_msg(f"slope  Sum 1/H_q           vs loglog z : {fits['S1_vs_loglogz'][0]:.4f}")
log_msg(f"slope  Sum log q/H_q^2     vs log z : {fits['SlogH2_vs_logz'][0]:.6f} (0 = converged)")
for m in MS:
    log_msg(f"slope  triggered m={m:<3d} Sum log q/H_q vs log z : "
            f"{fits[f'trig_m{m}_vs_logz'][0]:.4f}")

# ------------------------------------------------------- bucket counts N_j
buckets = {}
for H in Hs:
    j = H.bit_length()  # H in [2^{j-1}, 2^j)
    buckets[j] = buckets.get(j, 0) + 1
NJ = {j: buckets.get(j, 0) for j in range(1, 22)}

# paper eq:dyadic-count claim N_j <= C sqrt(z 2^j); compute implied C
z = float(LIMIT)
lz = log(z)
dyadic_table = []
for j in range(1, 22):
    nj = NJ[j]
    ep_bound_C1 = math.sqrt(z * 2 ** j)
    dyadic_table.append(dict(j=j, H_range=f"[{2**(j-1)},{2**j})", N_j=nj,
                             EP_bound_C1=round(ep_bound_C1, 1),
                             ratio=round(nj / ep_bound_C1, 6) if ep_bound_C1 else None))

# paper Lemma 2.4: #S_small(z) <= C z/(log z)^{2A}
lemma24_table = []
for s in snapshots:
    zz = s["z"]
    lzz = log(zz)
    for A in (1, 2):
        thr = lzz ** A
        cnt = sum(1 for q, H in zip(Qs, Hs) if q <= zz and H < thr)
        lemma24_table.append(dict(z=zz, A=A, threshold=round(thr, 2),
                                  count=cnt,
                                  paper_bound_C1=round(zz / lzz ** (2 * A), 2)))

# ------------------------------- complete census of ALL primes with H <= 64
log_msg("complete census over ALL primes (any size) with H <= 64 via gcd(2^H-1,3^H-1) ...")
census = {}
for H in range(2, 65):
    G = gcd(2 ** H - 1, 3 ** H - 1)
    if G == 1:
        continue
    for r in factorint(G):
        if r <= 3:
            continue
        Hr = lcm(int(n_order(2, r)), int(n_order(3, r)))
        if Hr == H:
            census.setdefault(H, []).append(int(r))
for H in census:
    census[H].sort()
# cross-check against the sieve data
sieve_small = {}
for q, H in zip(Qs, Hs):
    if H <= 64:
        sieve_small.setdefault(H, []).append(q)
for H, lst in sieve_small.items():
    cl = [r for r in census.get(H, []) if r <= LIMIT]
    assert sorted(lst) == cl, (H, lst, cl)
log_msg("  PASS: census (gcd route) agrees with sieve data for q <= 10^6")
F_all = []
running = 0
for y in range(2, 65):
    running += len(census.get(y, []))
    F_all.append(dict(y=y, F=running))

# -------------------------------------- eq:papp-refined falsification table
# per-H form used in eq:F-bound:  M(z,H) <= C z (log z)^{-c0 log z / log2 H}
# witness: p=11 has H=10 (also p=13, H=12) => M(z,10) >= 1 for all z >= 11.
# RHS -> 0 as z -> infty for ANY C, c0 > 0.  Find numeric crossing z*.
def papp_rhs_lt1_threshold(H, c0, C):
    """smallest x = ln z with C z (log z)^{-c0 log z/log2 H} < 1"""
    l2H = math.log2(H)
    x = 2.0
    while x < 1e9:
        # condition: ln C + x - (c0 * x / l2H) * ln(x) < 0
        if math.log(C) + x - (c0 * x / l2H) * math.log(x) < 0:
            return x
        x *= 1.01
    return None


papp_falsification = []
for c0 in (1.0, 0.5, 0.1):
    for C in (1.0, 100.0):
        x = papp_rhs_lt1_threshold(10, c0, C)
        if x is None:
            zstr = "> exp(1e9)"
        elif x < 700:
            zstr = f"{math.exp(x):.3e}"
        else:
            zstr = f"exp({x:.1f}) ~ 10^{x/math.log(10):.0f}"
        papp_falsification.append(dict(
            H=10, witness_prime=11, c0=c0, C=C, z_star=zstr,
            meaning="for z > z_star the claimed bound forces M(z,10) < 1, "
                    "but p=11 gives M(z,10) >= 1: eq:papp-refined FALSE"))

# paper's own F-bound assembly (eq:F-bound) granting C = c0 = 1:
# RHS(z) = z log z * sum_{H=2}^{sqrt z} (1/H) (log z)^{-log z/log2 H}
def f_bound_rhs(zz):
    lzz = log(zz)
    s = 0.0
    Hmax = int(math.isqrt(int(zz)))
    H = 2
    while H <= Hmax:
        s += (1.0 / H) * lzz ** (-(lzz / math.log2(H)))
        H += 1
    return zz * lzz * s


fb_table = [dict(z=f"1e{e}", paper_claims="o(1)",
                 actual_RHS=f"{f_bound_rhs(10**e):.4e}")
            for e in (4, 6, 8)]

# Lemma 2.8 numeric: z (log z)^{-2A} claimed o(1) for A >= 1
lemma28_table = [dict(z=f"1e{e}", A=A,
                      value=f"{10**e * log(10**e)**(-2*A):.4e}")
                 for e in (4, 6, 9, 12) for A in (1, 2)]

# ---------------------------------------------------- gcd tail census
log_msg("tail census: gcd(2^H-1, 3^H-1) for H in [20, 2000] ...")
tail_sum_logG_H2 = 0.0
tail_sum_logG_H = 0.0
max_ratio = (0.0, None)
big_gcds = []
for H in range(20, 2001):
    G = gcd(2 ** H - 1, 3 ** H - 1)
    if G == 1:
        continue
    lG = math.log(G)
    tail_sum_logG_H2 += lG / (H * H)
    tail_sum_logG_H += lG / H
    r = lG / H
    if r > max_ratio[0]:
        max_ratio = (r, H)
    if G.bit_length() >= 40:
        big_gcds.append(dict(H=H, bits=G.bit_length()))
log_msg(f"  sum_{{H=20}}^{{2000}} log gcd / H^2 = {tail_sum_logG_H2:.6f}")
log_msg(f"  max log gcd / H on [20,2000] = {max_ratio[0]:.4f} at H={max_ratio[1]}")

# certified tail bound for Sum_{q>10^6} log q / H_q^2 :
# every q with H_q = H divides gcd(2^H-1,3^H-1), distinct q multiply in,
# so Sum_{H_q=H} log q <= log gcd(2^H-1,3^H-1).  q>10^6 forces H >= 20
# (H_q > log2 q).  Hence tail <= sum_{H>=20} log gcd / H^2; the H<=2000
# part is the number above; H>2000 needs a gcd bound (NOT available
# unconditionally -- this is exactly the paper's L1 dependency).

# ---------------------------------------------------- certified rationals
final = snapshots[-1]
# Sum 1/H_q <= T1_hi / 2^40 ; >= T1_lo / 2^40
# Sum log q/H_q <= (710/1024) * Tb_hi / 2^40 ; >= (709/1024)*Tb_lo/2^40
# (log 2 = 0.6931471... ; 709/1024 = 0.69238... <= log2 <= 710/1024 = 0.69336)
cert = {}
for s in snapshots:
    if s["z"] in (10000, 100000, 1000000):
        zz = s["z"]
        cert[str(zz)] = dict(
            nprimes=s["nprimes"],
            T1_hi=s["T1_hi"], T1_lo=s["T1_lo"], Tb_hi=s["Tb_hi"], Tb_lo=s["Tb_lo"],
            sum_1_over_H_upper=f"{s['T1_hi']}/2^40 = {s['T1_hi']/SCALE:.9f}",
            sum_1_over_H_lower=f"{s['T1_lo']}/2^40 = {s['T1_lo']/SCALE:.9f}",
            sum_logq_over_H_upper=f"(710*{s['Tb_hi']})/(1024*2^40) = "
                                  f"{710*s['Tb_hi']/(1024*SCALE):.9f}",
            sum_logq_over_H_lower=f"(709*{s['Tb_lo']})/(1024*2^40) = "
                                  f"{709*s['Tb_lo']/(1024*SCALE):.9f}",
            float_sum_1_over_H=s["S1"], float_sum_logq_over_H=s["SlogH"],
            float_sum_logq_over_H2=s["SlogH2"], float_sum_1_over_H2=s["S1H2"])

# sanity: float inside certified bracket
for zz, c in cert.items():
    s = [x for x in snapshots if str(x["z"]) == zz][0]
    assert c["T1_lo"] / SCALE <= s["S1"] <= c["T1_hi"] / SCALE
    assert 709 * c["Tb_lo"] / (1024 * SCALE) <= s["SlogH"] <= 710 * c["Tb_hi"] / (1024 * SCALE)
log_msg("  PASS: float sums lie inside certified rational brackets")

# ------------------------------------------------------------- write JSON
out = dict(
    lane="LANE 1 -- kappa_V = 0 (L1), sums Sum log q/H_q and Sum 1/H_q",
    generated=time.strftime("%Y-%m-%d %H:%M:%S"),
    limit=LIMIT,
    definitions=dict(
        H_q="|<2,3> mod q| = lcm(ord_q(2), ord_q(3)) [verified by brute-force "
            f"subgroup generation for all {method_checked} primes 5<=q<10^4]",
        trigger="q triggered for m iff (-m^{-1})^{H_q} == 1 mod q",
        g_V="exact value: 1/H_q if triggered else 0 [verified on "
            f"{gv_checked}+{gv_full_checked} (q,m) pairs, two independent methods]"),
    method_verification=dict(
        lcm_formula_vs_bruteforce_subgroup=f"PASS {method_checked} primes",
        gV_per_l_method=f"PASS {gv_checked} pairs (q<3000)",
        gV_full_double_loop=f"PASS {gv_full_checked} pairs (q<300)",
        lemma22_first_ineq_violations_g_gt_1_over_d2d3=gv_lemma22_violations,
        lemma22_second_ineq_violations_g_gt_1_over_H2=gv_lemma22_H2_violations,
        triggered_pairs_with_g_equal_1_over_H=gv_equals_1_over_H,
        smallest_lemma22_counterexample=smallest_ce),
    partial_sums=snapshots,
    decade_window_sums_triggered=
        {m: {f"10^{d}..10^{d+1}": round(v, 4)
             for d, v in sorted(decade_window[m].items())} for m in MS},
    slope_fits={k: dict(slope=round(v[0], 6), intercept=round(v[1], 6),
                        R2=round(v[2], 8)) for k, v in fits.items()},
    bucket_counts_Nj_at_1e6=dyadic_table,
    lemma24_small_H_counts=lemma24_table,
    small_H_primes_up_to_1e6=[dict(q=q, d2=d2, d3=d3, H=H)
                              for q, d2, d3, H in small_H_list],
    census_all_primes_H_le_64=dict(
        note="COMPLETE list of ALL primes (any size) with H_p <= 64, via "
             "factoring gcd(2^H-1, 3^H-1): any p with H_p=H divides it.",
        by_H={str(H): v for H, v in sorted(census.items())},
        F_cumulative=F_all),
    papp_refined_falsification=dict(
        statement="eq:papp-refined / per-H form M(z,H) <= C z (log z)^{-c0 log z/log2 H} "
                  "is FALSE for every C, c0 > 0: fixed witness p=11 (H=10) makes "
                  "M(z,10)>=1 for all z>=11 while RHS -> 0.",
        thresholds=papp_falsification,
        f_bound_assembly_blowup=fb_table,
        lemma28_value_called_o1=lemma28_table),
    gcd_tail=dict(
        certified_inequality="Sum_{q>10^6} log q / H_q^2 <= Sum_{H>=20} "
                             "log gcd(2^H-1,3^H-1) / H^2  (exact: distinct q with "
                             "H_q=H multiply into the gcd; H_q > log2 q > 19.9)",
        partial_H20_2000=round(tail_sum_logG_H2, 6),
        sum_logG_over_H_H20_2000=round(tail_sum_logG_H, 4),
        max_logG_over_H=dict(value=round(max_ratio[0], 4), at_H=max_ratio[1]),
        gcds_with_40plus_bits=big_gcds,
        unconditional_gap="for H>2000 only log gcd <= H log 2 is elementary, "
                          "giving a DIVERGENT majorant Sum log2/H; closing the "
                          "tail needs an index-distribution / gcd input -- this "
                          "is the honest residue of the paper's L1."),
    certified_rational_bounds=cert,
)
with open(os.path.join(HERE, "lane1-kappa-sums.json"), "w") as f:
    json.dump(out, f, indent=1)
log_msg("wrote lane1-kappa-sums.json")
log_msg("ALL ASSERTIONS PASSED")
