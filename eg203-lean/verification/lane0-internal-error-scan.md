# LANE 0 — Certified receipt tables: V-family preprint internal-error scan

Paper: `public/proofs/eg203/paper/wilder-2026-V-family-rosser-iwaniec.tex` (+ 01/03/05 includes), 2026-06-03.
Generator: `lane0_verify.py` (this dir). Machine receipt: `lane0-internal-error-scan.json`.
All counts exact-integer; densities exact rationals. Date: 2026-06-10.

## Receipt 1 — Ground truth for the local density g_V(q,m)

For prime q∤6m, the map ψ: Z/d2 × Z/d3 → ⟨2,3⟩ mod q, (k,ℓ) ↦ 2^k·3^ℓ is a surjective
homomorphism onto a group of order H = lcm(d2,d3). Every fiber has exactly d2·d3/H points.
Hence, exactly:

```
#solutions of 2^k 3^ℓ ≡ −m^{−1} (mod q) per (d2,d3)-period = d2·d3/H_q  if triggered, else 0
g_V(q,m) = 1/H_q  if triggered, else 0          (NOT ≤ 1/(d2·d3), NOT ≤ 1/H_q²)
```

Brute-force check over 141 (q,m) pairs (q ∈ {5,…,10007}, m ∈ {1,5,7,25,35,49,55,77,91}):

| check | result |
|---|---|
| count == d2·d3/H (triggered), == 0 (untriggered) | 141/141 exact match |
| paper Lemma 2.2 bound g_V ≤ 1/(d2·d3) | violated in 126/126 triggered cases |
| paper Lemma 2.2 bound g_V ≤ 1/H² | violated in 126/126 triggered cases |

Smallest counterexample: q=7, m=5: d2=3, d3=6, H=6, solutions/period = 3 (not ≤1),
g_V = 1/6 (paper claims ≤ 1/18 and ≤ 1/36).

## Receipt 2 — Sieve dimension: κ_V = 1, not 0

S(z) = Σ_{3<p≤z, triggered} (log p)/H_p computed exactly for all p ≤ 10^6 (78,496 primes):

| z | S(z), m=5 | S(z), m=7 | S(z), m=35 | Σ 1/H_p | loglog z | Σ logp/H_p² | frac H=p−1 |
|---|---|---|---|---|---|---|---|
| 10^3 | 4.64 | 4.71 | 4.49 | 1.712 | 1.933 | 0.300 | 0.7410 |
| 10^4 | 6.82 | 6.92 | 6.73 | 2.133 | 2.220 | 0.303 | 0.7164 |
| 10^5 | 9.08 | 9.18 | 9.01 | 2.492 | 2.443 | 0.303 | 0.7021 |
| 10^6 | 11.37 | 11.46 | 11.29 | 2.797 | 2.626 | 0.303 | 0.6982 |

Slope of S(z) against log z over z ∈ [10^4, 10^6]: **0.987 (m=5), 0.986 (m=7), 0.990 (m=35)**.
Heuristic explanation: E_m[g_V(p)] = (H/(p−1))·(1/H) = 1/(p−1), so Σ g log p ~ log z; slope = 1.
Verdict: **κ_V = 1 (linear sieve), Prop 2.3 (κ_V=0) BROKEN.**
Side claims: Σ 1/H_p = O(loglog z) — consistent (Remark 3.4 plausible-TRUE);
Σ (log p)/H_p² = O(1) — TRUE (converged at 0.303).

## Receipt 3 — Singular series eq:S-defn diverges to 0

Partial product Π_{p≤z, trig}(1 − p/((p−1)H_p)) (the literal eq:S-defn/eq:S-trig):

| z | m=5 | m=7 | m=35 |
|---|---|---|---|
| 10^3 | 0.2625 | 0.2257 | 0.3253 |
| 10^6 | 0.1340 | 0.1148 | 0.1646 |
| ratio | 0.5104 | 0.5087 | 0.5059 |

Predicted ratio if W(z) ~ C/log z (κ=1 behavior): log10^3/log10^6 = 0.5000. Match to 3 digits.
W(z)·log z is constant: C(5) ≈ 1.85, C(7) ≈ 1.58, C(35) ≈ 2.27 (each stable across 10^4–10^6).
Verdict: **𝔖(m) per eq:S-defn equals 0 for every m; Prop 5.2 (𝔖 ≥ c_0 > 0) BROKEN as stated.**
The convergent object is the Bateman–Horn-normalized Π(1−g_V(p))/(1−1/p) (positive constant).

## Receipt 4 — Per-q discrepancy (m=5, D=3000, |T_D| = 4,504,501)

E_corr = count − |T_D|/H (correct main term). E_gq = count − (g/q)|T_D| (paper eq:E-defn literal).
E_h2 = count − |T_D|/H² (paper Lemma 3.2 Case 2 main term). ETK = paper bound D·log(H)/H.

| q | H | count | E_corr | E_gq | E_h2 | ETK bound | D |
|---|---|---|---|---|---|---|---|
| 7 | 6 | 751000 | **249.8** | 643750 | 625875 | 895.9 | 3000 |
| 11 | 10 | 450300 | −150.1 | 409350 | 405255 | 690.8 | 3000 |
| 13 | 12 | 375750 | 374.9 | 346875 | 344469 | 621.2 | 3000 |
| 23 | 11 | 409500 | −0.1 | 391696 | 372273 | 654.0 | 3000 |
| 41 | 40 | 112575 | −37.5 | 109828 | 109760 | 276.7 | 3000 |
| 73 | 36 | 0 (untrig.) | 0 | 0 | 0 | — | 3000 |
| 109 | 108 | 41666 | −42.3 | 41283 | 41280 | 130.1 | 3000 |
| 151 | 150 | 30040 | 10.0 | 29841 | 29840 | 100.2 | 3000 |
| 257 | 256 | 17578 | −17.7 | 17510 | 17509 | 65.0 | 3000 |
| 1009 | 504 | 9018 | 80.5 | 9009 | 9000 | **37.0** | 3000 |

Verdicts: against the paper's own main terms the "error" is ~|T_D|/H ≈ D²/(2H) — Lemma 3.2 /
Prop 3.1 FALSE as literally stated. Against the corrected main term |T_D|/H the error is O(D)
(usually ≪ D), so **Prop 3.1's conclusion survives the correction for prime moduli** with room
to spare (Σ_q O(D) = O(D^{3/2}) ≪ D²/(log D)^A). The refined ETK bound D·logH/H fails with
implied constant 1 at q=1009 (80.5 > 37.0); the safe elementary bound is O(D).

## Receipt 5 — Empirical claims spot-check

| claim | result |
|---|---|
| V(6,257,518,159, 16, 10) prime | TRUE (sympy.isprime) |
| minimal first-prime diagonal for m=6,257,518,159 | exactly 26 (full scan of T_25 has no prime) |
| sweep m ≤ 10^5 (33,334 ordinary m) | all have witnesses; max first-prime diagonal 11 at m=74563 (consistent with paper's "max 17 for m ≤ 10^6") |
| π_V(5,D): D=10→23, 20→51, 30→79, 40→118, 50→152, 60→188 | growth ≈ 3.1·D, linear — the THEOREM SHAPE π_V ≍ D is empirically supported even though the proof is broken |
| π_V(7,D): D=60→187 | same linear shape |

## One-line summary

The paper's load-bearing Lemma 2.2 bound g_V ≤ 1/H² is false (truth: g_V = 1/H exactly);
with the true density the family is a **κ = 1 linear sieve with a parity barrier**, the literal
singular series is 0, and the κ=0 architecture (Prop 2.3 → Prop 3.1 main term → §4 Brun-suffices
→ §6 folklore conversion) collapses — while the BV error-term summation (corrected main term,
prime moduli) and the empirical theorem-shape both survive and are certified above.
