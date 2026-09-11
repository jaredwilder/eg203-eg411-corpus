#!/usr/bin/env python3
"""
LANE 3 -- Prop 3.1 BV-level stress test (EG#203 V-family preprint).

Exact-integer numerical stress of Proposition prop:BV (03-BV-and-Iwaniec.tex):

    sum_{q <= D^{1/2-eps}, (q,6m)=1, q prime} |E_V(D,q,0)|  <=  C(eps,A) * D^2/(log D)^A

with per-q inputs Lemma lem:per-q (perimeter O(D*h), claimed density 1/h^2)
and the Erdos-Turan-Koksma refinement |E| = O(D log h / h).

GROUND TRUTH used for the corrected main term (re-derived and verified here):
  for prime q, q !| 6m, the congruence 2^k 3^l = -m^{-1} (mod q) has exactly
  d2*d3/H solutions per (d2 x d3)-period when triggered (0 otherwise), where
  H = |<2,3> mod q| = lcm(d2,d3).  Density per cell = 1/H (NOT 1/H^2).
  Corrected E_q := #{(k,l) in T_D : q|V} - |T_D|/H   (triggered q).

Everything below is exact integer / Fraction arithmetic; floats only in reports.

Panels:
  A (mandated grid)  m in {5,25,35,55,65,85,95,115,5005,1000003}, D in {50,...,800}
  B (margin ext.)    m in {5,35,1000003}, D in {1600,3200,6400,10000}
  C (per-q shape)    m=5, D=3000, all primes 3<q<=1100  (in-BV flag: q<=isqrt(3000)=54)
  D (composite/squarefree moduli attack)  d=q1*q2, m grid, D=800: does
     g_V multiply over prime factors?  (the L3 'squarefree extension' input)

Outputs: lane3-bv-stress.json + lane3-bv-stress.md in this directory.
"""

import json, math, time
from fractions import Fraction
from math import isqrt, gcd, lcm, log
from sympy import primerange, n_order, mod_inverse

HERE = r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification"

M_GRID = [5, 25, 35, 55, 65, 85, 95, 115, 5005, 1000003]
D_GRID = [50, 100, 200, 400, 800]
M_EXT  = [5, 35, 1000003]
D_EXT  = [1600, 3200, 6400, 10000]

CHECKS = {"floor_sum_random": 0, "brute_force_rows": 0, "period_count": 0,
          "H_lcm": 0, "lattice_index": 0, "nontriggered_zero": 0,
          "brute_force_joint": 0}
FAILURES = []

# ---------------------------------------------------------------- floor_sum
def floor_sum(n, m, a, b):
    """sum_{i=0}^{n-1} floor((a*i+b)/m), n>=0, m>=1, a,b>=0. Exact."""
    ans = 0
    while True:
        if a >= m:
            ans += (n - 1) * n // 2 * (a // m)
            a %= m
        if b >= m:
            ans += n * (b // m)
            b %= m
        y_max = a * n + b
        if y_max < m:
            return ans
        n = y_max // m
        b = y_max % m
        m, a = a, m

def count_class(D, a0, b0, P, Q):
    """#{(k,l): k>=0,l>=0, k+l<=D, k=a0 mod P, l=b0 mod Q}. Exact O(log)."""
    c = D - a0 - b0
    if c < 0 or a0 < 0 or b0 < 0:
        return 0
    n = c // P + 1
    bp = c - (n - 1) * P            # in [0,P)
    return n + floor_sum(n, Q, P, bp)

# self-test floor_sum / count_class against naive
import random
random.seed(203)
for _ in range(300):
    n = random.randint(0, 40); m_ = random.randint(1, 12)
    a = random.randint(0, 30); b = random.randint(0, 30)
    naive = sum((a * i + b) // m_ for i in range(n))
    assert floor_sum(n, m_, a, b) == naive
    CHECKS["floor_sum_random"] += 1
for _ in range(300):
    D = random.randint(0, 60); P = random.randint(1, 9); Q = random.randint(1, 9)
    a0 = random.randint(0, P - 1); b0 = random.randint(0, Q - 1)
    naive = sum(1 for k in range(D + 1) for l in range(D - k + 1)
                if k % P == a0 and l % Q == b0)
    assert count_class(D, a0, b0, P, Q) == naive

# ---------------------------------------------------------------- prime-q machinery
_qcache = {}
def q_data(q):
    """Per-prime data independent of m: d2,d3,H, log tables, lattice basis, lambda1."""
    if q in _qcache:
        return _qcache[q]
    d2 = n_order(2, q); d3 = n_order(3, q)
    H = lcm(d2, d3)
    # verify H = |<2,3>| by direct subgroup closure when cheap
    if d2 * d3 <= 20000:
        p2 = [pow(2, i, q) for i in range(d2)]
        p3 = [pow(3, j, q) for j in range(d3)]
        S = {(u * v) % q for u in p2 for v in p3}
        assert len(S) == H, (q, d2, d3, H, len(S))
        CHECKS["H_lcm"] += 1
    log3 = {}
    x = 1
    for j in range(d3):
        log3[x] = j
        x = x * 3 % q
    log2 = {}
    x = 1
    for i in range(d2):
        log2[x] = i
        x = x * 2 % q
    # kernel lattice  L = {(a,b): 2^a 3^b = 1 mod q}; basis (d2,0),(a*,b*)
    bstar, astar = None, None
    for b in range(1, d3 + 1):
        if pow(3, b * d2, q) == 1:           # 3^b in <2>  (unique subgroup of order d2)
            v = pow(3, b, q)
            if v in log2 or mod_inverse(v, q) in log2:
                vv = mod_inverse(v, q)
                if vv in log2:
                    bstar, astar = b, log2[vv]
                    break
    assert bstar is not None
    assert d2 * bstar == H, (q, d2, bstar, H)   # lattice index == subgroup order
    CHECKS["lattice_index"] += 1
    # shortest vector (L2) and min L1 of kernel lattice
    best2 = float(d2); bestv = (d2, 0); best1 = d2
    j = 1
    while j * bstar <= best2 + d2:
        b = j * bstar
        a = (j * astar) % d2
        for ar in (a, a - d2):
            n2 = math.hypot(ar, b)
            if n2 < best2:
                best2, bestv = n2, (ar, b)
            n1 = abs(ar) + b
            if n1 < best1:
                best1 = n1
        if b > best2 and b > best1:
            break
        j += 1
    out = dict(q=q, d2=d2, d3=d3, H=H, log2=log2, log3=log3,
               bstar=bstar, astar=astar, lam1=best2, lam1_vec=bestv, minL1=best1)
    _qcache[q] = out
    return out

def solution_classes(m, q, qd):
    """All (a,b) in [0,d2)x[0,d3) with 2^a 3^b = -m^{-1} (mod q). Exact."""
    t = (-mod_inverse(m % q, q)) % q
    inv2 = mod_inverse(2, q)
    cur = t
    sols = []
    for a in range(qd["d2"]):
        b = qd["log3"].get(cur)
        if b is not None:
            sols.append((a, b))
        cur = cur * inv2 % q
    return t, sols

def exact_count_prime(m, D, q, qd, sols):
    return sum(count_class(D, a, b, qd["d2"], qd["d3"]) for (a, b) in sols)

def brute_count_prime(m, D, q):
    p3 = [1] * (D + 1)
    for l in range(1, D + 1):
        p3[l] = p3[l - 1] * 3 % q
    cnt = 0
    base = m % q
    for k in range(D + 1):
        lim = D - k
        c = 0
        for l in range(lim + 1):
            if (base * p3[l] + 1) % q == 0:
                c += 1
        cnt += c
        base = base * 2 % q
    return cnt

# ---------------------------------------------------------------- per-(m,D,q) row
def analyze_row(m, D, q, brute=False):
    qd = q_data(q)
    d2, d3, H = qd["d2"], qd["d3"], qd["H"]
    TD = (D + 1) * (D + 2) // 2
    t, sols = solution_classes(m, q, qd)
    triggered = len(sols) > 0
    # ground-truth verification of the kernel count claim
    expected_period = d2 * d3 // H
    if triggered:
        assert d2 * d3 % H == 0
        assert len(sols) == expected_period, (m, q, len(sols), expected_period)
    CHECKS["period_count"] += 1
    count = exact_count_prime(m, D, q, qd, sols) if triggered else 0
    if not triggered:
        # verify zero count cheaply for small D
        if D <= 200:
            assert brute_count_prime(m, D, q) == 0
            CHECKS["nontriggered_zero"] += 1
    if brute:
        bc = brute_count_prime(m, D, q)
        assert bc == count, (m, D, q, bc, count)
        CHECKS["brute_force_rows"] += 1
    E = Fraction(count) - Fraction(TD, H) if triggered else Fraction(0)
    absE = abs(E)
    h = H
    row = dict(m=m, D=D, q=q, d2=d2, d3=d3, H=H,
               lam1=round(qd["lam1"], 4), lam1_vec=list(qd["lam1_vec"]), minL1=qd["minL1"],
               triggered=triggered, sols_per_period=len(sols),
               count=count, TD=TD,
               expected="%d/%d" % (TD, H) if triggered else "0",
               E_float=float(E), absE=float(absE),
               E_exact=str(E),
               perim_bound=D * h, ratio_perim=float(absE / (D * h)),
               etk_bound=D * log(h) / h if h > 1 else None,
               ratio_etk=(float(absE) / (D * log(h) / h)) if h > 1 else None,
               absE_over_D=float(absE) / D,
               D_over_lam1=D / qd["lam1"],
               ratio_Dlam1=float(absE) / (D / qd["lam1"]),
               # paper-literal error terms (the two normalizations under attack)
               E_qslip_float=float(Fraction(count) - Fraction(TD, H * q)) if triggered else 0.0,
               E_h2_float=float(Fraction(count) - Fraction(TD, H * H)) if triggered else 0.0)
    return row, E

# ---------------------------------------------------------------- composite (squarefree d = q1*q2)
def joint_analyze(m, D, q1, q2, brute=False):
    qd1, qd2 = q_data(q1), q_data(q2)
    t1, S1 = solution_classes(m, q1, qd1)
    t2, S2 = solution_classes(m, q2, qd2)
    if not S1 or not S2:
        return None
    P = lcm(qd1["d2"], qd2["d2"]); Q = lcm(qd1["d3"], qd2["d3"])
    g2 = gcd(qd1["d2"], qd2["d2"]); g3 = gcd(qd1["d3"], qd2["d3"])
    classes = []
    for (a1, b1) in S1:
        for (a2, b2) in S2:
            if (a1 - a2) % g2 == 0 and (b1 - b2) % g3 == 0:
                # CRT for k mod P
                # k = a1 + d2_1 * x ; a1 + d2_1 x = a2 mod d2_2
                d21, d22 = qd1["d2"], qd2["d2"]
                m2 = d22 // g2
                x = 0 if m2 == 1 else ((a2 - a1) // g2) * mod_inverse(d21 // g2, m2) % m2
                alpha = (a1 + d21 * x) % P
                d31, d32 = qd1["d3"], qd2["d3"]
                m3 = d32 // g3
                y = 0 if m3 == 1 else ((b2 - b1) // g3) * mod_inverse(d31 // g3, m3) % m3
                beta = (b1 + d31 * y) % Q
                assert alpha % d21 == a1 and alpha % d22 == a2 % d22
                assert beta % d31 == b1 and beta % d32 == b2 % d32
                classes.append((alpha, beta))
    TD = (D + 1) * (D + 2) // 2
    count = sum(count_class(D, a, b, P, Q) for (a, b) in classes)
    if brute:
        # direct check
        p31 = [pow(3, l, q1) for l in range(D + 1)]
        p32 = [pow(3, l, q2) for l in range(D + 1)]
        bc = 0
        base1, base2 = m % q1, m % q2
        for k in range(D + 1):
            for l in range(D - k + 1):
                if (base1 * p31[l] + 1) % q1 == 0 and (base2 * p32[l] + 1) % q2 == 0:
                    bc += 1
            base1 = base1 * 2 % q1
            base2 = base2 * 2 % q2
        assert bc == count, (m, D, q1, q2, bc, count)
        CHECKS["brute_force_joint"] += 1
    H1, H2 = qd1["H"], qd2["H"]
    dens_true = Fraction(len(classes), P * Q)
    dens_BH = Fraction(1, H1 * H2)              # multiplicativity assumption
    E_true = Fraction(count) - dens_true * TD
    E_BH = Fraction(count) - dens_BH * TD
    return dict(m=m, D=D, q1=q1, q2=q2, H1=H1, H2=H2,
                period=[P, Q], n_joint_classes=len(classes),
                density_true=str(dens_true), density_BH=str(dens_BH),
                entanglement_ratio=str(dens_true / dens_BH),
                entanglement_ratio_float=float(dens_true / dens_BH),
                consistent=len(classes) > 0,
                count=count, TD=TD,
                E_true_float=float(E_true), E_BH_float=float(E_BH),
                absE_true_over_D=abs(float(E_true)) / D,
                absE_BH_over_D=abs(float(E_BH)) / D)

# ---------------------------------------------------------------- run panels
t0 = time.time()
panelA, panelB, panelC, panelD = [], [], [], []
aggA = []

def run_panel(m_list, D_list, store, agg=None, brute_max_D=200):
    for m in m_list:
        for D in D_list:
            Qmax = isqrt(D)
            sumAbs = Fraction(0); sum_qslip = 0.0; sum_h2 = 0.0
            ntrig = 0; worst = (0.0, None)
            for q in primerange(4, Qmax + 1):
                if m % q == 0:
                    continue
                row, E = analyze_row(m, D, q, brute=(D <= brute_max_D))
                store.append(row)
                if row["triggered"]:
                    ntrig += 1
                    sumAbs += abs(E)
                    sum_qslip += abs(row["E_qslip_float"])
                    sum_h2 += abs(row["E_h2_float"])
                    if row["absE"] > worst[0]:
                        worst = (row["absE"], q)
            if agg is not None:
                lnD = log(D)
                agg.append(dict(
                    m=m, D=D, Qmax=Qmax, n_triggered=ntrig,
                    sumAbsE=float(sumAbs), sumAbsE_exact=str(sumAbs),
                    maxAbsE=worst[0], argmax_q=worst[1],
                    sumAbsE_qslip=sum_qslip, sumAbsE_h2=sum_h2,
                    rhs_A1=D * D / lnD, rhs_A2=D * D / lnD ** 2, rhs_A3=D * D / lnD ** 3,
                    ratio_A3=float(sumAbs) / (D * D / lnD ** 3),
                    ratio_qslip_A1=sum_qslip / (D * D / lnD),
                    ratio_h2_A1=sum_h2 / (D * D / lnD),
                ))

print("Panel A (mandated grid)...")
run_panel(M_GRID, D_GRID, panelA, aggA, brute_max_D=200)

print("Panel B (extended D)...")
aggB = []
run_panel(M_EXT, D_EXT, panelB, aggB, brute_max_D=0)

print("Panel C (per-q shape, m=5, D=3000, q<=1100)...")
D_C, m_C = 3000, 5
for q in primerange(4, 1101):
    if m_C % q == 0:
        continue
    row, E = analyze_row(m_C, D_C, q, brute=False)
    row["in_bv_range"] = (q <= isqrt(D_C))
    panelC.append(row)
# brute-force spot checks at D=3000
for q in (7, 53, 1009):
    qd = q_data(q)
    t, sols = solution_classes(m_C, q, qd)
    c_fast = exact_count_prime(m_C, D_C, q, qd, sols) if sols else 0
    c_brut = brute_count_prime(m_C, D_C, q)
    assert c_fast == c_brut, (q, c_fast, c_brut)
    CHECKS["brute_force_rows"] += 1
print("  spot brute checks at D=3000 pass (q=7,53,1009)")

print("Panel D (composite squarefree moduli d=q1*q2, D=800)...")
D_D = 800
for m in M_GRID:
    trig = []
    for q in primerange(4, isqrt(D_D) + 1):
        if m % q == 0:
            continue
        qd = q_data(q)
        t, S = solution_classes(m, q, qd)
        if S:
            trig.append(q)
    for i in range(len(trig)):
        for j in range(i + 1, len(trig)):
            r = joint_analyze(m, D_D, trig[i], trig[j], brute=False)
            if r:
                panelD.append(r)
# brute-force validation of joint counting at D=200 for m=5, all pairs
for (q1, q2) in [(7, 11), (7, 13), (11, 13), (7, 23), (11, 23), (13, 23)]:
    joint_analyze(5, 200, q1, q2, brute=True)
print("  joint brute checks at D=200 pass")

# ---------------------------------------------------------------- fits & analysis
def slope_loglog(pairs):
    pts = [(log(D), log(s)) for (D, s) in pairs if s > 0]
    n = len(pts)
    if n < 2:
        return None
    mx = sum(p[0] for p in pts) / n; my = sum(p[1] for p in pts) / n
    num = sum((p[0] - mx) * (p[1] - my) for p in pts)
    den = sum((p[0] - mx) ** 2 for p in pts)
    return num / den

fits = {}
for m in M_GRID:
    pairs = [(a["D"], a["sumAbsE"]) for a in aggA if a["m"] == m]
    fits[str(m)] = slope_loglog(pairs)
pooled_pairs = [(a["D"], a["sumAbsE"]) for a in aggA] + [(a["D"], a["sumAbsE"]) for a in aggB]
fits["pooled_A_and_B"] = slope_loglog(pooled_pairs)
C_D1 = max((a["sumAbsE"] / a["D"]) for a in aggA + aggB)
C_D11 = max((a["sumAbsE"] / a["D"] ** 1.1) for a in aggA + aggB)
maxratio_A3 = max(a["ratio_A3"] for a in aggA + aggB)

# growth of the literal-paper normalizations vs the BV RHS (attack on eq:E-defn / lem:per-q)
growth_qslip = [(a["D"], a["ratio_qslip_A1"]) for a in aggA if a["m"] == 5]
growth_h2 = [(a["D"], a["ratio_h2_A1"]) for a in aggA if a["m"] == 5]

# ETK violations (constant 1) -- all panels, flag in-BV-range cases
def etk_viol(rows, tag):
    out = []
    for r in rows:
        if r["triggered"] and r["ratio_etk"] is not None and r["ratio_etk"] > 1.0:
            out.append(dict(panel=tag, m=r["m"], D=r["D"], q=r["q"], H=r["H"],
                            lam1=r["lam1"], minL1=r["minL1"], absE=r["absE"],
                            etk_bound=r["etk_bound"], ratio=r["ratio_etk"],
                            in_bv=r.get("in_bv_range", True)))
    return out
viols = etk_viol(panelA, "A") + etk_viol(panelB, "B") + etk_viol(panelC, "C")
viols.sort(key=lambda v: -v["ratio"])

# per-q worst constants
def worst(rows, key, flt=lambda r: r["triggered"]):
    rs = [r for r in rows if flt(r) and r.get(key) is not None]
    rs.sort(key=lambda r: -r[key])
    return rs[:12]

worst_perim = worst(panelA + panelB + panelC, "ratio_perim")
worst_overD = worst(panelA + panelB + panelC, "absE_over_D")
worst_Dlam1 = worst(panelA + panelB + panelC, "ratio_Dlam1")
worst_etk_inbv = worst([r for r in panelA + panelB] +
                       [r for r in panelC if r.get("in_bv_range")], "ratio_etk")

# composite entanglement findings
entangled = [r for r in panelD if r["entanglement_ratio_float"] != 1.0]
inconsistent = [r for r in panelD if not r["consistent"]]
ent_sorted = sorted(panelD, key=lambda r: -abs(math.log(r["entanglement_ratio_float"]))
                    if r["entanglement_ratio_float"] > 0 else float("inf"))

elapsed = time.time() - t0
print(f"done in {elapsed:.1f}s; checks: {CHECKS}")

# ---------------------------------------------------------------- write JSON
out = dict(
    lane="LANE 3 -- Prop 3.1 BV-level stress (prop:BV, lem:per-q, ETK refinement, squarefree extension)",
    generated="2026-06-10",
    definitions=dict(
        V="V(m,k,l) = m*2^k*3^l + 1",
        T_D="{(k,l): k,l>=0, k+l<=D}, |T_D|=(D+1)(D+2)/2",
        H_q="|<2,3> mod q| (computed as subgroup size; equals lcm(d2,d3), verified)",
        corrected_E="E_q = #{(k,l) in T_D : q|V} - |T_D|/H_q  (triggered q; ground truth density 1/H verified on every row via the kernel count d2*d3/H per period)",
        paper_E_qslip="count - |T_D|/(H*q)   [eq:E-defn with eq:gV-defn density, the /q slip]",
        paper_E_h2="count - |T_D|/H^2       [lem:per-q claimed density]",
        lam1="shortest L2 vector of kernel lattice {(a,b): 2^a 3^b = 1 mod q}",
    ),
    checks=CHECKS,
    failures=FAILURES,
    elapsed_sec=round(elapsed, 1),
    aggregates_panelA=aggA,
    aggregates_panelB=aggB,
    fits=dict(per_m_slope_sumAbsE_vs_D=fits,
              C_in_sumAbsE_le_C_times_D=C_D1,
              C_in_sumAbsE_le_C_times_D_pow_1_1=C_D11,
              max_ratio_sumAbsE_over_D2_logD3=maxratio_A3,
              growth_ratio_qslip_over_BVrhsA1_m5=growth_qslip,
              growth_ratio_h2_over_BVrhsA1_m5=growth_h2),
    etk_violations_const1=viols,
    worst_ratio_perimeter=worst_perim,
    worst_absE_over_D=worst_overD,
    worst_ratio_D_over_lam1=worst_Dlam1,
    worst_etk_in_bv_range=worst_etk_inbv,
    composite_panelD=dict(
        n_pairs=len(panelD),
        n_entangled=len(entangled),
        n_inconsistent_despite_both_triggered=len(inconsistent),
        most_entangled=ent_sorted[:15],
        all_rows=panelD),
    rows_panelA=panelA,
    rows_panelB=panelB,
    rows_panelC=panelC,
)
with open(HERE + r"\lane3-bv-stress.json", "w") as f:
    json.dump(out, f, indent=1)
print("wrote lane3-bv-stress.json")
