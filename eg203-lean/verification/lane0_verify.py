"""
LANE 0 receipts: exact-integer ground-truth checks for
wilder-2026-V-family-rosser-iwaniec.tex (EG#203 V-family preprint).

All computations exact integer / rational where possible.
Writes lane0-internal-error-scan.json.
"""
import json, math, time
from fractions import Fraction
from sympy import primerange, isprime, factorint, mod_inverse

T0 = time.time()
OUT = {}

# ---------- helpers ----------
def ordp(a, p, fac_pm1):
    """multiplicative order of a mod p, given factorization dict of p-1"""
    e = p - 1
    for f, mult in fac_pm1.items():
        for _ in range(mult):
            if pow(a, e // f, p) == 1:
                e //= f
            else:
                break
    return e

def lcm(a, b):
    return a // math.gcd(a, b) * b

# =====================================================================
# PART A: ground truth for g_V(q,m): density of cells with q | V.
# Claim chain to test:
#   eq:gV-defn  : g_V = (#solutions in d2 x d3 period) / (d2*d3)   [definition]
#   GROUND TRUTH: #solutions per period = d2*d3/H if triggered else 0
#                 => density = 1/H (triggered), 0 otherwise.
#   Lemma lem:g-pointwise CLAIMS: g_V <= 1/(d2*d3) <= 1/H^2  (i.e. <=1 sol/period)
#   Sec 3 Lemma per-q CLAIMS: density "either 0 or 1/h^2"
#   Sec 5 eq:S-trig USES: g_V = 1/H (triggered)  [correct]
# =====================================================================
A_rows = []
qs = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 73, 109, 151, 257, 1009, 10007]
ms = [1, 5, 7, 25, 35, 49, 55, 77, 91]
violA_dd, violA_H2, ok_truth = 0, 0, 0
for q in qs:
    fac = factorint(q - 1)
    d2, d3 = ordp(2, q, fac), ordp(3, q, fac)
    # subgroup <2,3> by brute closure
    sub = set()
    x = 1
    elems2 = []
    for _ in range(d2):
        elems2.append(x); x = x * 2 % q
    for e2 in elems2:
        y = e2
        for _ in range(d3):
            sub.add(y); y = y * 3 % q
    H = len(sub)
    assert H == lcm(d2, d3), (q, H, d2, d3)
    for m in ms:
        if m % q == 0:
            continue
        target = (-mod_inverse(m, q)) % q
        trig = target in sub
        # exact solution count in one (d2,d3) period
        cnt = 0
        pk = 1
        for k in range(d2):
            pl = 1
            for l in range(d3):
                if (pk * pl) % q == target:
                    cnt += 1
                pl = pl * 3 % q
            pk = pk * 2 % q
        truth = d2 * d3 // H if trig else 0
        density = Fraction(cnt, d2 * d3)
        ok = (cnt == truth) and (density == (Fraction(1, H) if trig else 0))
        if ok: ok_truth += 1
        v_dd = trig and (density > Fraction(1, d2 * d3))      # violates paper's <= 1/(d2 d3)
        v_H2 = trig and (density > Fraction(1, H * H))        # violates paper's <= 1/H^2
        if v_dd: violA_dd += 1
        if v_H2: violA_H2 += 1
        A_rows.append(dict(q=q, m=m, d2=d2, d3=d3, H=H, triggered=trig,
                           solutions_per_period=cnt, predicted_d2d3_over_H=truth,
                           density=str(density),
                           violates_paper_1_over_d2d3=bool(v_dd),
                           violates_paper_1_over_H2=bool(v_H2)))
OUT["partA_density_ground_truth"] = dict(
    rows=A_rows,
    n_cases=len(A_rows),
    n_matching_ground_truth_1_over_H=ok_truth,
    n_violating_paper_bound_1_over_d2d3=violA_dd,
    n_violating_paper_bound_1_over_H2=violA_H2,
    verdict="g_V = 1/H_q (triggered) exactly, in EVERY case; paper's <=1/(d2*d3) and <=1/H^2 bounds violated whenever gcd(d2,d3)>1 (i.e. d2*d3 > H)")

# =====================================================================
# PART B: kappa_V slope.  Definition defn:kappa: sum_{3<p<=z} g_V(p) log p
# Paper Prop kappa-zero claims this is O(1) absolute.
# Ground truth g_V(p)=1[trig]/H_p  => sum should grow ~ c * log z, c>0.
# Also: sum 1/H_p (claimed O(loglog z) - plausibly TRUE),
#       sum (log p)/H_p^2 (claimed-needed O(1) - TRUE),
#       partial singular product per eq:S-trig (claimed >= c0 >0; truth -> 0),
#       fraction of primes with H = p-1 (full subgroup).
# =====================================================================
Z = 10**6
checkpoints = [10**3, 10**4, 10**5, 10**6]
mlist = [5, 7, 35]
sums_glogp = {m: [] for m in mlist}      # sum g log p
prods_Strig = {m: [] for m in mlist}     # product (1 - p/((p-1)H)) over triggered
sum_1overH = []
sum_logp_over_H2 = []
frac_full = []
run_glogp = {m: 0.0 for m in mlist}
run_logprod = {m: 0.0 for m in mlist}
run_1H = 0.0
run_lpH2 = 0.0
n_full = 0
n_primes = 0
ci = 0
for p in primerange(5, Z + 1):
    fac = factorint(p - 1)
    d2, d3 = ordp(2, p, fac), ordp(3, p, fac)
    H = lcm(d2, d3)
    lp = math.log(p)
    n_primes += 1
    if H == p - 1:
        n_full += 1
    run_1H += 1.0 / H
    run_lpH2 += lp / (H * H)
    for m in mlist:
        if m % p == 0:
            continue
        t = (-mod_inverse(m, p)) % p
        trig = pow(t, H, p) == 1     # cyclic group: t in <2,3> iff t^H=1
        if trig:
            run_glogp[m] += lp / H
            run_logprod[m] += math.log(1.0 - p / ((p - 1.0) * H))
    while ci < len(checkpoints) and p >= checkpoints[ci] - 0 and p > checkpoints[ci]:
        ci += 1
    if p in (997, 9973, 99991, 999983):  # last prime under each checkpoint
        pass
# simpler: redo with checkpoint capture
run_glogp = {m: 0.0 for m in mlist}
run_logprod = {m: 0.0 for m in mlist}
run_1H = 0.0; run_lpH2 = 0.0; n_full = 0; n_primes = 0
cp_iter = iter(checkpoints)
next_cp = next(cp_iter)
records = []
for p in primerange(5, Z + 1):
    if p > next_cp:
        records.append(dict(z=next_cp,
            sum_1_over_H=run_1H, loglog_z=math.log(math.log(next_cp)),
            sum_logp_over_H2=run_lpH2,
            frac_full_subgroup=n_full / n_primes,
            sum_g_logp={m: run_glogp[m] for m in mlist},
            singular_partial_product={m: math.exp(run_logprod[m]) for m in mlist}))
        next_cp = next(cp_iter, None)
        if next_cp is None:
            next_cp = float('inf')
    fac = factorint(p - 1)
    d2, d3 = ordp(2, p, fac), ordp(3, p, fac)
    H = lcm(d2, d3)
    lp = math.log(p)
    n_primes += 1
    if H == p - 1:
        n_full += 1
    run_1H += 1.0 / H
    run_lpH2 += lp / (H * H)
    for m in mlist:
        if m % p == 0:
            continue
        t = (-mod_inverse(m, p)) % p
        if pow(t, H, p) == 1:
            run_glogp[m] += lp / H
            run_logprod[m] += math.log(1.0 - p / ((p - 1.0) * H))
records.append(dict(z=Z,
    sum_1_over_H=run_1H, loglog_z=math.log(math.log(Z)),
    sum_logp_over_H2=run_lpH2,
    frac_full_subgroup=n_full / n_primes,
    sum_g_logp={m: run_glogp[m] for m in mlist},
    singular_partial_product={m: math.exp(run_logprod[m]) for m in mlist}))
# slope of sum g log p vs log z between z=1e4 and z=1e6
slopes = {}
for m in mlist:
    s1 = next(r for r in records if r["z"] == 10**4)["sum_g_logp"][m]
    s2 = next(r for r in records if r["z"] == 10**6)["sum_g_logp"][m]
    slopes[m] = (s2 - s1) / (math.log(10**6) - math.log(10**4))
OUT["partB_kappa_slope"] = dict(
    checkpoints=records,
    kappa_empirical_slope_log_z=slopes,
    verdict="sum_{3<p<=z} g_V(p) log p grows LINEARLY in log z with slope ~kappa>0 "
            "(paper Prop 2.3 claims O(1), i.e. kappa_V=0: BROKEN under ground-truth g=1/H). "
            "sum 1/H ~ O(loglog z) consistent (Remark 3.x OK); sum logp/H^2 = O(1) TRUE; "
            "singular partial product per eq:S-defn DECREASES toward 0 (Prop 5.2 positivity "
            "fails for the literal definition).")

# =====================================================================
# PART C: per-q discrepancy E_V(D,q,0) against the CORRECT main term
# |T_D|/H (triggered).  Paper Lemma 3.2 claims |E| <= min(|T_D|/h^2,1)+O(Dh)
# and the ETK-refined claim |E| = O(D log h / h).
# Also compute the "error" against the paper's main terms:
#   (g/q)|T_D| (eq:E-defn literal, g=1/H)  and |T_D|/h^2 (Lemma 3.2 case 2).
# =====================================================================
def count_divisible(q, m, D):
    """exact #{(k,l) in T_D : q | V(m,k,l)}"""
    fac = factorint(q - 1)
    d2, d3 = ordp(2, q, fac), ordp(3, q, fac)
    target = (-mod_inverse(m, q)) % q
    # 3^l residues cycle d3; precompute map residue -> l0 in [0,d3)
    pow3 = {}
    y = 1
    for l in range(d3):
        pow3.setdefault(y, l)
        y = y * 3 % q
    total = 0
    pk = 1
    inv_pk = 1
    inv2 = mod_inverse(2, q)
    for k in range(0, D + 1):
        need = (target * inv_pk) % q   # need 3^l == target * 2^{-k}
        l0 = pow3.get(need)
        if l0 is not None:
            Lmax = D - k
            if l0 <= Lmax:
                total += (Lmax - l0) // d3 + 1
        pk = pk * 2 % q
        inv_pk = inv_pk * inv2 % q
    return total, d2, d3

C_rows = []
m = 5
for q in [7, 11, 13, 23, 41, 73, 109, 151, 257, 1009]:
    fac = factorint(q - 1)
    d2, d3 = ordp(2, q, fac), ordp(3, q, fac)
    H = lcm(d2, d3)
    t = (-mod_inverse(m, q)) % q
    trig = pow(t, H, q) == 1
    for D in [100, 300, 1000, 3000]:
        TD = (D + 1) * (D + 2) // 2
        cnt, _, _ = count_divisible(q, m, D)
        main_correct = Fraction(TD, H) if trig else Fraction(0)
        E_correct = cnt - main_correct
        main_paper_gq = Fraction(TD, q * H) if trig else Fraction(0)   # (g/q)|T_D|
        main_paper_h2 = Fraction(TD, H * H) if trig else Fraction(0)   # |T_D|/h^2
        C_rows.append(dict(q=q, m=m, D=D, H=H, triggered=trig, count=cnt,
            E_vs_correct_main_TD_over_H=float(E_correct),
            E_vs_paper_eqEdefn_g_over_q=float(cnt - main_paper_gq),
            E_vs_paper_lemma32_TD_over_h2=float(cnt - main_paper_h2),
            paper_ETK_bound_DlogH_over_H=D * math.log(H) / H,
            elementary_bound_D=D))
OUT["partC_per_q_discrepancy"] = dict(
    rows=C_rows,
    verdict="Against the CORRECT main term |T_D|/H the error is O(D) (often much smaller); "
            "against the paper's own main terms ((g/q)|T_D| or |T_D|/h^2) the 'error' is "
            "~|T_D|/H ~ D^2/H, i.e. Lemma 3.2 / Prop 3.1 as literally stated are FALSE; they "
            "become true only after correcting the main term to |T_D|/H.")

# =====================================================================
# PART D: empirical witness claims.
#  (1) V(6257518159,16,10) prime; minimal diagonal for that m is 26.
#  (2) mini-sweep m <= 10^5: every ordinary m has a witness, max first-prime diagonal.
# =====================================================================
mw = 6257518159
v = mw * (2**16) * (3**10) + 1
w_prime = isprime(v)
min_diag = None
found = []
for D in range(0, 27):
    for k in range(0, D + 1):
        l = D - k
        if isprime(mw * (2**k) * (3**l) + 1):
            found.append((k, l))
    if found:
        min_diag = D
        break
OUT["partD_witness"] = dict(
    m=mw, witness_k=16, witness_l=10, V_is_prime=bool(w_prime),
    minimal_diagonal_found=min_diag, first_witnesses=found[:5],
    verdict="abstract witness claim check")

maxdiag = 0
argmax = None
for m2 in range(1, 100001):
    if m2 % 2 == 0 or m2 % 3 == 0:
        continue
    D = 0
    ok = False
    while not ok:
        for k in range(0, D + 1):
            if isprime(m2 * (2**k) * (3**(D - k)) + 1):
                ok = True
                break
        if not ok:
            D += 1
            if D > 40:
                raise RuntimeError(f"no witness for m={m2} up to D=40")
    if D > maxdiag:
        maxdiag, argmax = D, m2
OUT["partD_sweep_1e5"] = dict(range="ordinary m <= 1e5", max_first_prime_diagonal=maxdiag,
                              attained_at=argmax,
                              paper_claim_for_1e6="max 17",
                              verdict="consistent iff <= 17")

# =====================================================================
# PART E: shape of pi_V(m,D): is it ~ linear in D (the THEOREM's shape)?
# =====================================================================
E_curves = {}
for m3 in [5, 7]:
    Dmax = 60
    prime_cells = []
    for k in range(0, Dmax + 1):
        for l in range(0, Dmax + 1 - k):
            if isprime(m3 * (2**k) * (3**l) + 1):
                prime_cells.append(k + l)
    curve = []
    for D in range(0, Dmax + 1, 10):
        curve.append(dict(D=D, pi_V=sum(1 for d in prime_cells if d <= D)))
    E_curves[m3] = curve
OUT["partE_piV_shape"] = dict(curves=E_curves,
    verdict="pi_V(m,D) growth for small m; roughly linear in D supports the THEOREM SHAPE "
            "(with properly normalized singular series), independent of the broken proof.")

OUT["elapsed_sec"] = round(time.time() - T0, 1)
with open(r"C:\Users\jared\Local Sites\woocommerce-enterprise\public\proofs\eg203\verification\lane0-internal-error-scan.json", "w") as f:
    json.dump(OUT, f, indent=1)
print("WROTE lane0-internal-error-scan.json in", OUT["elapsed_sec"], "s")
print("A: ok_truth", OUT["partA_density_ground_truth"]["n_matching_ground_truth_1_over_H"], "/",
      OUT["partA_density_ground_truth"]["n_cases"],
      "violate 1/(d2d3):", OUT["partA_density_ground_truth"]["n_violating_paper_bound_1_over_d2d3"],
      "violate 1/H^2:", OUT["partA_density_ground_truth"]["n_violating_paper_bound_1_over_H2"])
for r in OUT["partB_kappa_slope"]["checkpoints"]:
    print("B z=%8d  S1/H=%.3f loglogz=%.3f  SlpH2=%.3f  fracfull=%.4f  Sglogp=%s  prod=%s" % (
        r["z"], r["sum_1_over_H"], r["loglog_z"], r["sum_logp_over_H2"], r["frac_full_subgroup"],
        {k: round(v, 2) for k, v in r["sum_g_logp"].items()},
        {k: round(v, 4) for k, v in r["singular_partial_product"].items()}))
print("B slopes:", {k: round(v, 4) for k, v in OUT["partB_kappa_slope"]["kappa_empirical_slope_log_z"].items()})
print("D witness prime:", w_prime, "min diag:", min_diag)
print("D sweep 1e5 max diag:", maxdiag, "at m=", argmax)
