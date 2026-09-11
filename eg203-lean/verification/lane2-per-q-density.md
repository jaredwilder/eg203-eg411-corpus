# LANE 2 — Per-q Local Density: Exact-Computation Receipt
**Target:** `wilder-2026-V-family-rosser-iwaniec.tex` §3 Lemma 3.2 (`lem:per-q`), with upstream Lemma 2.2 (`eq:g-pointwise`) and downstream Prop 3.1 (`prop:BV`), §4 `W(z)`.
**Generator:** `lane2_per_q_density.py` (this directory). Full machine receipt: `lane2-per-q-density-receipts.json`.
**Date:** 2026-06-10. All counts exact integers; all discrepancies exact rationals (`fractions.Fraction`).

---

## VERDICT (lane top claim: "the §3 discrepancy lemma — suspected h vs h² slip")

**MIXED — the suspicion is confirmed and is worse than a slip in one lemma.**

| Claim | Status |
|---|---|
| Lemma 3.2 "density 1/h²" / expected count `\|T_D\|/h²` | **BROKEN** — true density is **1/h**. Off by factor h in 5,596/5,596 (100%) of triggered (q,m) pairs tested. |
| Lemma 2.2 `g_V ≤ 1/(d2·d3) ≤ 1/H²` | **BROKEN** — `count per period > 1` in 5,586/5,596 triggered pairs (99.8%); the `≤ 1/H²` half fails in 100% of triggered pairs. |
| Ground truth `g_V = 1/H_q` (triggered), `0` (untriggered) | **VERIFIED** — 6,659 (q,m) pairs, 0 exceptions; independently brute-forced on 128 pairs, 0 exceptions. |
| Corrected Lemma 3.2′ (main term `\|T_D\|/H`, error `O(D)`) | **VERIFIED** — max measured `\|E\|/(D+1)` = 0.0836 across the T_D grid; the explicit bound `4(D+q)` holds with ≥ 47× margin. |
| Prop 3.1 conclusion (with corrected main term, prime moduli) | **VERIFIED / STRENGTHENED** — measured Σ\|E\| at D=3000 beats the required bound by 89×; level extends to Q = D^{1−ε} for prime moduli. |
| §4 `W(z) = Π(1−g_V) ≥ 𝔖(m) ≥ c₀ > 0` under the corrected density | **BROKEN** — `W(z)·log z → C(m)` (converged to 4 digits by z=10⁶), so `W(z) → 0` like `C(m)/log z`. The family is a **κ = 1 linear sieve** (measured slopes 0.987–0.993), not κ = 0. The Theorem 1.1 chain does not survive. |

---

## 1. Ground truth (recomputed from scratch)

For prime q ∤ 6m: `d2 = ord_q(2)`, `d3 = ord_q(3)`, `H_q = |⟨2,3⟩ mod q|`. Since (ℤ/q)ˣ is cyclic, `H_q = lcm(d2,d3)` — confirmed by explicit subgroup closure for every q ≤ 300 (0 failures).

**Local count law (verified exactly):** the number of (k,ℓ) ∈ [0,d2)×[0,d3) with q | V(m,k,ℓ), i.e. 2^k·3^ℓ ≡ −m⁻¹ (mod q), equals

```
d2·d3/H_q = gcd(d2,d3)   if q is triggered for m  (−m⁻¹ ∈ ⟨2,3⟩ mod q)
0                         otherwise
```

so the local density is **g_V(q,m) = 1/H_q** (triggered), 0 (untriggered).

*Proof shape (finite group theory):* ψ : ℤ/d2 × ℤ/d3 → ⟨2,3⟩ mod q, ψ(k,ℓ) = 2^k·3^ℓ, is a surjective homomorphism onto a group of order H; every fiber has exactly d2·d3/H points.

**Receipt A (fast method):** all 667 primes 3 < q ≤ 5000 × 10 ordinary m ∈ {1, 5, 7, 25, 35, 143, 1001, 6257518159, 10¹²+7, 10¹⁸+9} = **6,659 pairs (5,596 triggered): 6,659/6,659 exact matches.**
**Receipt A2 (independent brute force, full double loop over the period):** q ≤ 200, m ∈ {5, 35, 6257518159} = 128 pairs: **128/128 matches with the fast method.**

**Smallest counterexample to the paper:** q=5, m=1: d2=d3=4, H=4, count per 4×4 period = **4** (density 1/4 = 1/H). Paper Lemma 2.2 claims ≤ 1/16 (= 1/(d2·d3) = 1/H²): wrong by factor 4. The factor by which the paper's 1/H² density is off equals H: range over tested triggered pairs **min 4, median 1906, max 4998**.

**Where the slip sits in the text.** Lemma 3.2's own proof derives the *correct* per-period count: "*has either zero or exactly d_q(2)·d_q(3)/h solutions in a single (d_q(2),d_q(3))-period*" — and then mis-divides in the very next sentence: "*Hence the density of solutions … is either 0 or 1/h².*" The correct division is (d2·d3/h)/(d2·d3) = **1/h**. The 1/h² figure descends from Lemma 2.2's kernel-index error ("*within one H_p² block there is at most one preimage*" — false: ker ψ̃ ⊂ ℤ² has index H, so an H×H block contains ~H kernel points, not ≤ 1). **Internal smoking gun:** §5 (`eq:S-trig`) already states "*Recall g_V(p,m) = 1/H_p if p is triggered … (per Granville C3 in the Pass-3 review)*" — the correct value — flatly contradicting Lemma 2.2/3.2 (1/H ≤ 1/H² iff H ≤ 1, never). The paper carries both densities simultaneously and the κ=0 architecture was never updated to the corrected one.

---

## 2. T_D discrepancy: which main term is right (Receipt B)

Exact counts of #{(k,ℓ) ∈ T_D : q | V} vs three candidate main terms (D ∈ {300, 3000}; m ∈ {5, 7, 6257518159}; q ∈ {7, 23, 73, 251, 601, 1009, 2003, 4999}; 46 cells, 36 triggered). Excerpt (D = 3000, |T_D| = 4,504,501):

| q | m | H | exact count | `\|T_D\|/H` (corr) | E_corr | `\|T_D\|/H²` (paper L3.2) | E_h2 | `\|T_D\|/(qH)` (paper eq:E-defn) | E_overq |
|---|---|---|---|---|---|---|---|---|---|
| 7 | 5 | 6 | 751,000 | 750,750.2 | **+249.8** | 125,125.0 | +625,875 | 107,250.0 | +643,750 |
| 23 | 5 | 11 | 409,500 | 409,500.1 | **−0.1** | 37,227.3 | +372,273 | 17,804.3 | +391,696 |
| 251 | 5 | 250 | 18,036 | 18,018.0 | **+18.0** | 72.1 | +17,964 | 71.8 | +17,964 |
| 1009 | 5 | 504 | 9,018 | 8,937.5 | **+80.5** | 17.7 | +9,000 | 8.9 | +9,009 |
| 4999 | 5 | 4998 | 898 | 901.3 | **−3.3** | 0.18 | +898 | 0.18 | +898 |

- Against the corrected main term `\|T_D\|/H`: max |E|/(D+1) over all 36 triggered cells = **0.0836** (at q=7, where gcd(d2,d3)=3 — genuinely Θ(D), linear from D=300 to 3000: 24.8 → 249.8).
- Against the paper's `\|T_D\|/H²`: the "error" **equals the main term itself** (E_h2 ≈ 83–100% of the true count). Same for the `/q` variant of `eq:E-defn`. Both paper normalizations are not approximations of the count at all.
- Untriggered q (73 for m=5,7; 601 for all): exact count **0**, exactly as the trigger dichotomy predicts (and q=73 flips to triggered for m=6257518159 — trigger is m-dependent, verified).
- The §3 "sharper ETK bound" |E| ≤ O(D·log h/h) **fails with implied constant 1**: ratio H·|E|/(D·log H) reaches **4.54** (q=1009, m=5, D=300), **5.68** (q=4999, m=6257518159, D=300). The safe elementary statement is |E| = O(D) — see corrected lemma below.

## 3. BV summation strengthening (Receipt C)

D = 3000, m = 5, corrected main term, exact Σ|E| over prime moduli:

| range | #primes | measured Σ\|E_corr\| | required `D²/(log D)²` | margin |
|---|---|---|---|---|
| q ≤ 54 (= D^{1/2}) | 13 | **1,575.6** | 140,401 | **89×** |
| q ≤ 1000 | 165 | **3,385.9** | 140,401 | 41× |

Max single |E| = 374.9 (q = 13). With per-q bound 4(D+q): Σ_{q≤Q} |E| ≤ 4(D+Q)·π(Q) = O(D^{3/2}/log D) at Q = D^{1/2−ε} — beats `D²/(log D)^A` for every A by a power of D, with **no ETK input, no κ input, no Pappalardi input**. Prime-moduli level extends to **Q = D/(log D)^{A+1}**.

## 4. The corrected exponent propagated downstream (Receipt D)

With g_V = 1/H (triggered), over all primes 3 < p ≤ 10⁶ (78,496 primes; orders computed for every p; trigger tested exactly per m):

**κ_V = 1, not 0.** Measured slope of Σ_{p≤z} g_V(p)·log p between z = 10⁴ and 10⁶: m=5: **0.9868**, m=7: **0.9858**, m=35: **0.9901**, m=6257518159: **0.9934**. (Heuristic identity: E_m[g_V(p)] = (H/(p−1))·(1/H) = 1/(p−1) ⇒ slope exactly 1.) Fraction of primes with ⟨2,3⟩ = (ℤ/p)ˣ: **0.6982** (rank-2 Artin density ≈ 0.69755); these primes alone force κ ≥ 0.698.

**W(z) → 0 like C(m)/log z** (κ=1 Mertens behavior), refuting `W(z) ≥ 𝔖(m) ≥ c₀ > 0`:

| m | W(10³)·log z | W(10⁴)·log z | W(10⁵)·log z | W(10⁶)·log z | W(10⁶)/W(10³) [C/log z predicts 0.500] |
|---|---|---|---|---|---|
| 5 | 1.9517 | 1.9817 | 1.9895 | **1.9927** | 0.5105 |
| 7 | 1.7688 | 1.7888 | 1.7970 | **1.7999** | 0.5088 |
| 35 | 2.3297 | 2.3477 | 2.3542 | **2.3577** | 0.5060 |
| 6257518159 | 1.3689 | 1.3791 | 1.3826 | **1.3830** | 0.5051 |

The paper-side sums for contrast: Σ log p/H² (the paper's claimed κ-sum ceiling) indeed converges (≈ 0.20–0.29 by z=10⁶, m-dependent) — the inequality Σ g log p ≤ Σ log p/H² is simply false because g = 1/H, not ≤ 1/H².

**Strengthen/weaken verdict for the chain:**
- **Prop 3.1: STRENGTHENED.** With the corrected main term the per-q error is elementary O(D); the BV-style sum is O(D^{3/2}) ≪ D²/(log D)^A; no exponential-sum machinery needed; prime-moduli level improves from D^{1/2−ε} to D^{1−ε}. (Caveat unchanged from Lane 0 E6/L3: §4 needs *squarefree composite* moduli up to z^r = D^{10/3}; nothing here supplies that.)
- **§4 and the main theorem: FATALLY WEAKENED.** κ_V = 1 ⇒ (i) the Brun pure sieve at fixed depth r=10 loses its `1+O(e^{−r})` loss claim; (ii) the lower-bound linear sieve needs s = log Q/log z > β = 2, but the paper's parameters give s = 3/2 − 3ε < 2 ⇒ f(s) = 0, the sieve lower bound is vacuous; (iii) even at s ≈ 3 (using the strengthened prime level), the output counts z-rough values, and the rough→prime conversion at κ=1 hits the parity barrier the paper claimed to be exempt from; (iv) `𝔖(m)` as defined (`eq:S-defn`/`eq:S-trig`) is 0 for every m, so both Thm 1.1 and the Lean axiom `V_family_singular_series_uniform_lower_bound` are vacuous/false as stated (Lane 0 E5 concurs from the §5 side).

---

## 5. CORRECTED STATEMENTS (drop-in replacements)

**Lemma 2.2′ (local density — exact value, replaces `lem:g-pointwise`).**
*Let q > 3 be prime, q ∤ 6m, d2 = ord_q(2), d3 = ord_q(3), H_q = |⟨2,3⟩ mod q| = lcm(d2,d3). Then the number of (k,ℓ) ∈ [0,d2)×[0,d3) with V(m,k,ℓ) ≡ 0 (mod q) equals d2·d3/H_q = gcd(d2,d3) if −m⁻¹ ∈ ⟨2,3⟩ mod q, and 0 otherwise. Equivalently:*

```
g_V(q,m) = 1/H_q   if q triggered for m,     g_V(q,m) = 0   otherwise.
```

*In particular g_V(q,m) ≤ 1/max(d2,d3) always (this half of the old proof was correct), and the bounds 1/(d2·d3), 1/H_q² are unattainable for any triggered q with H_q ≥ 2.*

**Lemma 3.2′ (per-prime discrepancy, replaces `lem:per-q`; also fixes `eq:E-defn`).**
*Define (no /q — `g_V` is already a density per `eq:gV-defn`):*

```
E_V(D,q,0) := #{(k,ℓ) ∈ T_D : q | V(m,k,ℓ)} − g_V(q,0,m)·|T_D|.
```

*Then for every prime q ∤ 6m: |E_V(D,q,0)| ≤ 4(D + q). (Untriggered q: E_V = 0 exactly.)*

*Proof sketch (elementary, no ETK):* the solution set is, per ℓ-row, a single residue class k ≡ k₀(ℓ) (mod d2) on exactly s = gcd(d2,d3) residues of ℓ (mod d3). Row counting gives the main term s·D²/(2·d2·d3) = D²/(2H) with per-row error ≤ 1 and row-distribution error ≤ s·(D/d3 + 1); collecting, |E| ≤ 4D + 2q ≤ 4(D+q). Measured worst case on the test grid: |E| ≤ 0.084·(D+1) — margin ≥ 47×.

**Prop 3.1′ (BV level, prime moduli — strengthened).**
*For all A > 0 and Q ≤ D/(log D)^{A+1}: Σ_{q ≤ Q, q prime, q∤6m} |E_V(D,q,0)| ≤ 8·D·Q/log Q = O(D²/(log D)^A), uniformly in ordinary m.* (At the paper's level Q = D^{1/2−ε} the sum is O(D^{3/2}), a power-of-D stronger than required.)

**Downstream patch required (cannot be absorbed):** with g_V = 1/H, Definition 2.1's sum Σ g_V(p) log p grows like 1·log z ⇒ **κ_V = 1**. Every consequence drawn from κ_V = 0 (Prop 2.3, Thm 4.1, Prop 4.2, `eq:asymp-sieve`, the "no parity barrier" claim, Prop 5.2 positivity, and the witness (c, D₀) = (0.25, 10⁸⁷) for the Lean axiom) must be re-derived in the κ = 1 linear-sieve regime or withdrawn. The salvageable singular-series object is the Bateman–Horn normalization Π_p (1 − g_V(p,m))/(1 − 1/p)^{κ}, κ=1 — the constant C(m) measured in §4 above (e.g. C(5) ≈ 1.993·e^{γ-correction}); a corrected paper must restate `eq:S-defn` in that normalized form and re-anchor [WilderChain103]'s 1/128 translation to it.

---

## 6. Lean kernel candidates (statements only; all finite/decidable)

**(K1) Per-pair instance law** — for each fixed prime q and fixed m (decidable; the 6,659-row JSON is the witness table; each row is `native_decide`-able):

```lean
-- count over one (d2,d3) period equals gcd d2 d3 or 0
example : ((Finset.range 3 ×ˢ Finset.range 6).filter
    (fun kl => (5 * 2 ^ kl.1 * 3 ^ kl.2 + 1) % 7 = 0)).card = 3 := by native_decide
```

**(K2) General local-count theorem** (finite group theory; provable via `ZMod`, `orderOf`, fiber-counting of the hom `ψ`):

```lean
theorem V_local_period_count (q : ℕ) (hq : Nat.Prime q) (m : ℕ) (hm : ¬ q ∣ 6 * m) :
    let d2 := orderOf (2 : ZMod q); let d3 := orderOf (3 : ZMod q)
    ((Finset.range d2 ×ˢ Finset.range d3).filter
        (fun kl => ((m : ZMod q) * 2 ^ kl.1 * 3 ^ kl.2 + 1 = 0))).card
      = if ∃ k ℓ : ℕ, ((m : ZMod q) * 2 ^ k * 3 ^ ℓ + 1 = 0)
        then Nat.gcd d2 d3 else 0
```

**(K3) Corrected discrepancy bound** (elementary lattice counting; formalizable without analytic input):

```lean
theorem V_TD_discrepancy (q m D : ℕ) (hq : Nat.Prime q) (hm : ¬ q ∣ 6 * m) :
    let H := Nat.lcm (orderOf (2 : ZMod q)) (orderOf (3 : ZMod q))
    let cnt := ((Finset.range (D+1) ×ˢ Finset.range (D+1)).filter
        (fun kl => kl.1 + kl.2 ≤ D ∧ ((m : ZMod q) * 2 ^ kl.1 * 3 ^ kl.2 + 1 = 0))).card
    let triggered := ∃ k ℓ : ℕ, ((m : ZMod q) * 2 ^ k * 3 ^ ℓ + 1 = 0)
    (triggered → |(cnt : ℤ) * (2 * H) − ((D+1) * (D+2) : ℤ)| ≤ (8 * (D + q)) * H) ∧
    (¬ triggered → cnt = 0)
-- integer-cleared form of |cnt − |T_D|/H| ≤ 4(D+q)
```

K1 is immediate. K2 is the real kernel prize (one finite-group lemma kills Lemma 2.2/3.2's error permanently). K3 needs a short lattice-row argument, no sieve theory.

---

## Files

- `lane2_per_q_density.py` — generator (exact integer/rational arithmetic; runtime ≈ 5 s).
- `lane2-per-q-density-receipts.json` — full machine receipt: 6,659 part-A rows, 46 T_D cells, BV sums, κ/W(z) checkpoints.
- This file — human-readable receipt + corrected statements.

**Cross-lane consistency:** independently reproduces Lane 0's E1 (g_V = 1/H), E3 (the /q slip), E4 (h vs h² + ETK constant failure + O(D) safe bound), and the κ=1 / W·log z → C measurements (Lane 0 Receipt 2/3 values match to 3–4 digits where comparable: e.g. W-ratios 0.5105/0.5088/0.5060 vs Lane 0's 0.5104/0.5087/0.5059).
