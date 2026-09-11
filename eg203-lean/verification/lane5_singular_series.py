# LANE 5 — Singular series (L5) + constants (S6-7) verification for
# wilder-2026-V-family-rosser-iwaniec.tex
#
# Definitions (exact, from the paper):
#   V(m,k,l) = m*2^k*3^l + 1, ordinary m: gcd(m,6)=1
#   For prime q > 3, q !| m:  d2 = ord_q(2), d3 = ord_q(3),
#   H_q = |<2,3> mod q| = lcm(d2,d3)   [cyclic group => join of subgroups]
#   q triggered for m  <=>  -m^{-1} mod q in <2,3> mod q  <=>  pow(t,H,q)==1
#   g_V(q,m) = 1/H_q if triggered else 0     [paper S5 line: "per Granville C3"]
#   eq:S-defn:  S(m) = prod_{p>3} (1 - g_V(p,m)*p/(p-1))
#   Truncation: S_Q(m) = prod over 3<q<=Q. All factors <= 1, so S_Q is
#   non-increasing in Q and S(m) = inf_Q S_Q(m).
#   BH-normalized salvage: S_BH,Q(m) = prod over 3<q<=Q of
#       (1 - g_V*q/(q-1)) / (1 - 1/q)
#
# Everything below is recomputed from scratch; exact integers wherever possible.

import json, math, sys, time
sys.set_int_max_str_digits(200000)
from fractions import Fraction
from math import gcd, log, log1p, exp
from sympy import primerange, factorint

T0 = time.time()
QMAX = 100_000
CHECKPOINTS = [1000, 10_000, 100_000]
OUT_JSON = r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification\lane5-singular-series-receipts.json"

receipts = {"lane": "LANE5-singular-series-and-constants", "QMAX": QMAX}

# ---------------------------------------------------------------- primes + orders
def mult_order(a, q, fac):
    t = q - 1
    for f in fac:
        while t % f == 0 and pow(a, t // f, q) == 1:
            t //= f
    return t

primes = [int(p) for p in primerange(5, QMAX + 1)]
ORD = {}   # q -> (d2, d3, H, index e=(q-1)//H)
for q in primes:
    fac = list(factorint(q - 1).keys())
    d2 = mult_order(2, q, fac)
    d3 = mult_order(3, q, fac)
    H = d2 * d3 // gcd(d2, d3)
    ORD[q] = (d2, d3, H, (q - 1) // H)
print(f"[{time.time()-T0:6.1f}s] orders computed for {len(primes)} primes <= {QMAX}")

# index distribution (rank-2 Artin check)
idx_counts = {}
for q in primes:
    e = ORD[q][3]
    idx_counts[e] = idx_counts.get(e, 0) + 1
full_frac = idx_counts.get(1, 0) / len(primes)
receipts["index_distribution"] = {
    "n_primes": len(primes),
    "index_1_count": idx_counts.get(1, 0),
    "index_1_fraction": full_frac,
    "index_2_count": idx_counts.get(2, 0),
    "rank2_artin_reference_density": 0.6979,  # conditional rank-2 Artin constant
    "min_H": min(ORD[q][2] for q in primes),
    "min_H_at_q": min(primes, key=lambda q: ORD[q][2]),
}

# ---------------------------------------------------------------- SANITY 1: H = lcm = subgroup size (brute force q <= 2000)
bad = []
for q in [p for p in primes if p <= 2000]:
    S = set(); x = 1
    # enumerate <2> then multiply by powers of 3
    d2, d3, H, e = ORD[q]
    pow2 = set()
    x = 1
    for _ in range(d2):
        pow2.add(x); x = (x * 2) % q
    sub = set()
    y = 1
    for _ in range(d3):
        sub |= {(y * a) % q for a in pow2}
        y = (y * 3) % q
    if len(sub) != H:
        bad.append((q, len(sub), H))
receipts["sanity_H_eq_lcm_subgroup_bruteforce_q_le_2000"] = {
    "checked": sum(1 for p in primes if p <= 2000), "mismatches": bad}
assert not bad
print(f"[{time.time()-T0:6.1f}s] sanity1 H=lcm OK")

# ---------------------------------------------------------------- SANITY 2: g_V per eq:gV-defn == (1/H)*1_trig  (brute force)
# count solutions of 2^k 3^l = -m^{-1} (mod q) over Z/d2 x Z/d3, compare d2*d3/H * 1_trig
bad2 = []
checked2 = 0
for q in [p for p in primes if p <= 200]:
    d2, d3, H, e = ORD[q]
    for m in [1, 5, 7, 11, 25, 35, 49, 121, 143]:
        if m % q == 0:
            continue
        t = (-pow(m, -1, q)) % q
        trig = pow(t, H, q) == 1
        cnt = 0
        xk = 1
        for k in range(d2):
            # need 3^l = t * 2^{-k}
            target = (t * pow(xk, -1, q)) % q
            yl = 1
            for l in range(d3):
                if yl == target:
                    cnt += 1
                yl = (yl * 3) % q
            xk = (xk * 2) % q
        expect = (d2 * d3 // H) if trig else 0
        checked2 += 1
        if cnt != expect:
            bad2.append((q, m, cnt, expect))
receipts["sanity_gV_groundtruth_bruteforce"] = {"pairs_checked": checked2, "mismatches": bad2}
assert not bad2
print(f"[{time.time()-T0:6.1f}s] sanity2 g_V=1/H*1_trig OK on {checked2} (q,m) pairs")

# ---------------------------------------------------------------- worst-case floor W_Q (all primes triggered)
# For EVERY ordinary m and every Q:  S_Q(m) >= W_Q := prod_{3<q<=Q} (1 - q/((q-1)H_q))
# (each factor of S_Q is either 1 or exactly 1 - q/((q-1)H_q) < 1).
W_exact_1000 = Fraction(1)
logW = 0.0
W_at = {}
cp = set(CHECKPOINTS)
for q in primes:
    H = ORD[q][2]
    logW += log1p(-q / ((q - 1) * H))
    if q <= 1000:
        W_exact_1000 *= Fraction((q - 1) * H - q, (q - 1) * H)
for Q in CHECKPOINTS:
    lw = 0.0
    for q in primes:
        if q > Q: break
        H = ORD[q][2]
        lw += log1p(-q / ((q - 1) * H))
    W_at[Q] = exp(lw)
receipts["worst_case_floor_W_Q"] = {
    "definition": "W_Q = prod_{3<q<=Q} (1 - q/((q-1)*H_q)); for every ordinary m, S_Q(m) >= W_Q; attained by m = primorial(Q)-1",
    "W_1000_exact_num_digits": len(str(W_exact_1000.numerator)),
    "W_1000_exact": str(W_exact_1000.numerator)[:50] + "..." if len(str(W_exact_1000.numerator)) > 50 else str(W_exact_1000),
    "W_1000_float": float(W_exact_1000),
    "W_floats": {str(Q): W_at[Q] for Q in CHECKPOINTS},
    "W_ratio_1e5_over_1e3": W_at[100_000] / W_at[1000],
}
# store exact W_1000 separately (full precision, as string fraction)
receipts["W_1000_exact_fraction"] = {
    "numerator": str(W_exact_1000.numerator),
    "denominator": str(W_exact_1000.denominator),
    "float": float(W_exact_1000),
}
print(f"[{time.time()-T0:6.1f}s] W_Q floor: " + ", ".join(f"W_{Q}={W_at[Q]:.6f}" for Q in CHECKPOINTS))

# ---------------------------------------------------------------- S5 internal sums
# (a) the paper's convergence sum  sum 1/(H_q (q-1))  -- converges (but is the WRONG sum: deficit/q)
# (b) the actual per-factor deficit q/((q-1) H_q) ~ 1/H_q summed over ALL primes (paper's tail-bound object)
#     S5 claims sum_{p>P0} 1/H_p <= C/log P0  (i.e. bounded tail). We show it grows like loglog.
sum_wrong = 0.0
sum_invH_at = {}
acc = 0.0
for q in primes:
    H = ORD[q][2]
    sum_wrong += 1.0 / (H * (q - 1))
    if q > 7:
        acc += 1.0 / H
    for Q in CHECKPOINTS:
        pass
sum_invH_tail = {}
for Q in CHECKPOINTS:
    s = 0.0
    for q in primes:
        if q > Q: break
        if q > 7:
            s += 1.0 / ORD[q][2]
    sum_invH_tail[Q] = s
receipts["S5_sum_checks"] = {
    "papers_convergent_sum_1_over_H(p-1)_at_1e5": sum_wrong,
    "tail_sum_1_over_H_p_gt_7_at": {str(Q): sum_invH_tail[Q] for Q in CHECKPOINTS},
    "tail_sum_growth_1e3_to_1e5": sum_invH_tail[100_000] - sum_invH_tail[1000],
    "loglog_diff_1e3_to_1e5": log(log(100_000)) - log(log(1000)),
    "verdict": "sum_{p>7} 1/H_p grows ~ loglog z (unbounded); S5's claim 'sum_{p>P0} 1/H_p <= C/log P0' is FALSE",
}
print(f"[{time.time()-T0:6.1f}s] S5 sums: wrong-sum={sum_wrong:.4f}, tail(1e3)={sum_invH_tail[1000]:.4f}, tail(1e5)={sum_invH_tail[100_000]:.4f}")

# ---------------------------------------------------------------- main survey: 500 ordinary m in [1,1500] + extras
def survey(m):
    """returns dict with logS, logS_BH, deficit sums, trig counts at each checkpoint"""
    res = {}
    logS = 0.0; logBH = 0.0; deficit = 0.0; ntrig = 0; ndiv = 0
    ci = 0
    out = {}
    for q in primes:
        while ci < len(CHECKPOINTS) and q > CHECKPOINTS[ci]:
            out[CHECKPOINTS[ci]] = (logS, logBH, deficit, ntrig, ndiv)
            ci += 1
        H = ORD[q][2]
        if m % q == 0:
            ndiv += 1
            logBH -= log1p(-1.0 / q)
            continue
        t = (-pow(m % q, -1, q)) % q
        if pow(t, H, q) == 1:
            ntrig += 1
            x = q / ((q - 1) * H)
            logS += log1p(-x)
            deficit += x
            logBH += log1p(-x) - log1p(-1.0 / q)
        else:
            logBH -= log1p(-1.0 / q)
    while ci < len(CHECKPOINTS):
        out[CHECKPOINTS[ci]] = (logS, logBH, deficit, ntrig, ndiv)
        ci += 1
    return out

sample_m = [m for m in range(1, 1501) if gcd(m, 6) == 1]
assert len(sample_m) == 500
extras = [6_257_518_159]
import random
rng = random.Random(20260610)
big_random = []
while len(big_random) < 60:
    m = rng.randrange(10**11, 10**12)
    if gcd(m, 6) == 1:
        big_random.append(m)

results = {}
for i, m in enumerate(sample_m + extras + big_random):
    results[m] = survey(m)
    if i % 100 == 0:
        print(f"[{time.time()-T0:6.1f}s] surveyed {i+1} m values")
print(f"[{time.time()-T0:6.1f}s] survey done: {len(results)} m values")

# primorial adversaries: m_B = (prod_{p<=B} p) - 1  => triggered at EVERY 3<q<=B (m == -1 mod q => -m^{-1} == 1 in <2,3>)
prim_adv = {}
for B in [100, 1000, 5000, 100_000]:
    P = 1
    for p in primerange(2, B + 1):
        P *= int(p)
    mB = P - 1
    prim_adv[B] = mB
    results[f"primorial({B})-1"] = survey(mB)
    print(f"[{time.time()-T0:6.1f}s] adversary B={B} done ({len(str(mB))} digits)")

# ---------------------------------------------------------------- distribution stats
def stats_at(Q):
    vals = [(m, exp(results[m][Q][0])) for m in sample_m]
    vals_bh = [(m, exp(results[m][Q][1])) for m in sample_m]
    vs = sorted(v for _, v in vals)
    vbh = sorted(v for _, v in vals_bh)
    n = len(vs)
    mn_m, mn = min(vals, key=lambda t: t[1])
    mx_m, mx = max(vals, key=lambda t: t[1])
    mn_mbh, mnbh = min(vals_bh, key=lambda t: t[1])
    return {
        "S_min": mn, "S_argmin_m": mn_m, "S_max": mx, "S_argmax_m": mx_m,
        "S_median": vs[n // 2], "S_q25": vs[n // 4], "S_q75": vs[3 * n // 4],
        "S_BH_min": mnbh, "S_BH_argmin_m": mn_mbh, "S_BH_median": vbh[n // 2],
        "S_median_times_logQ": vs[n // 2] * log(Q),
    }
receipts["distribution_500_ordinary_m_le_1500"] = {str(Q): stats_at(Q) for Q in CHECKPOINTS}

# decay check: S_Q * log Q  should be ~ constant per m (Mertens-like decay => S(m)=0)
ratios = []
for m in sample_m:
    s3 = exp(results[m][1000][0]); s5 = exp(results[m][100_000][0])
    ratios.append((s5 * log(100_000)) / (s3 * log(1000)))
ratios.sort()
receipts["decay_check_S_times_logQ_const"] = {
    "statement": "if S_Q(m) ~ C(m)/log Q (Mertens-type decay to 0), then ratio (S_1e5*log1e5)/(S_1e3*log1e3) ~ 1",
    "median_ratio": ratios[len(ratios) // 2],
    "q25": ratios[len(ratios) // 4], "q75": ratios[3 * len(ratios) // 4],
    "naive_ratio_if_no_decay_would_be": log(100_000) / log(1000),
    "deficit_sum_growth_median": None,
}
defgrow = sorted(results[m][100_000][2] - results[m][1000][2] for m in sample_m)
receipts["decay_check_S_times_logQ_const"]["deficit_sum_growth_median"] = defgrow[len(defgrow) // 2]
receipts["decay_check_S_times_logQ_const"]["loglog_diff"] = log(log(100_000)) - log(log(1000))

# big random m (distribution stability at 12 digits)
bs = sorted(exp(results[m][100_000][0]) for m in big_random)
receipts["big_random_m_12digit"] = {"n": len(big_random), "S_1e5_min": bs[0], "S_1e5_median": bs[len(bs)//2], "S_1e5_max": bs[-1]}

# paper's record-holder m
mrec = 6_257_518_159
receipts["paper_record_m_6257518159"] = {
    str(Q): {"S": exp(results[mrec][Q][0]), "S_BH": exp(results[mrec][Q][1]),
             "trig": results[mrec][Q][3]} for Q in CHECKPOINTS}

# adversaries
adv_tab = {}
for B in [100, 1000, 5000, 100_000]:
    key = f"primorial({B})-1"
    adv_tab[key] = {str(Q): {"S": exp(results[key][Q][0]), "S_BH": exp(results[key][Q][1]),
                             "trig": results[key][Q][3]} for Q in CHECKPOINTS}
    adv_tab[key]["digits_of_m"] = len(str(prim_adv[B]))
receipts["primorial_adversaries"] = adv_tab
# attainment check: primorial(1e5)-1 must give S_1e5 == W_1e5 exactly (same log sum)
attain_diff = abs(results["primorial(100000)-1"][100_000][0] - sum(
    log1p(-q / ((q - 1) * ORD[q][2])) for q in primes))
receipts["W_attainment"] = {
    "log_diff_primorial_vs_W": attain_diff,
    "n_triggered_of_9592": results["primorial(100000)-1"][100_000][3],
    "verdict": "primorial(1e5)-1 triggers ALL primes <= 1e5; truncated S equals the floor W_Q exactly",
}

# ---------------------------------------------------------------- exact-fraction pass at Q=1000 (kernel-receipt grade)
prim1000 = [q for q in primes if q <= 1000]
def S_exact_1000(m):
    F = Fraction(1)
    for q in prim1000:
        if m % q == 0:
            continue
        H = ORD[q][2]
        t = (-pow(m, -1, q)) % q
        if pow(t, H, q) == 1:
            F *= Fraction((q - 1) * H - q, (q - 1) * H)
    return F
mn_m, mn_F = None, None
for m in sample_m:
    F = S_exact_1000(m)
    if mn_F is None or F < mn_F:
        mn_m, mn_F = m, F
receipts["exact_min_S_1000_over_m_le_1500"] = {
    "argmin_m": mn_m, "min_float": float(mn_F),
    "min_exact_numerator": str(mn_F.numerator), "min_exact_denominator": str(mn_F.denominator),
    "kernel_statement": f"for every ordinary m <= 1500, S_1000(m) >= {float(mn_F):.6f} (exact rational stored), attained at m={mn_m}",
}
# cross-check float vs exact for one m
xc = abs(float(S_exact_1000(35)) - exp(results[35][1000][0]))
receipts["float_vs_exact_crosscheck_m35"] = xc
assert xc < 1e-9
print(f"[{time.time()-T0:6.1f}s] exact pass done; min S_1000 = {float(mn_F):.6f} at m={mn_m}")

# ---------------------------------------------------------------- constants audit (S5-S7)
ln6 = log(6)
audit = {}
audit["sylow_99225"] = {
    "claim": "(2520/8)*(5040/16) = 99225 uncovered cells on (2520,5040); density 1/128",
    "2520/8": 2520 // 8, "5040/16": 5040 // 16, "product": (2520 // 8) * (5040 // 16),
    "99225_times_128_eq_2520*5040": 99225 * 128 == 2520 * 5040,
    "density_exact": "99225/12700800 = 1/128 EXACTLY",
    "verdict": "VERIFIED (arithmetic)",
}
audit["c_pre_inconsistency"] = {
    "exec_summary_main_tex": "c_pre = 1/128, c0 ~ 1.1e-4",
    "S5_S7_L5_and_public_page": "c_pre = 1/256 = (1/128)*(1/2 tail), c0 ~ 6.6e-4",
    "1/256": 1 / 256, "paper_says_approx": 3.91e-3, "match": abs(1 / 256 - 3.90625e-3) < 1e-12,
}
audit["c0_arithmetic"] = {
    "S5_formula": "c0 = (1/256)*exp(-2*0.89) = (1/256)*e^-1.78",
    "value": exp(-1.78) / 256,
    "claimed": 6.6e-4,
    "verdict": "arithmetic VERIFIED: 6.5876e-4 ~ 6.6e-4",
    "exec_1.1e-4_reconstruction": {
        "double_mertens_slip": exp(-2 * 1.78) / 256,
        "note": "exec's 1.1e-4 equals (1/256)*e^{-2*1.78}, i.e. the Mertens correction applied twice (or C_Mertens=1.78 used in place of 0.89); not derivable any other way from in-paper constants",
        "1/128_with_correct_mertens": exp(-1.78) / 128,
    },
}
audit["C_Mertens_0.89_provenance"] = {
    "paper_text": "'C_Mertens ~ 0.89 (Mertens product head to P0 <= 7)' -- no formula given",
    "candidates": {
        "e^gamma/2": exp(0.5772156649) / 2,
        "sum_{p<=7} 1/p": 1/2 + 1/3 + 1/5 + 1/7,
        "sum_{5<=p<=7} 1/(p-1)": 1/4 + 1/6,
        "-sum_{p<=7} log(1-1/p)": -(log(1/2) + log(2/3) + log(4/5) + log(6/7)),
        "-sum_{5<=p<=7} log(1-1/p)": -(log(4/5) + log(6/7)),
        "mertens_constant_M": 0.2614972128,
    },
    "verdict": "UNDERIVED in paper; only e^gamma/2 = 0.8905 numerically matches 0.89",
}
audit["worst_case_head_p_le_7"] = {
    "exact": "(1-5/16)*(1-7/36) = (11/16)*(29/36) = 319/576",
    "float": 319 / 576,
    "vs_1_over_128": (319 / 576) / (1 / 128),
    "note": "the TRUE worst-case Euler head over p in {5,7} is 0.5538, a factor 70.9 LARGER than 1/128; the 1/128 is a (2520,5040)-cell-covering density over ALL eligible q (incl. q>7), not the p<=7 Euler head -- the S5 head/tail split mis-attributes it",
}
audit["S6_c_formula"] = {
    "2log6": 2 * ln6,
    "1/(2log6)": 1 / (2 * ln6),
    "c = (1/(2log6))*0.9": (1 / (2 * ln6)) * 0.9,
    "c_with_cBrun_0.999": 0.999 / (2 * ln6) * 0.9,
    "claimed": 0.25,
    "S8_witness_check_c=0.25 <= cBrun/(2log6)*0.9": 0.25 <= 0.999 / (2 * ln6) * 0.9,
    "margin": 0.999 / (2 * ln6) * 0.9 - 0.25,
    "verdict": "arithmetic VERIFIED (margin 0.36%); soundness depends on kappa=0 (BROKEN per E1) and on unverified HR Thm 6.1 constants (L2)",
}
audit["S6_asymp_identity"] = {
    "claim": "|T_D|*S/log(m*6^D) ~ (D^2/2)*S/(D log6) = S*D/(2 log6)",
    "check": "algebra: |T_D| = (D+1)(D+2)/2 ~ D^2/2; log(m*6^D) = D log6 + log m ~ D log6  -- VERIFIED as asymptotic algebra (for fixed m)",
}
audit["S6_num_factors_typo"] = {
    "eq:num-factors_middle": "(D log6 + log m)/(D^{1/3} log D * 1/(D^{2/3})) -- denominator equals log D / D^{1/3}, NOT (log D)/3",
    "correct_value": "log z = (1/3) log D for z = D^{1/3}; final bound floor(3(D log6+log m)/log D) is correct",
    "verdict": "typo in middle expression (already flagged E7); conclusion arithmetic correct",
}
audit["S7_D0"] = {
    "e^200_log10": 200 / log(10),
    "claim_e200_approx_1e87": "10^86.859 ~ 1e87: VERIFIED",
    "max(e^200,1e50)": "e^200 (since 86.86 > 50): VERIFIED",
    "improvement_claim": "10^(2520-87) = 10^2433: VERIFIED as arithmetic",
    "z0_constraint": "z = D^{1/3} >= 100 <=> D >= 1e6: VERIFIED",
    "brun_depth_loss": {"claim": "C^10/10! <= 1e-3", "requires_C_le": (3628800 * 1e-3) ** 0.1,
                        "note": "C unstated in paper; holds iff C <= 2.2699"},
    "D1_e200_provenance": "UNDERIVED: 'Sufficient: D1 >= e^200 for A=10 and S(m) >= 1e-3' has no in-paper derivation; with the paper's own remainder O(D^{5/4}/(log D)^A) vs main term S*D^2, ANY D >= 13 suffices -- e^200 is not implied by any formula in the paper",
    "D2_1e50_provenance": "UNDERIVED: 'by a rough estimate from the rate of convergence' -- no formula",
    "S7_assumes_S_ge_1e-3_but_delivers_6.6e-4": "INTERNAL INCONSISTENCY: the BV bullet assumes S(m) >= 1e-3 while S5's own c0 = 6.6e-4 < 1e-3",
}
receipts["constants_audit"] = audit

# ---------------------------------------------------------------- final write
receipts["runtime_seconds"] = round(time.time() - T0, 1)
with open(OUT_JSON, "w") as f:
    json.dump(receipts, f, indent=1)
print(f"[{time.time()-T0:6.1f}s] receipts written to {OUT_JSON}")

# quick console summary
print("\n=== SUMMARY ===")
for Q in CHECKPOINTS:
    st = receipts["distribution_500_ordinary_m_le_1500"][str(Q)]
    print(f"Q={Q:>6}: S min={st['S_min']:.5f} (m={st['S_argmin_m']}) med={st['S_median']:.5f} max={st['S_max']:.5f} | W_Q={W_at[Q]:.5f} | med*lnQ={st['S_median_times_logQ']:.4f}")
print(f"decay ratio (S*lnQ const test): median {receipts['decay_check_S_times_logQ_const']['median_ratio']:.4f} (1.0 = pure Mertens decay)")
print(f"deficit growth median {receipts['decay_check_S_times_logQ_const']['deficit_sum_growth_median']:.4f} vs loglog diff {receipts['decay_check_S_times_logQ_const']['loglog_diff']:.4f}")
for k, v in adv_tab.items():
    print(f"{k}: S_1e5={v['100000']['S']:.5f}  S_BH_1e5={v['100000']['S_BH']:.5f}")
st = receipts["exact_min_S_1000_over_m_le_1500"]
print(f"exact min S_1000 over 500 m: {st['min_float']:.6f} at m={st['argmin_m']}; W_1000={float(W_exact_1000):.6f}")
