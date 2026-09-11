# LANE 4 — §6 Almost-prime → prime conversion (sec:almost-prime): verification receipts

Date: 2026-06-10. Generator: `lane4_verify.py` (this directory). Full numeric tables:
`lane4-almost-prime-receipts.json`. Independent cross-check (separate code path,
naive big-int arithmetic): `lane4-thm61-counterexample-crosscheck.json` — agrees exactly.

Paper under test: `public/proofs/eg203/paper/wilder-2026-V-family-rosser-iwaniec.tex`
(§6 = "Almost-prime to prime conversion" in `05-almost-prime-and-constants.tex`,
consuming §4's eq:S-bound-DD).

Ground-truth local density used throughout (re-derived, matches Lane 0's 141/141 exact check):
for prime p ∤ 6m, H_p = lcm(ord_p 2, ord_p 3); p triggered for m iff (−m^{−1})^{H_p} ≡ 1 (mod p);
density of p | V cells = 1/H_p if triggered, else 0.

---

## 0. What §6 actually argues (faithful report)

1. Input: §4's Brun output eq:S-bound-DD, S(A, P_z, z) ≥ (c_Brun/2)·𝔖(m)·D² at z = D^{1/3},
   where P_z = {primes p : 3 < p ≤ z, p ∤ m} (NB: the paper's sieve EXCLUDES 2 and 3).
2. eq:num-factors counts prime factors of V above z. The middle expression is mangled
   (denominator `D^{1/3} log D · 1/(D^{2/3})` = (log D)/D^{1/3} ≠ log z = (log D)/3);
   the final expression uses the correct (log D)/3. The paper concedes the count
   ~3D log6/log D "can be very large".
3. **Theorem 6.1 (thm:buchstab)** asserts: with z1 = D^{1/3}, z2 = cD for some c > 0,
   π_V(m,D) ≥ S(A, P_{z1}, z1) − Σ_{z1<p≤z2} S(A_p, P_{z1}, z1).
4. The "proof": (a) cites Buchstab's identity but writes S(A_p, P_{z1}, z1) where Buchstab
   has S(A_p, P_p, p) — the displayed "identity" is actually only a "≤"; (b) immediately
   concedes the factor count at z2 = cD is "still not bounded"; (c) concedes the
   "fundamental tension" — single-prime-factor⇒prime needs z2 > √V ≈ √m·6^{D/2},
   exponential in D; (d) pivots to "the fix: Iwaniec semilinear sieve", then asserts
   "Our situation is simpler" — that at κ_V = 0 "any reasonable lower-bound sieve gives an
   asymptotic prime count without needing the upper-bound matching argument" — and writes
   eq:asymp-sieve: π_V ~ |T_D|·𝔖(m)/log(m·6^D), citing "Iwaniec asymptotic sieve,
   HR \S25 [EXISTS-LOCATION]". HR 1974 is cited elsewhere by chapter-section (\S2.3);
   a "\S25" does not match the book's structure, and "asymptotic sieve at κ=0" is not a
   look-up-able named theorem (cf. L4's own admission). The proof never connects the
   displayed Buchstab inequality to π_V at all; QED is reached by assertion.

So the rough→prime step rests entirely on the unproven folklore eq:asymp-sieve.
That was Lane 0's structural reading. The findings below show it is worse: the
bridge inequality of Theorem 6.1 is not just unproven — it is **false on real data**,
and eq:asymp-sieve with the paper's own 𝔖 contradicts the data by 4 orders of magnitude.

---

## F1 — BROKEN: Theorem 6.1 (thm:buchstab) is numerically FALSE — 41/45 exact counterexamples

For m ∈ {5,35,65,95,115}, D ∈ {30,60,100}, c ∈ {0.5,1,2} (z2 = cD), all counts exact integers.
At z1 = D^{1/3} < 5 the paper's sieving set P_{z1} = {3 < p ≤ z1} is EMPTY, so
S(A, P_{z1}, z1) = |T_D| exactly. RHS = |T_D| − Σ_{5≤p≤z2} #{cells : p|V}.

Canonical counterexample (cross-checked by two independent code paths):

| quantity | value |
|---|---|
| m, D, c | 35, 100, 1 (z1 = 4.64, z2 = 100) |
| S(A, P_{z1}, z1) = X | 5151 |
| Σ_{z1<p≤z2} S(A_p, P_{z1}, z1) | 3453 |
| RHS of Theorem 6.1 | **1698** |
| π_V(35, 100) (exact, BPSW on every cell) | **411** |
| Theorem 6.1 claim π_V ≥ RHS | **FALSE** (off by 4.13×) |

Violations occur in 41 of 45 triples; RHS/π_V ranges up to 6.40 (m=35, D=100, c=0.5).
The 4 "holds" cases (e.g. m=5, D=100, c=2: RHS = 29; lane-convention RHS = −12) hold only
because over-subtraction has collapsed the RHS toward/below 0 — never because primes were
separated. Violation worsens with D at fixed c (m=35, c=1: 3.32× → 3.66× → 4.13×),
consistent with RHS = Θ(D²·(1 − Σ 1/H_p)) vs π_V = Θ(D). Structurally: Σ_{p≤cD} 1_trig/H_p
grows like δ·loglog D (measured: 1.07–1.23 at 10³ up to 1.75–1.90 at 10⁶), so
(1 − Σ) shrinks only loglog-slowly — the inequality stays false from D ≈ 50 up to
astronomically large D, and where it eventually "holds" it is vacuous (RHS < 0).
Theorem 6.1 never yields prime information at any scale. Whether 2,3 are included in
the sieve (lane convention) or excluded (paper convention) changes nothing (both columns
in the JSON; both falsify).

## F2 — BROKEN: eq:asymp-sieve with the paper's 𝔖 contradicts the data by ~4 orders of magnitude

The paper's singular series (eq:S-defn) measured at truncation P:
𝔖_paper(P)·log P is CONSTANT across P = 10³ → 10⁶
(m=5: 1.8135, 1.8412, 1.8483, 1.8513; all m similar) ⇒ 𝔖_paper(P) ~ C(m)/log P ⇒
**𝔖_paper(m) = 0** (independent in-lane confirmation of Lane 0's E5, root cause the /q
normalization slip; the true deficit per triggered p is p/((p−1)H_p) ≈ 1/H_p and
Σ 1/H_p diverges).

Consequences measured at D = 100:

| prediction | value (m=35) | actual π_V |
|---|---|---|
| thm:main bound c·c₀·D = 0.25·6.6e−4·D | 0.017 | 411 |
| eq:asymp-sieve X·c₀/log(m·6^D) | 0.019 | 411 |
| eq:asymp-sieve X·𝔖_paper(10⁶)/log(m·6^D) | 4.6 | 411 |
| corrected: 3·C_BH(m)·Σ_{elig} 1/log V | 409.9 | 411 |

The literal Theorem 1.1 inequality π_V ≥ c·𝔖(m)·D is "true" only because 𝔖(m) = 0 —
it is vacuous, and the companion Lean axiom `V_family_singular_series_uniform_lower_bound`
(𝔖 ≥ c₀ > 0) is false for eq:S-defn. Even granting the paper its finite truncation
𝔖(10⁶), eq:asymp-sieve underpredicts by 65–100× — because it evaluates log V at the
box maximum m·6^D instead of per cell (factor ≈ 4.1) and uses the wrong normalization
(no (1−1/p)⁻¹ renormalization; remaining factor ≈ 𝔖_partial-dependent).

## F3 — VERIFIED (the strengthening): the renormalized Bateman–Horn heuristic nails π_V to ±12%

Define C_BH(m) = Π_{3<p≤P} f_p with f_p = (1−1/H_p)/(1−1/p) if p triggered, 1/(1−1/p)
otherwise (incl. p | m). Partial products stabilize by P = 10⁶:

| m | C_BH(10³) | C_BH(10⁴) | C_BH(10⁵) | C_BH(10⁶) |
|---|---|---|---|---|
| 5 | 1.1632 | 1.1780 | 1.1815 | 1.1831 |
| 35 | 1.3885 | 1.3955 | 1.3981 | 1.3998 |
| 65 | 1.2039 | 1.2084 | 1.2081 | 1.2098 |
| 95 | 1.3408 | 1.3514 | 1.3485 | 1.3498 |
| 115 | 1.2183 | 1.2235 | 1.2223 | 1.2229 |

Prediction π̂ = 3·C_BH(m)·Σ_{cells: 2∤V, 3∤V} 1/log V (the 3 = local factors at p=2,3).
Actual/predicted over all 15 boxes: 0.81, 0.89, 0.91, 0.99, 1.06, 1.00, 0.89, 0.97, 1.01,
1.10, 1.12, 1.07, 0.93, 1.03, 0.97 — mean 0.98, all within ±12% (D=100 row: within ±7%).
Per-diagonal: prediction flattens to ≈ 3·C_BH·1.136 primes/diagonal (m=5: 3.92 at t=100);
20-diagonal band ratios 0.86–0.96. π_V growth is linear-in-D as the corrected heuristic
predicts (ratios π(100)/π(30) = 4.1–4.7 vs corrected-prediction ratios ≈ 3.8–4.3).

## F4 — VERIFIED: the family behaves as κ = 1, not κ = 0 — measured inside the box

z-curve at D = 100 (lane convention, sifting all p ≤ z): actual z-rough counts vs
N₀·Π_{3<p≤z}(1 − 1_trig/H_p) match to 0.9–5.3% at every z ∈ {5,…,10⁴} (the per-prime
density-1/H model is exact in-box). The κ discriminant: W(z)·log z is CONSTANT
(m=5: 1.92, 1.82, 1.89, 1.90, 1.95, 1.97, 1.98 for z = 10 → 10⁴) ⇒ W(z) ~ C/log z,
the Mertens/linear-sieve profile (κ = 1). A κ = 0 family would have W(z) → const > 0.
In-box corroboration of Lane 0's E1: the architecture premise "thin κ=0 regime" is wrong.

## F5 — BROKEN (the conversion itself): rough sets are composite-dominated at every polynomial z

Prime fraction among z-rough cells at D = 100 (m=5): 6.7% at z = D^{1/3}; 16.6% at z = D;
31.4% at z = 10⁴ ≈ D². The fraction grows ∝ log z exactly as 1/log V·(log z/C') predicts;
reaching fraction ≈ 1 requires log z ≈ ½ log V, i.e. z ≈ 6^{D/2} — exponential in D,
unreachable from the proven level Q = D^{1/2−ε}. Quantitatively at z = D^{1/3}:
S(A, z1) = Θ(D²) (≈ 5000 at D=100) while π_V = Θ(D) (≈ 340–410): the Brun output
overcounts primes by a factor ≈ D/(2·3·C_BH·1.136) — linear in D. No κ value changes
this: "rough at z = D^{1/3}" and "prime at size 6^D" differ by the unbridged factor log V/log z.
The paper's own "fundamental tension" paragraph concedes this; the "Our situation is
simpler" escape is a non sequitur — at these scales its sieving set P_{z1} is literally
EMPTY (z1 < 5), so S(A, P_{z1}, z1) = |T_D| and the Brun stage sifts nothing.

## F6 — CORRECTED (minor): bookkeeping slips in §6

- eq:num-factors middle expression mangled (see §0.2 above); conclusion unaffected.
- The Buchstab "identity" as displayed (with S(A_p, P_{z1}, z1)) is an inequality (≤), not
  an identity; the true identity needs S(A_p, P_p, p).
- "Iwaniec asymptotic sieve … HR \S25" — location does not exist in HR 1974's numbering
  style used elsewhere in the paper (\S2.3); the named "asymptotic sieve" lives in
  Bombieri 1976 / Friedlander–Iwaniec (Opera de Cribro 2010, Ch. 22), not IK 2004 —
  citation misdirection (UNTESTABLE-TONIGHT for verbatim content, location flagged).
- §4 setup note: "elements may coincide for different (k,ℓ)" — impossible; V is injective
  on (k,ℓ) by unique factorization. Harmless but should be deleted.

---

## Verdict for the lane

**BROKEN.** §6's rough→prime conversion does not exist as mathematics: its only
stated mechanism (Theorem 6.1) is exactly falsified at 41/45 tested parameter points
(certified counterexample m=35, D=100, c=1: π_V = 411 < RHS = 1698), its fallback
(eq:asymp-sieve) is an unproven folklore appeal whose paper-normalized form predicts
0.02 primes where 411 exist, and the conversion gap (rough = Θ(D²) vs prime = Θ(D))
cannot be bridged at any polynomial sieve level. The salvageable object is the
renormalized Bateman–Horn asymptotic π_V ≈ 3·C_BH(m)·Σ 1/log V (≈ (3·1.136)·C_BH(m)·D
for large D), verified to ±12% on 15 boxes — as a CONJECTURE replacing eq:asymp-sieve,
not a theorem.
