"""
shield_laneC_common.py — Lane C shared infrastructure (EG#203 entanglement-shield audit).

Definitions (exact, recomputed from scratch — trust nothing upstream):
  V(m,k,l) = m * 2^k * 3^l + 1, ordinary m (gcd(m,6)=1).
  For prime q != 2,3 with q !| m: d2 = ord_q(2), d3 = ord_q(3), H_q = lcm(d2,d3).
  TRIGGERED(q, m): q !| 6m and (-m^{-1} mod q) in <2,3> mod q,
                   decided by pow(-m^{-1} mod q, H_q, q) == 1
                   (in a cyclic group, <2,3> is THE subgroup of order lcm(ord2, ord3)).
  CARRIER: prime q <= 10^6 with H_q <= 200.
  Local law (verified upstream, lane2, 5117 pairs): triggered q covers a coset of
  Lambda_q = {(k,l): 2^k 3^l == 1 mod q} of index H_q, density exactly 1/H_q.

  f_q(m) = (1 - 1/H_q)/(1 - 1/q) if triggered, else 1/(1 - 1/q)   [incl. q | m]
  C_BH(m; P) = prod_{3 < q <= P} f_q(m)            [lane4 F3 convention, reproduced]

Building this cache cross-implements the carrier census two independent ways:
  Route A: multiplicative orders for every prime q <= 10^6 (factor q-1, order reduction).
  Route B: q is a carrier iff q | gcd(2^H - 1, 3^H - 1) for some H <= 200
           (then d2 | H, d3 | H so H_q | H <= 200; conversely q | g_{H_q}).
  Plus: brute-force cycle-walk orders for every claimed carrier (no factorization),
  and sympy.n_order spot checks on random primes.
"""
import hashlib
import json
import math
import os
import sys
import time

import gmpy2
import numpy as np
import sympy

VERIF_DIR = os.path.dirname(os.path.abspath(__file__))
ORDER_CACHE = os.path.join(VERIF_DIR, "shield-laneC-orders-cache.npz")
CARRIER_RECEIPT = os.path.join(VERIF_DIR, "shield-laneC-0-carriers.json")
LIMIT = 10**6
CARRIER_H = 200
LN2 = math.log(2.0)
LN3 = math.log(3.0)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def env_meta(script_path):
    return {
        "script": os.path.basename(script_path),
        "script_sha256": sha256_file(script_path),
        "common_sha256": sha256_file(os.path.join(VERIF_DIR, "shield_laneC_common.py")),
        "python": sys.version.split()[0],
        "sympy": sympy.__version__,
        "numpy": np.__version__,
        "gmpy2": gmpy2.version(),
        "date": "2026-06-10",
    }


def prime_sieve(n):
    sieve = np.ones(n + 1, dtype=bool)
    sieve[:2] = False
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = False
    return np.nonzero(sieve)[0]


def factor_distinct(n, small_primes):
    """Distinct prime factors of n <= 10^6 by trial division (leftover is prime)."""
    fac = []
    for p in small_primes:
        if p * p > n:
            break
        if n % p == 0:
            fac.append(p)
            while n % p == 0:
                n //= p
    if n > 1:
        fac.append(n)
    return fac


def mult_order(a, q, fac_q1):
    o = q - 1
    for p in fac_q1:
        while o % p == 0 and pow(a, o // p, q) == 1:
            o //= p
    return o


def mult_order_walk(a, q, cap=10**7):
    """Independent order computation: walk powers until 1. Only for small orders."""
    x = a % q
    o = 1
    while x != 1:
        x = (x * a) % q
        o += 1
        if o > cap:
            raise RuntimeError("order walk cap exceeded")
    return o


def build_orders(force=False, verbose=True):
    """Compute (q, d2, d3, H) for every prime 3 < q <= LIMIT.  Cached."""
    if os.path.exists(ORDER_CACHE) and not force:
        z = np.load(ORDER_CACHE)
        return z["q"], z["d2"], z["d3"], z["H"]
    t0 = time.time()
    primes = prime_sieve(LIMIT)
    primes = primes[primes > 3]
    small = [int(p) for p in prime_sieve(1009)]
    qs, d2s, d3s, Hs = [], [], [], []
    for q in primes:
        q = int(q)
        fac = factor_distinct(q - 1, small)
        d2 = mult_order(2, q, fac)
        d3 = mult_order(3, q, fac)
        H = d2 * d3 // math.gcd(d2, d3)
        qs.append(q)
        d2s.append(d2)
        d3s.append(d3)
        Hs.append(H)
    q = np.array(qs, dtype=np.int64)
    d2 = np.array(d2s, dtype=np.int64)
    d3 = np.array(d3s, dtype=np.int64)
    H = np.array(Hs, dtype=np.int64)
    np.savez_compressed(ORDER_CACHE, q=q, d2=d2, d3=d3, H=H)
    if verbose:
        print(f"[orders] built {len(q)} primes in {time.time()-t0:.1f}s", flush=True)
    return q, d2, d3, H


def carriers(qa, d2a, d3a, Ha):
    sel = Ha <= CARRIER_H
    return qa[sel], d2a[sel], d3a[sel], Ha[sel]


def triggered(m, q, H):
    """q !| 6m and -m^{-1} mod q lies in <2,3> (the subgroup of order H)."""
    if m % q == 0:
        return False
    T = (-pow(m, -1, q)) % q
    return pow(T, H, q) == 1


def trig_target(m, q):
    return (-pow(m, -1, q)) % q


def c_bh(m, qa, Ha, P):
    """C_BH(m; P) = prod_{3<q<=P} f_q  (lane4 F3 convention). Returns (C, n_trig)."""
    logC = 0.0
    ntrig = 0
    for q, H in zip(qa, Ha):
        q = int(q)
        if q > P:
            break
        H = int(H)
        if triggered(m, q, H):
            logC += math.log1p(-1.0 / H) - math.log1p(-1.0 / q)
            ntrig += 1
        else:
            logC += -math.log1p(-1.0 / q)
    return math.exp(logC), ntrig


def trig_carriers_for_m(m, cq, cd2, cd3, cH):
    out = []
    for q, d2, d3, H in zip(cq, cd2, cd3, cH):
        q, d2, d3, H = int(q), int(d2), int(d3), int(H)
        if triggered(m, q, H):
            out.append((q, d2, d3, H, trig_target(m, q)))
    return out


def pow_table(base, period, q):
    t = [1] * period
    for i in range(1, period):
        t[i] = (t[i - 1] * base) % q
    return t


def main():
    t0 = time.time()
    qa, d2a, d3a, Ha = build_orders(force=("--force" in sys.argv))
    cq, cd2, cd3, cH = carriers(qa, d2a, d3a, Ha)
    receipt = {"meta": env_meta(os.path.abspath(__file__)), "limit": LIMIT, "carrier_H": CARRIER_H}
    receipt["n_primes"] = int(len(qa))
    receipt["n_carriers"] = int(len(cq))
    receipt["carriers"] = [
        {"q": int(q), "d2": int(a), "d3": int(b), "H": int(h)}
        for q, a, b, h in zip(cq, cd2, cd3, cH)
    ]

    # --- Cross-check 1: sympy.n_order on 30 random primes (independent engine) ---
    rng = np.random.default_rng(20260610)
    idx = rng.choice(len(qa), size=30, replace=False)
    mism = []
    for i in idx:
        q = int(qa[i])
        if sympy.n_order(2, q) != int(d2a[i]) or sympy.n_order(3, q) != int(d3a[i]):
            mism.append(q)
    receipt["xcheck_sympy_norder_30"] = {"mismatches": mism, "pass": not mism}

    # --- Cross-check 2: brute cycle-walk orders for EVERY carrier (no factoring) ---
    walk_bad = []
    for q, a, b, h in zip(cq, cd2, cd3, cH):
        q = int(q)
        w2, w3 = mult_order_walk(2, q, cap=300), mult_order_walk(3, q, cap=300)
        if w2 != int(a) or w3 != int(b) or w2 * w3 // math.gcd(w2, w3) != int(h):
            walk_bad.append(q)
    receipt["xcheck_walk_all_carriers"] = {"mismatches": walk_bad, "pass": not walk_bad}

    # --- Cross-check 3 (Route B census): carriers == primes <= 1e6 dividing
    #     gcd(2^H-1, 3^H-1) for some H <= 200.  Independent of order computation. ---
    routeB = set()
    plist = [int(p) for p in qa]  # primes > 3 up to 1e6
    for Hcand in range(1, CARRIER_H + 1):
        g = int(gmpy2.gcd(2**Hcand - 1, 3**Hcand - 1))
        if g == 1:
            continue
        fac = sympy.factorint(g, limit=LIMIT)
        for p, _ in fac.items():
            p = int(p)
            if p <= LIMIT and p > 3 and gmpy2.is_prime(p):
                routeB.add(p)
    routeA = set(int(q) for q in cq)
    receipt["xcheck_routeB_census"] = {
        "routeA_count": len(routeA),
        "routeB_count": len(routeB),
        "equal": routeA == routeB,
        "A_minus_B": sorted(routeA - routeB),
        "B_minus_A": sorted(routeB - routeA),
    }

    # --- Cross-check 4: triggered() vs brute subgroup enumeration, 200 random pairs ---
    rng2 = np.random.default_rng(20260611)
    bad_trig = []
    for _ in range(200):
        ci = int(rng2.integers(0, len(cq)))
        q, d2, d3, H = int(cq[ci]), int(cd2[ci]), int(cd3[ci]), int(cH[ci])
        m = int(rng2.integers(5, 10**9))
        while math.gcd(m, 6) != 1:
            m += 1
        if m % q == 0:
            continue
        sub = set()
        x2 = 1
        for _i in range(d2):
            x3 = x2
            for _j in range(d3):
                sub.add(x3)
                x3 = (x3 * 3) % q
            x2 = (x2 * 2) % q
        assert len(sub) == H, (q, d2, d3, H, len(sub))
        brute = trig_target(m, q) in sub
        fast = triggered(m, q, H)
        if brute != fast:
            bad_trig.append({"m": m, "q": q})
    receipt["xcheck_triggered_brute_200"] = {"mismatches": bad_trig, "pass": not bad_trig}

    receipt["runtime_s"] = round(time.time() - t0, 1)
    receipt["verdict"] = (
        "VERIFIED"
        if all(
            receipt[k]["pass"] if "pass" in receipt[k] else receipt[k]["equal"]
            for k in [
                "xcheck_sympy_norder_30",
                "xcheck_walk_all_carriers",
                "xcheck_routeB_census",
                "xcheck_triggered_brute_200",
            ]
        )
        else "REFUTED"
    )
    with open(CARRIER_RECEIPT, "w") as f:
        json.dump(receipt, f, indent=1)
    print(
        f"[carriers] n={receipt['n_carriers']} verdict={receipt['verdict']} "
        f"routeB_equal={receipt['xcheck_routeB_census']['equal']} "
        f"({receipt['runtime_s']}s)",
        flush=True,
    )


if __name__ == "__main__":
    main()
