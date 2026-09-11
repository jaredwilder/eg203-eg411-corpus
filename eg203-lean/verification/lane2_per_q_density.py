"""
LANE 2 — PER-q LOCAL DENSITY verification for the EG#203 preprint
wilder-2026-V-family-rosser-iwaniec.tex, Section 3, Lemma 3.2 (lem:per-q).

Exact-integer ground truth for the local density of q | V(m,k,l),
V(m,k,l) = m*2^k*3^l + 1, ordinary m (gcd(m,6)=1), prime q with q∤6m.

Definitions (recomputed from scratch, trusting nothing):
  d2 = ord_q(2), d3 = ord_q(3)
  H_q = |<2,3> mod q|   (computed BOTH as explicit subgroup closure for q<=300
                         AND as lcm(d2,d3); (Z/q)^x is cyclic so they agree)
  q triggered for m  <=>  -m^{-1} mod q is in <2,3> mod q
  Per (d2,d3)-period solution count of 2^k*3^l = -m^{-1} (mod q):
      claim under test:  = d2*d3/H_q = gcd(d2,d3) if triggered, else 0
      => density = 1/H_q   (paper's Lemma 3.2 says 1/H_q^2; Lemma 2.2 says <= 1/(d2*d3) <= 1/H^2)

PART A: per-period exact counts, all primes 3 < q <= 5000, 10 ordinary m
        (fast method: per-row <2>-membership; each solvable row has exactly one
         k mod d2 because 2^k = c has <= 1 solution mod d2 — elementary, and
         independently confirmed by full brute force in PART A2).
PART A2: full brute-force double loop over [0,d2)x[0,d3) for q <= 200, 3 m values.
PART B: exact T_D counts + discrepancy E_V(D,q,0) against the THREE candidate
        main terms in the paper:
          MT_corr  = |T_D| / H          (corrected; ours)
          MT_h2    = |T_D| / H^2        (Lemma 3.2 "expected count")
          MT_overq = |T_D| / (q*H)      (eq:E-defn literal: (g/q)*|T_D| with true g=1/H)
PART C: BV-sum strengthening receipt: sum of |E_corr| over primes q <= Q at D=3000
        vs the required D^2/(log D)^A.
PART D: downstream chain with corrected exponent: kappa slope of
        sum_{p<=z} g_V(p) log p with g_V = 1/H (triggered), and
        W(z) = prod_{3<p<=z, triggered} (1 - 1/H_p):  is W(z) bounded below (paper)
        or ~ C/log z (kappa=1 Mertens)?  Checkpoints z = 1e3,1e4,1e5,1e6.

All counts exact integers; discrepancies via fractions.Fraction.
Receipts -> lane2-per-q-density-receipts.json + lane2-per-q-density.md
"""

import json
import math
import time
from fractions import Fraction
from math import gcd, log

from sympy import primerange, factorint

OUTDIR = r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification"

T0 = time.time()


def order_mod(a, q, fac):
    """Multiplicative order of a mod prime q, given factorization dict of q-1."""
    o = q - 1
    for p in fac:
        while o % p == 0 and pow(a, o // p, q) == 1:
            o //= p
    return o


def lcm(a, b):
    return a // gcd(a, b) * b


# ----------------------------------------------------------------------------
# PART A — per-period exact counts: q prime in (3, 5000], 10 ordinary m
# ----------------------------------------------------------------------------
M_LIST = [1, 5, 7, 25, 35, 143, 1001, 6257518159, 10**12 + 7, 10**18 + 9]
for m in M_LIST:
    assert gcd(m, 6) == 1, f"m={m} not ordinary"

primes = list(primerange(5, 5001))

rows = []
mismatches = []
subgroup_lcm_fail = []
trig_count = 0
pair_count = 0
density_paper_h2_violations = 0  # cases where true count > d2*d3/H^2 (paper Lemma 2.2/3.2 ceiling)
min_H_factor = None  # the factor by which paper density is off = H (collect stats)
H_factors = []

for q in primes:
    fac = factorint(q - 1)
    d2 = order_mod(2, q, fac)
    d3 = order_mod(3, q, fac)
    H = lcm(d2, d3)

    # explicit subgroup closure check for q <= 300 (H really is |<2,3>|)
    if q <= 300:
        elems2 = []
        x = 1
        for _ in range(d2):
            elems2.append(x)
            x = x * 2 % q
        allset = set()
        y = 1
        for _ in range(d3):
            allset.update(e * y % q for e in elems2)
            y = y * 3 % q
        if len(allset) != H:
            subgroup_lcm_fail.append(q)

    pow2set = set()
    x = 1
    for _ in range(d2):
        pow2set.add(x)
        x = x * 2 % q
    inv3 = pow(3, -1, q)

    for m in M_LIST:
        if m % q == 0:
            continue
        pair_count += 1
        t = (-pow(m, -1, q)) % q  # -m^{-1} mod q
        trig = pow(t, H, q) == 1  # subgroup of cyclic group = {x : x^H = 1}

        # exact per-period count: for each l in [0,d3), c_l = t*3^{-l};
        # 2^k = c_l has exactly one k in [0,d2) iff c_l in <2>, else none.
        c = t
        cnt = 0
        for _ in range(d3):
            if c in pow2set:
                cnt += 1
            c = c * inv3 % q

        pred = gcd(d2, d3) if trig else 0  # = d2*d3/H
        ok = (cnt == pred)
        # triggered consistency: count>0 <=> triggered
        ok2 = (cnt > 0) == trig
        if trig:
            trig_count += 1
            H_factors.append(H)
            # paper ceiling: d2*d3/H^2 (often < 1); true count = d2*d3/H
            if cnt * H * H > d2 * d3:  # cnt > d2*d3/H^2
                density_paper_h2_violations += 1
        if not (ok and ok2):
            mismatches.append(dict(q=q, m=str(m), d2=d2, d3=d3, H=H,
                                   triggered=trig, count=cnt, predicted=pred))
        rows.append(dict(q=q, m=str(m), d2=d2, d3=d3, H=H, gcd_d2_d3=gcd(d2, d3),
                         triggered=int(trig), count_period=cnt,
                         predicted_d2d3_over_H=pred))

print(f"[A] pairs={pair_count} triggered={trig_count} mismatches={len(mismatches)} "
      f"subgroup_lcm_fail={subgroup_lcm_fail} paper_h2_ceiling_violations={density_paper_h2_violations} "
      f"({time.time()-T0:.1f}s)")

# ----------------------------------------------------------------------------
# PART A2 — independent full brute force, q <= 200, m in {5, 35, 6257518159}
# ----------------------------------------------------------------------------
bf_mismatch = []
bf_pairs = 0
for q in [p for p in primes if p <= 200]:
    fac = factorint(q - 1)
    d2 = order_mod(2, q, fac)
    d3 = order_mod(3, q, fac)
    pw2 = [pow(2, k, q) for k in range(d2)]
    pw3 = [pow(3, l, q) for l in range(d3)]
    for m in [5, 35, 6257518159]:
        if m % q == 0:
            continue
        bf_pairs += 1
        mm = m % q
        cnt_bf = sum(1 for k in range(d2) for l in range(d3)
                     if (mm * pw2[k] * pw3[l] + 1) % q == 0)
        # fast-method row for same (q,m)
        row = next(r for r in rows if r["q"] == q and r["m"] == str(m))
        if cnt_bf != row["count_period"]:
            bf_mismatch.append(dict(q=q, m=str(m), brute=cnt_bf, fast=row["count_period"]))
print(f"[A2] brute-force pairs={bf_pairs} mismatches={len(bf_mismatch)} ({time.time()-T0:.1f}s)")

# ----------------------------------------------------------------------------
# PART B — exact T_D discrepancies against the three candidate main terms
# ----------------------------------------------------------------------------
QLIST = [7, 23, 73, 251, 601, 1009, 2003, 4999]
DLIST = [300, 3000]
MB_LIST = [5, 7, 6257518159]


def exact_TD_count(q, m, D, d2, d3):
    """Exact #{(k,l) in T_D : q | V(m,k,l)} via per-row discrete log."""
    dlog2 = {}
    x = 1
    for k in range(d2):
        dlog2[x] = k
        x = x * 2 % q
    t = (-pow(m, -1, q)) % q
    inv3 = pow(3, -1, q)
    c = t
    # we need c_l for l = 0..D; reduce l mod d3 by cycling c
    cnt = 0
    cl = t
    for l in range(D + 1):
        k0 = dlog2.get(cl)
        if k0 is not None and k0 <= D - l:
            cnt += (D - l - k0) // d2 + 1
        cl = cl * inv3 % q
    return cnt


td_rows = []
for q in QLIST:
    fac = factorint(q - 1)
    d2 = order_mod(2, q, fac)
    d3 = order_mod(3, q, fac)
    H = lcm(d2, d3)
    for m in MB_LIST:
        if m % q == 0:
            continue
        t = (-pow(m, -1, q)) % q
        trig = pow(t, H, q) == 1
        for D in DLIST:
            cnt = exact_TD_count(q, m, D, d2, d3)
            TD = Fraction((D + 1) * (D + 2), 2)
            if trig:
                mt_corr = TD / H
                mt_h2 = TD / (H * H)
                mt_overq = TD / (q * H)
            else:
                mt_corr = mt_h2 = mt_overq = Fraction(0)
            e_corr = float(cnt - mt_corr)
            e_h2 = float(cnt - mt_h2)
            e_overq = float(cnt - mt_overq)
            etk_ratio = (abs(e_corr) * H / (D * max(1.0, log(H)))) if trig else 0.0
            td_rows.append(dict(q=q, m=str(m), D=D, d2=d2, d3=d3, H=H,
                                triggered=int(trig), count_TD=cnt,
                                MT_corr=float(mt_corr), E_corr=round(e_corr, 3),
                                MT_h2=float(mt_h2), E_h2=round(e_h2, 3),
                                MT_overq=float(mt_overq), E_overq=round(e_overq, 3),
                                abs_E_corr_over_D=round(abs(e_corr) / (D + 1), 4),
                                ETK_ratio_H_absE_over_DlogH=round(etk_ratio, 3)))
print(f"[B] T_D rows={len(td_rows)} ({time.time()-T0:.1f}s)")

# ----------------------------------------------------------------------------
# PART C — BV-sum strengthening: sum |E_corr| over primes q <= Q, D = 3000, m = 5
# ----------------------------------------------------------------------------
D = 3000
m = 5
sumE_sqrt = Fraction(0)   # Q = floor(D^{1/2}) = 54
sumE_1000 = Fraction(0)   # Q = 1000  (illustrating level D^{1-eps})
nq_sqrt = nq_1000 = 0
maxE = (0.0, None)
for q in primes:
    if q > 1000:
        break
    if m % q == 0:
        continue
    fac = factorint(q - 1)
    d2 = order_mod(2, q, fac)
    d3 = order_mod(3, q, fac)
    H = lcm(d2, d3)
    t = (-pow(m, -1, q)) % q
    trig = pow(t, H, q) == 1
    cnt = exact_TD_count(q, m, D, d2, d3)
    TD = Fraction((D + 1) * (D + 2), 2)
    mt = TD / H if trig else Fraction(0)
    e = abs(cnt - mt)
    if float(e) > maxE[0]:
        maxE = (float(e), q)
    if q <= 54:
        sumE_sqrt += e
        nq_sqrt += 1
    sumE_1000 += e
    nq_1000 += 1
target_A2 = D**2 / (log(D)) ** 2
target_A10 = D**2 / (log(D)) ** 10
print(f"[C] D=3000 m=5: sum|E_corr| over q<=54 ({nq_sqrt} primes) = {float(sumE_sqrt):.1f}; "
      f"over q<=1000 ({nq_1000} primes) = {float(sumE_1000):.1f}; "
      f"max single |E|={maxE[0]:.1f} at q={maxE[1]}; D^2/(log D)^2 = {target_A2:.0f} "
      f"({time.time()-T0:.1f}s)")

# ----------------------------------------------------------------------------
# PART D — corrected-exponent chain: kappa slope and W(z), z up to 1e6
# ----------------------------------------------------------------------------
MD_LIST = [5, 7, 35, 6257518159]
Z_CHECK = [10**3, 10**4, 10**5, 10**6]
acc = {m: dict(S1=0.0,        # sum g log p, g = 1/H triggered  (kappa sum, corrected)
               S1h2_trig=0.0,  # sum log p / H^2 over triggered  (paper's claimed kappa sum)
               S1h2_all=0.0,   # sum log p / H^2 over all p      (E2 ceiling)
               logW=0.0,       # sum log(1 - 1/H) over triggered
               sum_invH=0.0,   # sum 1/H over triggered
               ntrig=0) for m in MD_LIST}
checkpoints = {m: [] for m in MD_LIST}
nfull = 0
nprimes_D = 0
ci = 0
for p in primerange(5, 10**6 + 1):
    nprimes_D += 1
    fac = factorint(p - 1)
    d2 = order_mod(2, p, fac)
    d3 = order_mod(3, p, fac)
    H = lcm(d2, d3)
    if H == p - 1:
        nfull += 1
    lp = log(p)
    for m in MD_LIST:
        if m % p == 0:
            continue
        a = acc[m]
        a["S1h2_all"] += lp / (H * H)
        t = (-pow(m, -1, p)) % p
        if pow(t, H, p) == 1:
            a["ntrig"] += 1
            a["S1"] += lp / H
            a["S1h2_trig"] += lp / (H * H)
            a["logW"] += math.log1p(-1.0 / H)
            a["sum_invH"] += 1.0 / H
    if ci < len(Z_CHECK) and p >= Z_CHECK[ci] - 30 and p <= Z_CHECK[ci]:
        pass
    # checkpoint when passing each z
    while ci < len(Z_CHECK) and p > Z_CHECK[ci]:
        ci += 1
    # simpler: snapshot at the largest prime <= z handled after loop via list scan
# redo checkpoints properly with a second pass over stored nothing — instead snapshot inline:
# (we re-run a light loop storing snapshots since the above 'while' approach lost them)

# -- inline snapshot version (single pass, done right) --
acc = {m: dict(S1=0.0, S1h2_trig=0.0, S1h2_all=0.0, logW=0.0, sum_invH=0.0, ntrig=0)
       for m in MD_LIST}
checkpoints = {m: [] for m in MD_LIST}
nfull = 0
nprimes_D = 0
zi = 0
for p in primerange(5, 10**6 + 1):
    while zi < len(Z_CHECK) and p > Z_CHECK[zi]:
        for m in MD_LIST:
            a = acc[m]
            z = Z_CHECK[zi]
            checkpoints[m].append(dict(z=z, S1=round(a["S1"], 4),
                                       S1h2_trig=round(a["S1h2_trig"], 4),
                                       S1h2_all=round(a["S1h2_all"], 4),
                                       W=math.exp(a["logW"]),
                                       W_log_z=math.exp(a["logW"]) * log(z),
                                       sum_invH=round(a["sum_invH"], 4),
                                       ntrig=a["ntrig"]))
        zi += 1
    nprimes_D += 1
    fac = factorint(p - 1)
    d2 = order_mod(2, p, fac)
    d3 = order_mod(3, p, fac)
    H = lcm(d2, d3)
    if H == p - 1:
        nfull += 1
    lp = log(p)
    for m in MD_LIST:
        if m % p == 0:
            continue
        a = acc[m]
        a["S1h2_all"] += lp / (H * H)
        t = (-pow(m, -1, p)) % p
        if pow(t, H, p) == 1:
            a["ntrig"] += 1
            a["S1"] += lp / H
            a["S1h2_trig"] += lp / (H * H)
            a["logW"] += math.log1p(-1.0 / H)
            a["sum_invH"] += 1.0 / H
# final checkpoint at z = 1e6
for m in MD_LIST:
    a = acc[m]
    z = 10**6
    checkpoints[m].append(dict(z=z, S1=round(a["S1"], 4),
                               S1h2_trig=round(a["S1h2_trig"], 4),
                               S1h2_all=round(a["S1h2_all"], 4),
                               W=math.exp(a["logW"]),
                               W_log_z=math.exp(a["logW"]) * log(z),
                               sum_invH=round(a["sum_invH"], 4),
                               ntrig=a["ntrig"]))

kappa_slopes = {}
for m in MD_LIST:
    cps = {c["z"]: c for c in checkpoints[m]}
    s = (cps[10**6]["S1"] - cps[10**4]["S1"]) / (log(10**6) - log(10**4))
    kappa_slopes[str(m)] = round(s, 4)
print(f"[D] primes<=1e6: {nprimes_D}, full-subgroup fraction={nfull/nprimes_D:.4f}; "
      f"kappa slopes={kappa_slopes} ({time.time()-T0:.1f}s)")
for m in MD_LIST:
    print(f"    m={m}: " + " | ".join(
        f"z=1e{round(log(c['z'],10))}: W={c['W']:.4f} W*log z={c['W_log_z']:.3f} S1={c['S1']:.2f}"
        for c in checkpoints[m]))

# ----------------------------------------------------------------------------
# Receipts
# ----------------------------------------------------------------------------
import statistics
summary = dict(
    generated_utc=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    lane="LANE 2 — per-q local density (paper Lemma 3.2 lem:per-q / Lemma 2.2 eq:g-pointwise)",
    part_A=dict(
        description="Exact per-(d2,d3)-period count of q|V cells, all primes 3<q<=5000, "
                    "10 ordinary m (incl. 6257518159, 1e12+7, 1e18+9). "
                    "Claim tested: count = d2*d3/H = gcd(d2,d3) if triggered else 0 "
                    "(density 1/H), vs paper's 1/H^2.",
        m_list=[str(m) for m in M_LIST],
        n_primes=len(primes),
        n_pairs=pair_count,
        n_triggered=trig_count,
        n_mismatches_vs_density_1_over_H=len(mismatches),
        mismatch_rows=mismatches,
        subgroup_closure_equals_lcm_failures=subgroup_lcm_fail,
        paper_h2_ceiling_violations=density_paper_h2_violations,
        paper_h2_ceiling_violation_rate_over_triggered=(
            density_paper_h2_violations / trig_count if trig_count else None),
        H_factor_paper_is_off_by=dict(min=min(H_factors), median=int(statistics.median(H_factors)),
                                      max=max(H_factors)) if H_factors else None,
    ),
    part_A2=dict(description="Independent full brute force over [0,d2)x[0,d3), q<=200, "
                             "m in {5,35,6257518159}",
                 n_pairs=bf_pairs, n_mismatches=len(bf_mismatch), mismatch_rows=bf_mismatch),
    part_B=dict(description="Exact T_D counts vs three main terms: corrected |T_D|/H, "
                            "Lemma 3.2's |T_D|/H^2, eq:E-defn literal |T_D|/(qH).",
                rows=td_rows),
    part_C=dict(description="BV strengthening at D=3000, m=5 with corrected main term",
                D=3000, m=5,
                sum_absE_corr_q_le_54=float(sumE_sqrt), n_primes_q_le_54=nq_sqrt,
                sum_absE_corr_q_le_1000=float(sumE_1000), n_primes_q_le_1000=nq_1000,
                max_single_absE=maxE[0], max_single_absE_at_q=maxE[1],
                required_D2_over_log2=target_A2, required_D2_over_log10=target_A10),
    part_D=dict(description="Corrected-exponent chain: kappa slope of sum g log p (g=1/H trig) "
                            "and W(z)=prod(1-1/H) over triggered primes, z to 1e6.",
                n_primes=nprimes_D, full_subgroup_fraction=round(nfull / nprimes_D, 4),
                kappa_slopes_1e4_to_1e6=kappa_slopes,
                checkpoints={str(m): checkpoints[m] for m in MD_LIST}),
)

with open(OUTDIR + r"\lane2-per-q-density-receipts.json", "w") as f:
    json.dump(dict(summary=summary, part_A_rows=rows), f, indent=1)

print(f"[done] receipts written ({time.time()-T0:.1f}s)")
