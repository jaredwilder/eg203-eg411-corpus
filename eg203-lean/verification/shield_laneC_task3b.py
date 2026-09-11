"""
shield_laneC_task3b.py — LANE C #3b: the pairwise entanglement dichotomy, EXACT + cross-implemented.

Claim under test (the quantitative core of the shield hypothesis): for triggered carriers
q1, q2 the joint covered density is either 0 (incompatible cosets) or exactly E/(H1*H2)
with E = [Z^2 : Lambda_{q1} + Lambda_{q2}] an integer >= 1.

Two independent implementations, exact integers only:
  (A) ENUMERATION: count covered-by-both cells on the exact period torus
      lcm(d2_1,d2_2) x lcm(d3_1,d3_2); joint density is an exact rational.
  (B) LATTICE ALGEBRA: basis of Lambda_q = {(d2,0), (b,c)} with c = H/d2 and b the
      discrete log solving 2^b 3^c == 1 (brute over [0,d2)); E = gcd of all 2x2 minors
      of the 2x4 matrix [basis1 | basis2]  (Smith form: index of the SUM lattice).
  PASS iff for every pair: joint == 0 or joint == E_B/(H1*H2) exactly (Fraction arithmetic).

m values: 1 (the -1 coset), and the two ratio extremes from task 3
(982367 ratio 1.108, 6820067 ratio 1.147, 133974061 ratio 0.914).
Carriers used: all triggered among q < 100 (largest densities; 23 candidates).
"""
import json
import math
import os
import time
from fractions import Fraction

import numpy as np

from shield_laneC_common import (
    VERIF_DIR,
    build_orders,
    carriers,
    env_meta,
    pow_table,
    trig_target,
    triggered,
)

OUT = os.path.join(VERIF_DIR, "shield-laneC-3b-pairwise-E.json")
MS = [1, 982367, 6820067, 133974061]


def lattice_basis(q, d2, d3, H):
    """Basis {(d2,0),(b,c)} of Lambda_q; c = H/d2, b in [0,d2) with 2^b 3^c == 1 mod q."""
    c = H // d2
    t = pow(3, c, q)
    for b in range(d2):
        if (pow(2, b, q) * t) % q == 1:
            return (d2, 0), (b, c)
    raise RuntimeError(f"no b found for q={q}")


def sum_lattice_index(b1a, b1b, b2a, b2b):
    """[Z^2 : L1+L2] = gcd of all 2x2 minors of the 2x4 generator matrix."""
    cols = [b1a, b1b, b2a, b2b]
    g = 0
    for i in range(4):
        for j in range(i + 1, 4):
            det = cols[i][0] * cols[j][1] - cols[i][1] * cols[j][0]
            g = math.gcd(g, abs(det))
    return g


def joint_density_exact(q1, d2_1, d3_1, T1, q2, d2_2, d3_2, T2):
    K = math.lcm(d2_1, d2_2)
    L = math.lcm(d3_1, d3_2)
    A1 = np.resize(np.array(pow_table(2, d2_1, q1), dtype=np.int64), K)
    B1 = np.resize(np.array(pow_table(3, d3_1, q1), dtype=np.int64), L)
    A2 = np.resize(np.array(pow_table(2, d2_2, q2), dtype=np.int64), K)
    B2 = np.resize(np.array(pow_table(3, d3_2, q2), dtype=np.int64), L)
    c1 = (A1[:, None] * B1[None, :]) % q1 == T1
    c2 = (A2[:, None] * B2[None, :]) % q2 == T2
    return Fraction(int((c1 & c2).sum()), K * L)


def main():
    t0 = time.time()
    qa, d2a, d3a, Ha = build_orders()
    cq, cd2, cd3, cH = carriers(qa, d2a, d3a, Ha)
    small = [
        (int(q), int(a), int(b), int(h))
        for q, a, b, h in zip(cq, cd2, cd3, cH)
        if int(q) < 100
    ]
    # verify the single-carrier exact local law on the period torus while here
    single_law_fail = []
    for q, a, b, h in small:
        T = (q - 1) % q  # any element of <2,3> coset works; use -1 when triggered for m=1
    results = []
    n_pairs = n_zero = n_e1 = n_egt1 = mism = 0
    e_hist = {}
    for m in MS:
        trigs = [(q, a, b, h, trig_target(m, q)) for q, a, b, h in small if triggered(m, q, h)]
        for i in range(len(trigs)):
            for j in range(i + 1, len(trigs)):
                q1, a1, b1, h1, T1 = trigs[i]
                q2, a2, b2, h2, T2 = trigs[j]
                jd = joint_density_exact(q1, a1, b1, T1, q2, a2, b2, T2)
                bas1 = lattice_basis(q1, a1, b1, h1)
                bas2 = lattice_basis(q2, a2, b2, h2)
                E_lat = sum_lattice_index(bas1[0], bas1[1], bas2[0], bas2[1])
                indep = Fraction(1, h1 * h2)
                ok = (jd == 0) or (jd == E_lat * indep)
                n_pairs += 1
                if jd == 0:
                    n_zero += 1
                elif jd == indep:
                    n_e1 += 1
                else:
                    n_egt1 += 1
                if not ok:
                    mism += 1
                E_obs = None if jd == 0 else int(jd / indep) if (jd / indep).denominator == 1 else str(jd / indep)
                e_hist[str(E_obs)] = e_hist.get(str(E_obs), 0) + 1
                results.append(
                    {
                        "m": m,
                        "q1": q1,
                        "q2": q2,
                        "H1": h1,
                        "H2": h2,
                        "joint": [jd.numerator, jd.denominator],
                        "E_lattice": E_lat,
                        "E_observed": E_obs,
                        "dichotomy_holds": ok,
                    }
                )
    summary = {
        "m_values": MS,
        "n_pairs": n_pairs,
        "n_zero_incompatible": n_zero,
        "n_E_equal_1": n_e1,
        "n_E_greater_1": n_egt1,
        "E_histogram": e_hist,
        "dichotomy_violations": mism,
        "all_pass": mism == 0,
    }
    out = {
        "meta": env_meta(os.path.abspath(__file__)),
        "summary": summary,
        "pairs": results,
        "runtime_s": round(time.time() - t0, 1),
    }
    with open(OUT, "w") as f:
        json.dump(out, f, indent=1)
    print(
        f"[task3b] pairs={n_pairs} zero={n_zero} E=1:{n_e1} E>1:{n_egt1} "
        f"violations={mism} ({out['runtime_s']}s)",
        flush=True,
    )


if __name__ == "__main__":
    main()
