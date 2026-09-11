#!/usr/bin/env python3
"""
LANE 3 (part 2) -- in-BV-range refutation of the per-q Erdos-Turan-Koksma claim
of 03-BV-and-Iwaniec.tex ("Sharper per-q bound": |E_V(D,q,0)| = O(D log h / h)),
plus a deep-D summation margin check for the CORRECTED Prop 3.1.

KEY STRUCTURE: the triangle T_D is sliced by diagonals k+l = j. On a diagonal the
congruence 2^k 3^(j-k) = -m^{-1} reduces to (2/3)^k = const, whose period is
e_q := ord_q(2 * 3^{-1}).  If q | 3^e - 2^e then e_q | e is SMALL while
H_q = |<2,3>| can be ~ q-1: the kernel lattice has a short vector parallel to the
hypotenuse, the discrepancy scales like D/e_q, and the claimed bound D ln(H)/H is
exceeded by a factor ~ H/(e_q ln H) -> infinity along the family.  Each tested pair
(q, D) has D >= q^4, i.e. q <= D^{1/4} <= D^{1/2-eps} for every eps <= 1/4:
INSIDE the level at which Prop 3.1 invokes the ETK bound.

NOTE on sampling: at D = q^4 exactly, D = 1 mod (q-1) aligns T_D with the period
lattice and |E| collapses (observed |E| as small as 3/H at D ~ 4e25). The scan
below uses offset-randomized D in [q^4, 3*q^4] to measure sup_D, not a lucky D.

Exact integers/Fractions; floats only in reports. Output: lane3-etk-family.json.
"""

import json, math, time, random
from fractions import Fraction
from math import isqrt, gcd, lcm, log, hypot
from sympy import primerange, n_order, mod_inverse, factorint

HERE = r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification"
random.seed(20260610)

def floor_sum(n, m, a, b):
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
    c = D - a0 - b0
    if c < 0:
        return 0
    n = c // P + 1
    bp = c - (n - 1) * P
    return n + floor_sum(n, Q, P, bp)

def prime_data(q, want_logs=True):
    d2 = n_order(2, q); d3 = n_order(3, q)
    H = lcm(d2, d3)
    eq = n_order(2 * mod_inverse(3, q) % q, q)        # diagonal (hypotenuse) order
    pd = dict(q=q, d2=d2, d3=d3, H=H, eq=eq)
    if not want_logs:
        return pd
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
    bstar = astar = None
    for b in range(1, d3 + 1):
        if pow(3, b * d2, q) == 1:
            vv = mod_inverse(pow(3, b, q), q)
            if vv in log2:
                bstar, astar = b, log2[vv]
                break
    assert bstar is not None and d2 * bstar == H
    best2 = float(d2); bestv = (d2, 0); best1 = d2
    j = 1
    while True:
        b = j * bstar
        if b > best2 and b > best1:
            break
        a = (j * astar) % d2
        for ar in (a, a - d2):
            n2 = hypot(ar, b)
            if n2 < best2:
                best2, bestv = n2, (ar, b)
            n1 = abs(ar) + b
            if n1 < best1:
                best1 = n1
        j += 1
    pd.update(log2=log2, log3=log3, lam1=best2, lam1_vec=bestv, minL1=best1)
    return pd

def solution_classes(m, q, pd):
    t = (-mod_inverse(m % q, q)) % q
    inv2 = mod_inverse(2, q)
    cur = t
    sols = []
    for a in range(pd["d2"]):
        b = pd["log3"].get(cur)
        if b is not None:
            sols.append((a, b))
        cur = cur * inv2 % q
    if sols:
        assert len(sols) == pd["d2"] * pd["d3"] // pd["H"]
    return sols

def count_at(D, sols, pd):
    return sum(count_class(D, a, b, pd["d2"], pd["d3"]) for (a, b) in sols)

def brute_count(m, D, q):
    p3 = [1] * (D + 1)
    for l in range(1, D + 1):
        p3[l] = p3[l - 1] * 3 % q
    cnt = 0
    base = m % q
    for k in range(D + 1):
        for l in range(D - k + 1):
            if (base * p3[l] + 1) % q == 0:
                cnt += 1
        base = base * 2 % q
    return cnt

t0 = time.time()
checks = {"brute": 0}

# ---------------- collect candidate primes ----------------
print("collecting candidates ...")
cand = {}   # q -> tag
for e in range(1, 41):                       # diagonal family q | 3^e - 2^e
    N = 3 ** e - 2 ** e
    if N <= 3:
        continue
    try:
        fac = factorint(N, limit=10**7)
    except Exception:
        continue
    for q, _ in fac.items():
        if 3 < q <= 1_200_000 and q == int(q):
            from sympy import isprime
            if isprime(q):
                cand.setdefault(q, f"3^{e}-2^{e}")
for s in range(2, 19):                       # positive-quadrant family q | 2^a 3^b - 1
    for a in range(s + 1):
        b = s - a
        N = (1 << a) * 3 ** b - 1
        if N <= 3:
            continue
        for q in factorint(N):
            if 3 < q <= 1_200_000:
                cand.setdefault(q, f"2^{a}3^{b}-1")
for q in primerange(5, 20000):               # direct scan small primes
    cand.setdefault(q, "direct")
print(f"  {len(cand)} candidate primes")

# rank by predicted in-range ETK ratio ~ H/(eq * ln H)
prelim = []
for q in cand:
    pd = prime_data(q, want_logs=False)
    H, eq = pd["H"], pd["eq"]
    pred = H / (eq * log(H)) if H > 1 else 0.0
    prelim.append((pred, q))
prelim.sort(reverse=True)
chosen = [q for _, q in prelim[:22]]
for extra in (13, 211, 757, 1009, 637729):
    if extra not in chosen and extra in cand:
        chosen.append(extra)

# ---------------- PANEL E: D-scan in [q^4, 3 q^4] ----------------
M_TRY = [m for m in range(1, 400) if gcd(m, 6) == 1]
panelE = []
for q in chosen:
    pd = prime_data(q)
    H, eq = pd["H"], pd["eq"]
    m_used = None
    for m in M_TRY:
        if m % q:
            sols = solution_classes(m, q, pd)
            if sols:
                m_used = m
                break
    if m_used is None:
        continue
    nclass = len(sols)
    nsamp = max(8, min(28, 250_000 // max(nclass, 1)))
    Dlo = q ** 4
    ratios = []
    bestrow = None
    for i in range(nsamp):
        Dj = Dlo + int(2 * Dlo * (i / nsamp)) + random.randint(0, max(q * q, 10))
        TD = (Dj + 1) * (Dj + 2) // 2
        cnt = count_at(Dj, sols, pd)
        E = Fraction(cnt) - Fraction(TD, H)
        absE = abs(E)
        etk = Dj * log(H) / H
        r = float(absE) / etk
        ratios.append(r)
        if bestrow is None or r > bestrow["ratio_etk"]:
            bestrow = dict(D=str(Dj), absE=float(absE), etk_bound=etk, ratio_etk=r,
                           absE_over_D=float(absE) / Dj,
                           absE_over_D_div_eq=float(absE) / (Dj / eq))
    row = dict(q=q, family=cand[q], d2=pd["d2"], d3=pd["d3"], H=H, eq=eq,
               lam1=round(pd["lam1"], 3), lam1_vec=list(pd["lam1_vec"]), minL1=pd["minL1"],
               m=m_used, n_classes=nclass, n_samples=nsamp,
               pred_ratio=H / (eq * log(H)),
               max_ratio_etk=bestrow["ratio_etk"], at_D=bestrow["D"],
               max_absE=bestrow["absE"], max_absE_over_D=bestrow["absE_over_D"],
               absE_over_D_div_eq=bestrow["absE_over_D_div_eq"],
               median_ratio_etk=sorted(ratios)[len(ratios) // 2],
               in_range="q = D^{1/4} (all samples D in [q^4, 3 q^4])")
    panelE.append(row)
    print(f"  q={q:>7} [{cand[q]:>10}] H={H:>7} eq={eq:>4} lam1={pd['lam1']:7.2f} "
          f"pred={row['pred_ratio']:9.1f} maxETKratio={row['max_ratio_etk']:9.2f} "
          f"med={row['median_ratio_etk']:8.2f} |E|/D={row['max_absE_over_D']:.4f}")

panelE.sort(key=lambda r: -r["max_ratio_etk"])

# brute-force validation of fast counting on two diagonal-family primes, small D
from sympy import isprime
val_qs = [q for q in chosen if q < 4000][:2] or [13, 211]
for q in val_qs:
    pd = prime_data(q)
    for m in (5, 7):
        if m % q == 0:
            continue
        sols = solution_classes(m, q, pd)
        D = 1500
        cf = count_at(D, sols, pd) if sols else 0
        cb = brute_count(m, D, q)
        assert cf == cb, (q, m, cf, cb)
        checks["brute"] += 1
print(f"  brute validation at D=1500 pass (q in {val_qs}; m=5,7)")

# ---------------- PANEL E2: deep-D full summation, D = 10^7 ----------------
print("Panel E2: D=10^7 full BV-range sum ...")
E2 = []
D_big = 10 ** 7
Qmax = isqrt(D_big)
for m in (5, 1000003):
    sumAbs = Fraction(0)
    ntrig = 0
    worst = (Fraction(0), None)
    for q in primerange(4, Qmax + 1):
        if m % q == 0:
            continue
        pd = prime_data(q)
        sols = solution_classes(m, q, pd)
        if sols:
            TD = (D_big + 1) * (D_big + 2) // 2
            cnt = count_at(D_big, sols, pd)
            E = Fraction(cnt) - Fraction(TD, pd["H"])
            ntrig += 1
            sumAbs += abs(E)
            if abs(E) > worst[0]:
                worst = (abs(E), q)
    lnD = log(D_big)
    E2.append(dict(m=m, D=D_big, Qmax=Qmax, n_triggered=ntrig,
                   sumAbsE=float(sumAbs), maxAbsE=float(worst[0]), argmax_q=worst[1],
                   rhs_A3=D_big**2 / lnD**3,
                   ratio_A3=float(sumAbs) / (D_big**2 / lnD**3),
                   ratio_D125=float(sumAbs) / D_big ** 1.25,
                   ratio_D32_over_logD=float(sumAbs) / (D_big ** 1.5 / lnD)))
    print(f"  m={m}: ntrig={ntrig} sum|E|={float(sumAbs):.5g} max|E|={float(worst[0]):.5g}@q={worst[1]} "
          f"ratio_A3={E2[-1]['ratio_A3']:.4g} vs D^1.25={E2[-1]['ratio_D125']:.4g}")

elapsed = time.time() - t0
out = dict(
    lane="LANE 3 part 2 -- ETK in-range refutation family + deep-D summation",
    generated="2026-06-10",
    method=dict(
        diagonal_family="primes q | 3^e-2^e: kernel vector (e,-e) parallel to hypotenuse, e_q=ord_q(2/3) small, H large",
        in_range="every sample D >= q^4, so q <= D^{1/4} <= D^{1/2-eps} for all eps <= 1/4 (inside Prop 3.1 level)",
        sampling="28 offset-randomized D in [q^4, 3q^4]; D=q^4 exactly is degenerate (D=1 mod q-1 aligns the box; |E| collapses to ~1/H)",
        main_term="corrected |T_D|/H_q (density 1/H verified on every row by exact period solution count)",
        etk_claim="|E_V(D,q,0)| = O(D log h / h)  -- 03-BV-and-Iwaniec.tex 'Sharper per-q bound via Erdos-Turan'"),
    checks=checks, elapsed_sec=round(elapsed, 1),
    panelE_family=panelE,
    panelE2_deepD=E2)
with open(HERE + r"\lane3-etk-family.json", "w") as f:
    json.dump(out, f, indent=1)
print(f"wrote lane3-etk-family.json  ({elapsed:.1f}s)")
