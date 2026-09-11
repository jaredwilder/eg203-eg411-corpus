#!/usr/bin/env python3
"""
shield_laneA.py -- EG#203 'entanglement shield' LANE A: the exact pairwise entanglement law.

Setup: V(m,k,l) = m*2^k*3^l + 1, ordinary m (gcd(m,6)=1). For prime q with q !| 6m:
  d2 = ord_q(2), d3 = ord_q(3), H = lcm(d2,d3).
  q is TRIGGERED for m iff t := (-m^{-1} mod q) in <2,3> <= (Z/q)^*  (test: pow(t,H,q)==1;
  valid because (Z/q)^* is cyclic so {x: x^H=1} is the unique subgroup of order H, which is <2,3>).
  Covered cells C_q(m) = {(k,l): q | V(m,k,l)} = c_q + Lam_q where
  Lam_q = {(k,l): 2^k 3^l == 1 mod q}, a rank-2 sublattice of Z^2 with [Z^2:Lam_q] = H.

LANE A LAW (verified by exact integer computation, cross-implemented):
  For triggered q1 != q2: joint density of {q1|V and q2|V} over Z^2
    = 0                if (c1 - c2) not in Lam1 + Lam2   (incompatible cosets)
    = E / (H1*H2)      otherwise, where E = [Z^2 : Lam1 + Lam2].

Implementations cross-checked per pair (all exact integers, no floats in the law check):
  (1) numpy brute grid count over one (lcm(d2_1,d2_2), lcm(d3_1,d3_2)) period  [areas <= 1e7]
  (2) per-k row count with discrete-log tables + CRT compatibility             [all pairs]
  (3) lattice formula E/(H1*H2), E from HNF of Lam1+Lam2, compat by membership [all pairs]
  (4) explicit coset-intersection machinery: point + HNF basis of Lam1^Lam2,
      asserting det = H1*H2/E and the point lies in both cosets               [all pairs]

Doctrine: UNIVERSAL_LAW/PROCESS-GOLD-2026-06-10.md. Receipts: shield-laneA-*.json/md.
Stages:  selftest | carriers | pairs all | pairs <tag> | ladder auto | summary
"""
import json, math, os, sys, time, hashlib, random
from fractions import Fraction
from itertools import combinations

import numpy as np
from sympy import primerange, factorint, primorial

OUTDIR = os.path.dirname(os.path.abspath(__file__))
HMAX = 200
QMAX = 10**6
BRUTE_AREA_CAP = 10**7
TRIPLE_BRUTE_AREA_CAP = 4 * 10**6
SEED = 20260610

PROMPT_LITERAL_PRIM22 = 3217644767340672907899084554130  # as given in the lane brief


def lcm(a, b):
    return a // math.gcd(a, b) * b


def det2(B):
    return B[0][0] * B[1][1] - B[0][1] * B[1][0]


def frac_str(fr):
    fr = Fraction(fr)
    return f"{fr.numerator}/{fr.denominator}"


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------- lattice toolkit

def hnf2(rows):
    """HNF basis ((a,b),(0,c)), a,c>0, 0<=b<c, of the rank-2 sublattice of Z^2 gen by rows."""
    rs = [[int(x), int(y)] for (x, y) in rows if x or y]
    assert rs, "no nonzero generators"
    while True:
        nz = [r for r in rs if r[0] != 0]
        if len(nz) <= 1:
            break
        nz.sort(key=lambda r: abs(r[0]))
        p = nz[0]
        for r in nz[1:]:
            f = r[0] // p[0]
            r[0] -= f * p[0]
            r[1] -= f * p[1]
    first = [r for r in rs if r[0] != 0]
    zero = [r for r in rs if r[0] == 0 and r[1] != 0]
    assert len(first) == 1, "hnf2: reduction failed or rank deficient in x"
    c = 0
    for r in zero:
        c = math.gcd(c, r[1])
    assert c != 0, "hnf2: rank deficient (no (0,*) generator)"
    a, b = first[0]
    if a < 0:
        a, b = -a, -b
    b %= c
    return ((a, b), (0, c))


def in_lat_hnf(v, B):
    """membership for HNF basis ((a,b),(0,c))"""
    (a, b), (z, c) = B
    assert z == 0
    x, y = v
    if x % a:
        return False
    return (y - (x // a) * b) % c == 0


def in_lat_gen(v, B):
    """membership for any integer basis B (rows), det != 0, via Cramer."""
    d = det2(B)
    assert d != 0
    x, y = v
    p, q = B[0]
    r, s = B[1]
    return (x * s - y * r) % d == 0 and (y * p - x * q) % d == 0


def lattice_intersect(B1, B2):
    """HNF basis of Lam1 ^ Lam2 via duality: (L1 ^ L2)* = L1* + L2*. dets must be > 0."""
    d1, d2_ = det2(B1), det2(B2)
    assert d1 > 0 and d2_ > 0
    N = d1 * d2_

    def dual_rows(B, dB):
        p, q = B[0]
        r, s = B[1]
        f = N // dB
        return [(s * f, -r * f), (-q * f, p * f)]  # rows of N*(B^{-1})^T

    S = hnf2(dual_rows(B1, d1) + dual_rows(B2, d2_))
    dS = det2(S)
    p, q = S[0]
    r, s = S[1]
    rows = [(s * N, -r * N), (-q * N, p * N)]
    assert all(x % dS == 0 for row in rows for x in row), "intersection not integral"
    return hnf2([(row[0] // dS, row[1] // dS) for row in rows])


def coset_intersect(c1, B1, c2, B2):
    """(c1+L1) ^ (c2+L2). Returns (point, HNF basis of L1^L2) or None.
    Enumerates over det(B2): pass the SMALL-determinant lattice as B2."""
    D = det2(B2)
    assert D > 0
    p, q = B2[0]
    r, s = B2[1]

    def phi(v):  # v in L2 iff phi(v) == (0,0)
        x, y = v
        return ((x * s - y * r) % D, (y * p - x * q) % D)

    d = (c2[0] - c1[0], c2[1] - c1[1])
    w = phi(d)
    u = phi(B1[0])
    vv = phi(B1[1])
    for a in range(D):
        r0 = ((w[0] - a * u[0]) % D, (w[1] - a * u[1]) % D)
        g0 = math.gcd(vv[0], D)
        if r0[0] % g0:
            continue
        Dg = D // g0
        t0 = 0 if Dg == 1 else (r0[0] // g0) * pow(vv[0] // g0, -1, Dg) % Dg
        for j in range(g0):
            t = t0 + j * Dg
            if (t * vv[1] - r0[1]) % D == 0:
                pt = (c1[0] + a * B1[0][0] + t * B1[1][0],
                      c1[1] + a * B1[0][1] + t * B1[1][1])
                assert in_lat_gen((pt[0] - c1[0], pt[1] - c1[1]), B1)
                assert in_lat_gen((pt[0] - c2[0], pt[1] - c2[1]), B2)
                Bint = lattice_intersect(hnf2(B1), hnf2(B2))
                assert in_lat_hnf(Bint[0], hnf2(B1)) is not None  # touch
                return pt, Bint
    return None


# ---------------------------------------------------------------- per-prime data

def order_mod(a, q, fac):
    o = q - 1
    for pp in fac:
        while o % pp == 0 and pow(a, o // pp, q) == 1:
            o //= pp
    assert pow(a, o, q) == 1
    for pp in factorint(o):
        assert pow(a, o // pp, q) != 1, "order not minimal"
    return o


def dlog_table(base, order, q):
    tab = {}
    v = 1
    for e in range(order):
        tab[v] = e
        v = v * base % q
    assert v == 1
    return tab


def carrier_basis(q, d2, d3):
    """HNF-ish basis ((d2,0),(a0,b0)) of Lam_q, det = H = lcm(d2,d3)."""
    g = math.gcd(d2, d3)
    b0 = d3 // g
    t3 = pow(pow(3, b0, q), -1, q)
    tab2 = dlog_table(2, d2, q)
    a0 = tab2.get(t3)
    assert a0 is not None, "3^{-b0} not in <2>: theory violated"
    B = ((d2, 0), (a0, b0))
    H = lcm(d2, d3)
    assert det2(B) == H
    assert pow(2, a0, q) * pow(3, b0, q) % q == 1
    assert in_lat_gen((0, d3), B)
    return B


def coset_of(q, d2, d3, t, tab2):
    inv3 = pow(3, -1, q)
    u = t % q
    for l0 in range(d3):
        k0 = tab2.get(u)
        if k0 is not None:
            assert pow(2, k0, q) * pow(3, l0, q) % q == t % q
            return (k0, l0)
        u = u * inv3 % q
    return None


def pow_array(b, q, n):
    out = np.empty(n, dtype=np.int64)
    v = 1
    for i in range(n):
        out[i] = v
        v = v * b % q
    return out


# ---------------------------------------------------------------- counting implementations

def perk_count(q1, d21, d31, t1, q2, d22, d32, t2):
    """Exact joint count over one (Pk, Pl) period, row-by-row (impl 2)."""
    Pk = lcm(d21, d22)
    Pl = lcm(d31, d32)
    tab1 = dlog_table(3, d31, q1)
    tab2 = dlog_table(3, d32, q2)
    i1 = pow(2, -1, q1)
    i2 = pow(2, -1, q2)
    u1 = t1 % q1
    u2 = t2 % q2
    g = math.gcd(d31, d32)
    cnt = 0
    for _ in range(Pk):
        j1 = tab1.get(u1)
        if j1 is not None:
            j2 = tab2.get(u2)
            if j2 is not None and (j1 - j2) % g == 0:
                cnt += 1  # exactly one l in [0,Pl) satisfies both congruences
        u1 = u1 * i1 % q1
        u2 = u2 * i2 % q2
    return cnt, Pk, Pl


def brute_grid_count(primes_t, Pk, Pl):
    """Fully elementary numpy count: primes_t = list of (q, t). impl 1 (and triples)."""
    pks = [pow_array(2, q, Pk) for q, _ in primes_t]
    pls = [pow_array(3, q, Pl) for q, _ in primes_t]
    blk = max(1, 4_000_000 // max(Pl, 1))
    cnt = 0
    for s in range(0, Pk, blk):
        mask = None
        for (q, t), pk, pl in zip(primes_t, pks, pls):
            mm = (pk[s:s + blk, None] * pl[None, :] % q) == t
            mask = mm if mask is None else (mask & mm)
        cnt += int(np.count_nonzero(mask))
    return cnt


# ---------------------------------------------------------------- stage: carriers

def stage_carriers():
    t0 = time.time()
    L = 1
    for i in range(1, HMAX + 1):
        L = lcm(L, i)
    carriers = []
    for q in primerange(5, QMAX):
        if pow(2, L, q) != 1 or pow(3, L, q) != 1:
            continue
        fac = factorint(q - 1)
        d2 = order_mod(2, q, fac)
        d3 = order_mod(3, q, fac)
        H = lcm(d2, d3)
        if H <= HMAX:
            carriers.append({"q": q, "d2": d2, "d3": d3, "H": H})
    out = {
        "definition": f"carriers = primes 5 <= q < {QMAX}, q not in {{2,3}}, with H_q = lcm(ord_q(2), ord_q(3)) <= {HMAX}",
        "count": len(carriers),
        "carriers": carriers,
        "elapsed_s": round(time.time() - t0, 1),
    }
    path = os.path.join(OUTDIR, "shield-laneA-carriers.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"[carriers] {len(carriers)} carriers (H<= {HMAX}, q < {QMAX}) in {out['elapsed_s']}s -> {path}", flush=True)


def load_carriers():
    with open(os.path.join(OUTDIR, "shield-laneA-carriers.json")) as f:
        return json.load(f)["carriers"]


# ---------------------------------------------------------------- m registry

def m_values():
    pr = lambda n: int(primorial(n))
    return [
        ("m1", 1), ("m5", 5), ("m7", 7), ("m11", 11), ("m13", 13),
        ("m25", 25), ("m35", 35), ("m143", 143),
        ("prim5m1", pr(5) - 1), ("prim8m1", pr(8) - 1),
        ("prim13m1", pr(13) - 1), ("prim17m1", pr(17) - 1),
        ("prim22m1", pr(22) - 1),
    ]


# ---------------------------------------------------------------- triggered set

def triggered_set(m, carriers):
    assert math.gcd(m, 6) == 1, "m not ordinary"
    trig, skipped = [], []
    for c in carriers:
        q, d2, d3, H = c["q"], c["d2"], c["d3"], c["H"]
        if m % q == 0:
            skipped.append(q)
            continue
        t = (-pow(m % q, -1, q)) % q
        if pow(t, H, q) != 1:
            continue
        tab2 = dlog_table(2, d2, q)
        cos = coset_of(q, d2, d3, t, tab2)
        assert cos is not None, "trigger test passed but no coset rep found"
        B = carrier_basis(q, d2, d3)
        # single-prime local law re-check: count over d2 x d3 box == d2*d3/H == gcd(d2,d3)
        A2 = pow_array(2, q, d2)
        A3 = pow_array(3, q, d3)
        cnt = int(np.count_nonzero((A2[:, None] * A3[None, :] % q) == t))
        assert cnt == d2 * d3 // H == math.gcd(d2, d3), f"single-prime law fails q={q}"
        trig.append({"q": q, "d2": d2, "d3": d3, "H": H, "t": t, "c": cos, "B": B})
    return trig, skipped


# ---------------------------------------------------------------- stage: pairs (the law)

def pair_law_record(m, A, Bc, do_brute=True):
    """A, Bc = triggered dicts. Returns record with all cross-implementation checks."""
    q1, d21, d31, H1, t1, c1, B1 = A["q"], A["d2"], A["d3"], A["H"], A["t"], A["c"], A["B"]
    q2, d22, d32, H2, t2, c2, B2 = Bc["q"], Bc["d2"], Bc["d3"], Bc["H"], Bc["t"], Bc["c"], Bc["B"]
    # impl 3: lattice formula
    Bsum = hnf2(list(B1) + list(B2))
    E = det2(Bsum)
    assert H1 % E == 0 and H2 % E == 0, "E must divide gcd(H1,H2)"
    d = (c1[0] - c2[0], c1[1] - c2[1])
    compat = in_lat_hnf(d, Bsum)
    predicted = Fraction(E, H1 * H2) if compat else Fraction(0)
    # impl 2: per-k row count
    cnt, Pk, Pl = perk_count(q1, d21, d31, t1, q2, d22, d32, t2)
    ok_perk = (Fraction(cnt, Pk * Pl) == predicted)
    # impl 1: numpy brute grid
    bcnt = None
    ok_brute = None
    if do_brute and Pk * Pl <= BRUTE_AREA_CAP:
        bcnt = brute_grid_count([(q1, t1), (q2, t2)], Pk, Pl)
        ok_brute = (bcnt == cnt)
    # impl 4: coset-intersection machinery
    if H1 <= H2:
        ci = coset_intersect(c2, B2, c1, B1)
    else:
        ci = coset_intersect(c1, B1, c2, B2)
    if compat:
        ok_mach = ci is not None and det2(ci[1]) == H1 * H2 // E
        if ok_mach:
            pt = ci[0]
            ok_mach = (in_lat_gen((pt[0] - c1[0], pt[1] - c1[1]), B1)
                       and in_lat_gen((pt[0] - c2[0], pt[1] - c2[1]), B2))
    else:
        ok_mach = ci is None
    if compat:
        # exact integer identity: cnt * H1 * H2 == Pk * Pl * E
        assert cnt * H1 * H2 == Pk * Pl * E, "law identity violated"
    else:
        assert cnt == 0, "incompatible cosets but nonzero count"
        assert E > 1, "incompatible requires E>1"
    rec = {
        "q1": q1, "q2": q2, "H1": H1, "H2": H2, "E": E, "compat": bool(compat),
        "joint": frac_str(predicted), "perk_count": cnt, "Pk": Pk, "Pl": Pl,
        "brute_count": bcnt,
        "checks": {"perk_eq_formula": bool(ok_perk),
                   "brute_eq_perk": (None if ok_brute is None else bool(ok_brute)),
                   "machinery_ok": bool(ok_mach)},
    }
    ok_all = ok_perk and ok_mach and (ok_brute is not False)
    return rec, predicted, ok_all


def stage_pairs(tag, m, carriers):
    t0 = time.time()
    trig, skipped = triggered_set(m, carriers)
    S1 = sum((Fraction(1, T["H"]) for T in trig), Fraction(0))
    pairs = []
    zero_cases = []
    S2 = Fraction(0)
    S2_indep = Fraction(0)
    E_hist = {}
    n_E1 = n_Egt1 = n_zero = 0
    n_brute = 0
    mismatches = 0
    for i, j in combinations(range(len(trig)), 2):
        rec, dens, ok = pair_law_record(m, trig[i], trig[j])
        if not ok:
            mismatches += 1
        pairs.append(rec)
        S2 += dens
        S2_indep += Fraction(1, trig[i]["H"] * trig[j]["H"])
        if rec["brute_count"] is not None:
            n_brute += 1
        if rec["compat"]:
            E_hist[str(rec["E"])] = E_hist.get(str(rec["E"]), 0) + 1
            if rec["E"] == 1:
                n_E1 += 1
            else:
                n_Egt1 += 1
        else:
            E_hist[f"{rec['E']}(zero)"] = E_hist.get(f"{rec['E']}(zero)", 0) + 1
            n_zero += 1
            zero_cases.append({
                "q1": rec["q1"], "q2": rec["q2"], "E": rec["E"],
                "c1": list(trig[i]["c"]), "c2": list(trig[j]["c"]),
                "delta_in_sum_lattice": False,
                "perk_count": rec["perk_count"],
                "brute_count": rec["brute_count"],
            })
    U2 = S1 - S2
    out = {
        "tag": tag, "m": str(m), "m_digits": len(str(m)), "gcd_m_6": math.gcd(m, 6),
        "n_carriers_universe": len(carriers),
        "skipped_q_dividing_m": skipped,
        "n_triggered": len(trig),
        "triggered": [{"q": T["q"], "d2": T["d2"], "d3": T["d3"], "H": T["H"],
                       "t": T["t"], "coset": list(T["c"]),
                       "basis": [list(T["B"][0]), list(T["B"][1])]} for T in trig],
        "S1": frac_str(S1), "S1_float": float(S1),
        "pair_stats": {
            "n_pairs": len(pairs), "compat_E1": n_E1, "compat_Egt1": n_Egt1,
            "zero_pairs": n_zero, "E_hist": E_hist,
            "S2": frac_str(S2), "S2_float": float(S2),
            "U2 = S1 - S2": frac_str(U2), "U2_float": float(U2),
            "S2_indep": frac_str(S2_indep), "S2_indep_float": float(S2_indep),
            "entanglement_excess = S2 - S2_indep": frac_str(S2 - S2_indep),
            "excess_float": float(S2 - S2_indep),
        },
        "verification": {
            "pairs_total": len(pairs),
            "pairs_brute_grid_checked": n_brute,
            "pairs_perk_checked": len(pairs),
            "pairs_machinery_checked": len(pairs),
            "mismatches": mismatches,
        },
        "zero_cases": zero_cases,
        "pairs": pairs,
        "elapsed_s": round(time.time() - t0, 1),
    }
    path = os.path.join(OUTDIR, f"shield-laneA-pairs-{tag}.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"[pairs:{tag}] trig={len(trig)} pairs={len(pairs)} brute={n_brute} "
          f"zero={n_zero} mismatches={mismatches} S1={float(S1):.4f} U2={float(U2):.4f} "
          f"({out['elapsed_s']}s)", flush=True)
    return out


# ---------------------------------------------------------------- stage: Bonferroni ladder

def stage_ladder(tag, m, carriers):
    t0 = time.time()
    trig, _ = triggered_set(m, carriers)
    n = len(trig)
    S1 = sum((Fraction(1, T["H"]) for T in trig), Fraction(0))
    # pairwise cosets via machinery, cross-checked against the lattice formula
    pairC = {}
    S2 = Fraction(0)
    for i, j in combinations(range(n), 2):
        A, Bc = trig[i], trig[j]
        Bsum = hnf2(list(A["B"]) + list(Bc["B"]))
        E = det2(Bsum)
        d = (A["c"][0] - Bc["c"][0], A["c"][1] - Bc["c"][1])
        compat = in_lat_hnf(d, Bsum)
        if A["H"] <= Bc["H"]:
            ci = coset_intersect(Bc["c"], Bc["B"], A["c"], A["B"])
        else:
            ci = coset_intersect(A["c"], A["B"], Bc["c"], Bc["B"])
        if compat:
            assert ci is not None
            dens = Fraction(1, det2(ci[1]))
            assert dens == Fraction(E, A["H"] * Bc["H"])
            pairC[(i, j)] = ci
            S2 += dens
        else:
            assert ci is None
            pairC[(i, j)] = None
    # triples
    tripC = {}
    S3 = Fraction(0)
    n_trip = 0
    for i, j, k in combinations(range(n), 3):
        n_trip += 1
        base = pairC[(i, j)]
        if base is None:
            tripC[(i, j, k)] = None
            continue
        pt, B12 = base
        Tk = trig[k]
        ci = coset_intersect(pt, B12, Tk["c"], Tk["B"])
        tripC[(i, j, k)] = ci
        if ci is not None:
            S3 += Fraction(1, det2(ci[1]))
    # quads (only if tractable)
    S4 = None
    n_quad = 0
    if n <= 64:
        S4 = Fraction(0)
        for i, j, k in combinations(range(n), 3):
            base = tripC[(i, j, k)]
            if base is None:
                continue
            pt, B123 = base
            for l in range(k + 1, n):
                n_quad += 1
                Tl = trig[l]
                ci = coset_intersect(pt, B123, Tl["c"], Tl["B"])
                if ci is not None:
                    S4 += Fraction(1, det2(ci[1]))
    # sample-verify triples by fully-elementary brute grid
    rnd = random.Random(SEED)
    all_trips = list(combinations(range(n), 3))
    rnd.shuffle(all_trips)
    sample_checked = 0
    sample_mism = 0
    sampled = []
    for (i, j, k) in all_trips:
        A, Bc, C = trig[i], trig[j], trig[k]
        Pk = lcm(lcm(A["d2"], Bc["d2"]), C["d2"])
        Pl = lcm(lcm(A["d3"], Bc["d3"]), C["d3"])
        if Pk * Pl > TRIPLE_BRUTE_AREA_CAP:
            continue
        ci = tripC[(i, j, k)]
        pred = Fraction(0) if ci is None else Fraction(1, det2(ci[1]))
        cnt = brute_grid_count([(A["q"], A["t"]), (Bc["q"], Bc["t"]), (C["q"], C["t"])], Pk, Pl)
        ok = (Fraction(cnt, Pk * Pl) == pred)
        if not ok:
            sample_mism += 1
        sampled.append({"qs": [A["q"], Bc["q"], C["q"]], "pred": frac_str(pred),
                        "count": cnt, "Pk": Pk, "Pl": Pl, "ok": bool(ok)})
        sample_checked += 1
        if sample_checked >= 120:
            break
    U2 = S1 - S2
    U3 = S1 - S2 + S3
    U4 = None if S4 is None else S1 - S2 + S3 - S4
    out = {
        "tag": tag, "m": str(m), "n_triggered": n,
        "S1": frac_str(S1), "S2": frac_str(S2), "S3": frac_str(S3),
        "S4": (None if S4 is None else frac_str(S4)),
        "S1_float": float(S1), "S2_float": float(S2), "S3_float": float(S3),
        "S4_float": (None if S4 is None else float(S4)),
        "U2 = S1-S2 (Bonferroni LOWER bound on union)": frac_str(U2),
        "U2_float": float(U2),
        "U3 = S1-S2+S3 (Bonferroni UPPER bound on union)": frac_str(U3),
        "U3_float": float(U3),
        "U4 = S1-S2+S3-S4 (Bonferroni LOWER bound)": (None if U4 is None else frac_str(U4)),
        "U4_float": (None if U4 is None else float(U4)),
        "n_triples": n_trip, "n_quads_evaluated": n_quad,
        "bonferroni_note": ("For ANY finite union of periodic cell sets on the common torus: "
                            "max(S1-S2, S1-S2+S3-S4) <= dens(union) <= min(1, S1-S2+S3). "
                            "The lane brief called U2 an upper bound; Bonferroni direction is "
                            "corrected here: even truncations are LOWER bounds, odd are UPPER."),
        "triple_sample_verification": {"checked": sample_checked, "mismatches": sample_mism,
                                       "area_cap": TRIPLE_BRUTE_AREA_CAP,
                                       "samples": sampled[:25]},
        "elapsed_s": round(time.time() - t0, 1),
    }
    path = os.path.join(OUTDIR, f"shield-laneA-uladder-{tag}.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"[ladder:{tag}] n={n} S1={float(S1):.4f} S2={float(S2):.4f} S3={float(S3):.4f} "
          f"S4={None if S4 is None else round(float(S4),4)} | U2={float(U2):.4f} "
          f"U3={float(U3):.4f} U4={None if U4 is None else round(float(U4),4)} "
          f"| triple-samples {sample_checked} mism {sample_mism} ({out['elapsed_s']}s)", flush=True)
    return out


# ---------------------------------------------------------------- stage: 5th-order ladder

def stage_ladder5(tag, m, carriers):
    """Bonferroni through S5 (odd order => true UPPER bound U5 = S1-S2+S3-S4+S5)."""
    t0 = time.time()
    trig, _ = triggered_set(m, carriers)
    n = len(trig)
    S1 = sum((Fraction(1, T["H"]) for T in trig), Fraction(0))
    pairC = {}
    S2 = Fraction(0)
    for i, j in combinations(range(n), 2):
        A, Bc = trig[i], trig[j]
        if A["H"] <= Bc["H"]:
            ci = coset_intersect(Bc["c"], Bc["B"], A["c"], A["B"])
        else:
            ci = coset_intersect(A["c"], A["B"], Bc["c"], Bc["B"])
        pairC[(i, j)] = ci
        if ci is not None:
            S2 += Fraction(1, det2(ci[1]))
    tripC = {}
    S3 = Fraction(0)
    for i, j, k in combinations(range(n), 3):
        base = pairC[(i, j)]
        if base is None:
            tripC[(i, j, k)] = None
            continue
        ci = coset_intersect(base[0], base[1], trig[k]["c"], trig[k]["B"])
        tripC[(i, j, k)] = ci
        if ci is not None:
            S3 += Fraction(1, det2(ci[1]))
    quadC = {}
    S4 = Fraction(0)
    for (i, j, k), base in tripC.items():
        if base is None:
            continue
        for l in range(k + 1, n):
            ci = coset_intersect(base[0], base[1], trig[l]["c"], trig[l]["B"])
            if ci is not None:
                quadC[(i, j, k, l)] = ci
                S4 += Fraction(1, det2(ci[1]))
    S5 = Fraction(0)
    n_quints = 0
    for (i, j, k, l), base in quadC.items():
        for r in range(l + 1, n):
            n_quints += 1
            ci = coset_intersect(base[0], base[1], trig[r]["c"], trig[r]["B"])
            if ci is not None:
                S5 += Fraction(1, det2(ci[1]))
    U3 = S1 - S2 + S3
    U4 = U3 - S4
    U5 = U4 + S5
    out = {
        "tag": tag, "m": str(m), "n_triggered": n,
        "S1": frac_str(S1), "S2": frac_str(S2), "S3": frac_str(S3),
        "S4": frac_str(S4), "S5": frac_str(S5),
        "S5_float": float(S5),
        "U4 = S1-S2+S3-S4 (LOWER)": frac_str(U4), "U4_float": float(U4),
        "U5 = S1-S2+S3-S4+S5 (UPPER)": frac_str(U5), "U5_float": float(U5),
        "nonempty_quads": len(quadC), "quints_evaluated": n_quints,
        "certificate": ("U5 < 1: the union of all triggered-carrier cosets has density <= U5 < 1; "
                        "carriers cannot cover Z^2 for this m" if U5 < 1 else
                        "U5 >= 1: fifth order does not certify"),
        "elapsed_s": round(time.time() - t0, 1),
    }
    path = os.path.join(OUTDIR, f"shield-laneA-uladder5-{tag}.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1)
    print(f"[ladder5:{tag}] n={n} S5={float(S5):.4f} U4={float(U4):.4f} U5={float(U5):.4f} "
          f"quads+={len(quadC)} quints={n_quints} ({out['elapsed_s']}s)", flush=True)
    return out


# ---------------------------------------------------------------- stage: selftest

def rand_basis(rnd, maxdet):
    while True:
        B = ((rnd.randint(-4, 4), rnd.randint(-4, 4)), (rnd.randint(-4, 4), rnd.randint(-4, 4)))
        d = det2(B)
        if d != 0 and abs(d) <= maxdet:
            return hnf2(list(B))


def stage_selftest():
    rnd = random.Random(SEED)
    # known-answer carrier bases
    assert carrier_basis(5, 4, 4) == ((4, 0), (1, 1))
    assert carrier_basis(7, 3, 6) == ((3, 0), (2, 2))
    # hnf2 lattice-equality on random generator multisets
    for _ in range(400):
        B = rand_basis(rnd, 36)
        r1, r2 = B
        rows = [r1, r2,
                (r1[0] + r2[0], r1[1] + r2[1]),
                (3 * r1[0] - 2 * r2[0], 3 * r1[1] - 2 * r2[1])]
        H = hnf2(rows)
        assert det2(H) == det2(B)
        assert all(in_lat_gen(r, B) for r in H) and all(in_lat_gen(r, H) for r in (r1, r2))
    # lattice_intersect vs brute membership on a box
    for _ in range(250):
        B1 = rand_basis(rnd, 12)
        B2 = rand_basis(rnd, 12)
        Bi = lattice_intersect(B1, B2)
        Bs = hnf2(list(B1) + list(B2))
        assert det2(Bi) * det2(Bs) == det2(B1) * det2(B2), "index product law fails"
        for x in range(-12, 13):
            for y in range(-12, 13):
                assert (in_lat_gen((x, y), B1) and in_lat_gen((x, y), B2)) == in_lat_hnf((x, y), Bi)
    # coset_intersect vs brute on a periodic box
    n_empty = 0
    for _ in range(250):
        B1 = rand_basis(rnd, 4)
        B2 = rand_basis(rnd, 4)
        c1 = (rnd.randint(-3, 3), rnd.randint(-3, 3))
        c2 = (rnd.randint(-3, 3), rnd.randint(-3, 3))
        ci = coset_intersect(c1, B1, c2, B2)
        Bi = lattice_intersect(B1, B2)
        T = det2(Bi)
        pts = [(x, y) for x in range(T) for y in range(T)
               if in_lat_gen((x - c1[0], y - c1[1]), B1) and in_lat_gen((x - c2[0], y - c2[1]), B2)]
        if ci is None:
            assert not pts
            n_empty += 1
        else:
            assert len(pts) == T * T // det2(Bi)  # density 1/det over periodic box [0,T)^2
            pt = ci[0]
            assert in_lat_gen((pt[0] - c1[0], pt[1] - c1[1]), B1)
            assert in_lat_gen((pt[0] - c2[0], pt[1] - c2[1]), B2)
    # one known joint: m=1, q=5 (coset (2,0)), q=7 (coset (1,1)), E=1, joint=1/24 over 12x12
    cnt, Pk, Pl = perk_count(5, 4, 4, 4, 7, 3, 6, 6)
    assert (Pk, Pl) == (12, 12) and cnt == 6
    assert brute_grid_count([(5, 4), (7, 6)], 12, 12) == 6
    out = {"selftest": "PASS", "hnf_tests": 400, "intersect_tests": 250,
           "coset_tests": 250, "coset_empty_cases_seen": n_empty,
           "known_answer": "q5/q7 m=1 joint 6/144 == 1/24 == E/(H1*H2) with E=1"}
    with open(os.path.join(OUTDIR, "shield-laneA-selftest.json"), "w") as f:
        json.dump(out, f, indent=1)
    print(f"[selftest] PASS (empty coset cases exercised: {n_empty})", flush=True)


# ---------------------------------------------------------------- stage: summary

def stage_summary():
    carriers = load_carriers()
    tags = [t for t, _ in m_values()]
    per_m = {}
    for tag in tags:
        p = os.path.join(OUTDIR, f"shield-laneA-pairs-{tag}.json")
        if os.path.exists(p):
            with open(p) as f:
                per_m[tag] = json.load(f)
    ladders = {}
    for tag in tags:
        p = os.path.join(OUTDIR, f"shield-laneA-uladder-{tag}.json")
        if os.path.exists(p):
            with open(p) as f:
                ladders[tag] = json.load(f)
    total_pairs = sum(d["verification"]["pairs_total"] for d in per_m.values())
    total_brute = sum(d["verification"]["pairs_brute_grid_checked"] for d in per_m.values())
    total_mism = sum(d["verification"]["mismatches"] for d in per_m.values())
    total_zero = sum(d["pair_stats"]["zero_pairs"] for d in per_m.values())
    m_with_brute = sum(1 for d in per_m.values() if d["verification"]["pairs_brute_grid_checked"] > 0)
    # global E histogram (compat only)
    E_hist = {}
    for d in per_m.values():
        for k, v in d["pair_stats"]["E_hist"].items():
            E_hist[k] = E_hist.get(k, 0) + v
    prim22 = per_m.get("prim22m1")
    files = sorted(f for f in os.listdir(OUTDIR) if f.startswith("shield-laneA"))
    hashes = {f: sha256_file(os.path.join(OUTDIR, f)) for f in files if not f.endswith("summary.md")}
    script_sha = sha256_file(os.path.abspath(__file__))
    verdict = {
        "lane": "A",
        "law": "joint density = 0 (iff c1-c2 not in Lam1+Lam2) OR E/(H1*H2), E=[Z^2:Lam1+Lam2]",
        "pairs_total": total_pairs,
        "pairs_brute_grid_checked": total_brute,
        "pairs_all_impl_mismatches": total_mism,
        "zero_pairs_total": total_zero,
        "m_values_tested": len(per_m),
        "m_values_with_brute_pairs": m_with_brute,
        "requirement_500_brute_pairs": total_brute >= 500,
        "requirement_10_m_values": len(per_m) >= 10,
        "prim22m1_included": prim22 is not None,
        "E_hist_global": E_hist,
        "per_m": {tag: {"n_triggered": d["n_triggered"], "S1": d["S1"], "S1_float": d["S1_float"],
                        "n_pairs": d["pair_stats"]["n_pairs"],
                        "zero_pairs": d["pair_stats"]["zero_pairs"],
                        "compat_Egt1": d["pair_stats"]["compat_Egt1"],
                        "S2_float": d["pair_stats"]["S2_float"],
                        "U2": d["pair_stats"]["U2 = S1 - S2"],
                        "U2_float": d["pair_stats"]["U2_float"],
                        "excess_float": d["pair_stats"]["excess_float"],
                        "mismatches": d["verification"]["mismatches"]} for tag, d in per_m.items()},
        "ladders": {tag: {k: v for k, v in L.items() if k not in ("triple_sample_verification",)}
                    for tag, L in ladders.items()},
        "script_sha256": script_sha,
        "receipt_sha256": hashes,
    }
    with open(os.path.join(OUTDIR, "shield-laneA-law-verdict.json"), "w") as f:
        json.dump(verdict, f, indent=1)
    # markdown
    lines = []
    lines.append("# shield-laneA — The Exact Pairwise Entanglement Law (EG#203 shield)")
    lines.append("")
    lines.append(f"Date: 2026-06-10. Script: `shield_laneA.py` (sha256 `{script_sha[:16]}…`).")
    lines.append("Doctrine: `UNIVERSAL_LAW/PROCESS-GOLD-2026-06-10.md` — exact integers, cross-implemented, labeled.")
    lines.append("")
    lines.append("## The law (tested object)")
    lines.append("")
    lines.append("For ordinary m and triggered primes q1 != q2 (q_i not dividing 6m, t_i = -m^{-1} mod q_i in <2,3>):")
    lines.append("```")
    lines.append("dens{(k,l): q1|V and q2|V} = 0                if c1 - c2 not in Lam1 + Lam2")
    lines.append("                           = E/(H1*H2)        otherwise,  E = [Z^2 : Lam1 + Lam2]")
    lines.append("```")
    lines.append("Cross-implemented 4 ways per pair: numpy brute grid over one period; per-k row count")
    lines.append("(dlog tables + CRT); HNF lattice-index formula; explicit coset-intersection machinery")
    lines.append("(point + HNF basis of Lam1^Lam2 with det = H1*H2/E).")
    lines.append("")
    lines.append("## Aggregate verification")
    lines.append("")
    lines.append(f"- m values tested: **{len(per_m)}** (requirement >= 10: {'PASS' if len(per_m) >= 10 else 'FAIL'})")
    lines.append(f"- triggered pairs, all implementations: **{total_pairs}**")
    lines.append(f"- pairs ALSO checked by fully-elementary numpy brute grid: **{total_brute}** (requirement >= 500: {'PASS' if total_brute >= 500 else 'FAIL'})")
    lines.append(f"- cross-implementation mismatches: **{total_mism}**")
    lines.append(f"- zero-overlap (incompatible-coset) pairs: **{total_zero}** — every one satisfies c1-c2 not in Lam1+Lam2 AND E>1 (asserted)")
    lines.append("")
    lines.append("## Per-m table")
    lines.append("")
    lines.append("| m | triggered | pairs | S1 | S2 | U2=S1-S2 | zero pairs | E>1 compat | excess S2-S2_indep | mism |")
    lines.append("|---|---|---|---|---|---|---|---|---|---|")
    for tag, d in per_m.items():
        ps = d["pair_stats"]
        lines.append(f"| {tag} | {d['n_triggered']} | {ps['n_pairs']} | {d['S1_float']:.4f} | "
                     f"{ps['S2_float']:.4f} | {ps['U2_float']:.4f} | {ps['zero_pairs']} | "
                     f"{ps['compat_Egt1']} | {ps['excess_float']:+.5f} | {d['verification']['mismatches']} |")
    lines.append("")
    lines.append("## Global E distribution (compatible pairs; '(zero)' = incompatible)")
    lines.append("")
    lines.append("```json")
    lines.append(json.dumps(E_hist, indent=1, sort_keys=True))
    lines.append("```")
    lines.append("")
    if ladders:
        lines.append("## Bonferroni ladder (exact, on the common torus)")
        lines.append("")
        lines.append("NOTE: the lane brief called U2 = S1 - S2 an 'upper bound'. Bonferroni direction is the")
        lines.append("opposite: even truncations are LOWER bounds on the union, odd truncations are UPPER bounds.")
        lines.append("So the certifying quantity is U3 = S1 - S2 + S3: if U3 < 1, carriers cannot cover (exact).")
        lines.append("")
        lines.append("| m | S1 | S2 | S3 | S4 | U2 (lower) | U3 (UPPER) | U4 (lower) | union bracket |")
        lines.append("|---|---|---|---|---|---|---|---|---|")
        for tag, L in ladders.items():
            s4 = "n/a" if L["S4_float"] is None else f"{L['S4_float']:.4f}"
            u4 = "n/a" if L["U4_float"] is None else f"{L['U4_float']:.4f}"
            lo = max(L["U2_float"], L["U4_float"] or L["U2_float"])
            hi = min(1.0, L["U3_float"])
            lines.append(f"| {tag} | {L['S1_float']:.4f} | {L['S2_float']:.4f} | {L['S3_float']:.4f} | {s4} | "
                         f"{L['U2_float']:.4f} | {L['U3_float']:.4f} | {u4} | [{lo:.4f}, {hi:.4f}] |")
        lines.append("")
        for tag, L in ladders.items():
            ts = L["triple_sample_verification"]
            lines.append(f"- {tag}: triple machinery sample-verified by brute grid on {ts['checked']} triples, "
                         f"mismatches {ts['mismatches']}; quads evaluated: {L['n_quads_evaluated']}.")
        lines.append("")
    if prim22:
        lines.append("## primorial(22)-1 notes")
        lines.append("")
        lines.append(f"- The lane brief gave m = {PROMPT_LITERAL_PRIM22} = 'primorial(22)-1'. Recomputed:")
        lines.append(f"  primorial(22) = {int(primorial(22))}; the brief's literal equals primorial(22) itself")
        lines.append(f"  (even, NOT ordinary). The adversarial m used here is primorial(22)-1 = {int(primorial(22)) - 1}")
        lines.append(f"  with gcd(m,6) = {math.gcd(int(primorial(22)) - 1, 6)} (ordinary: PASS).")
        lines.append(f"- S1(prim22m1) = {prim22['S1']} = {prim22['S1_float']:.6f}.")
        lines.append("")
    lines.append("## Labels")
    lines.append("")
    lines.append(f"- Pairwise law on all tested pairs: **VERIFIED** ({total_pairs} pairs, 4 implementations, "
                 f"{total_mism} mismatches). As a general theorem it also has the standard 2nd-isomorphism proof; "
                 "the machine check certifies our concrete implementations and every concrete (q1,q2,m) below.")
    lines.append("- Zero-case characterization (joint=0 iff c1-c2 not in Lam1+Lam2; and joint=0 implies E>1): "
                 f"**VERIFIED** on all {total_zero} zero cases and all compatible cases (two-sided).")
    lines.append("- 'Entanglement shield caps union below 1 for EVERY m': **OPEN** — supported here only for the "
                 "tested m and the q<10^6 carrier universe (see ladder brackets), not proven universally.")
    lines.append("")
    lines.append("## Receipts (sha256)")
    lines.append("")
    for fn, hh in sorted(hashes.items()):
        lines.append(f"- `{fn}` `{hh}`")
    md_path = os.path.join(OUTDIR, "shield-laneA-summary.md")
    with open(md_path, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"[summary] pairs={total_pairs} brute={total_brute} mism={total_mism} zero={total_zero} -> {md_path}", flush=True)


# ---------------------------------------------------------------- main

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    if cmd == "selftest":
        stage_selftest()
    elif cmd == "carriers":
        stage_carriers()
    elif cmd == "pairs":
        which = sys.argv[2] if len(sys.argv) > 2 else "all"
        carriers = load_carriers()
        for tag, m in m_values():
            if which not in ("all", tag):
                continue
            stage_pairs(tag, m, carriers)
    elif cmd == "ladder":
        which = sys.argv[2] if len(sys.argv) > 2 else "auto"
        carriers = load_carriers()
        chosen = []
        for tag, m in m_values():
            p = os.path.join(OUTDIR, f"shield-laneA-pairs-{tag}.json")
            if which == "auto":
                if os.path.exists(p):
                    with open(p) as f:
                        d = json.load(f)
                    if d["S1_float"] > 1.0:
                        chosen.append((tag, m))
            elif which in ("all", tag):
                chosen.append((tag, m))
        if which == "auto" and not chosen:
            # fall back to max-S1 tag
            best = None
            for tag, m in m_values():
                p = os.path.join(OUTDIR, f"shield-laneA-pairs-{tag}.json")
                if os.path.exists(p):
                    with open(p) as f:
                        d = json.load(f)
                    if best is None or d["S1_float"] > best[2]:
                        best = (tag, m, d["S1_float"])
            if best:
                chosen = [(best[0], best[1])]
        for tag, m in chosen:
            stage_ladder(tag, m, carriers)
    elif cmd == "ladder5":
        which = sys.argv[2]
        carriers = load_carriers()
        for tag, m in m_values():
            if which in ("all", tag):
                stage_ladder5(tag, m, carriers)
    elif cmd == "summary":
        stage_summary()
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
