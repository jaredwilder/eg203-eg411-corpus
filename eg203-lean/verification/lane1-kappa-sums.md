# LANE 1 RECEIPT — κ_V = 0 claim (§2 / L1), sums Σ log q/H_q and Σ 1/H_q

Generated 2026-06-10 by `lane1_verify.py` (this directory). Companion data:
`lane1-kappa-sums.json`. Everything below is recomputed from scratch in exact
integer arithmetic wherever marked *certified*; floats are cross-checked to lie
inside certified rational brackets.

**Definitions used** (recomputed, trusted nothing): for prime q ≥ 5,
d2 = ord_q(2), d3 = ord_q(3), H_q = |⟨2,3⟩ mod q|. Method verification:
H_q = lcm(d2,d3) confirmed against explicit brute-force subgroup generation for
**all 1227 primes 5 ≤ q < 10^4** (PASS). Exact local density confirmed on
2561 (q,m) pairs (per-ℓ method, q < 3000) + 353 pairs (exhaustive (k,ℓ)
double loop, q < 300): **g_V(q,m) = 1/H_q if q triggered, else 0 — exactly,
every pair.**

---

## VERDICT TABLE (lane top claim: Prop 2.3, κ_V = 0)

| Claim | Where | Verdict |
|---|---|---|
| g_V ≤ 1/(d2·d3) ≤ 1/H² | Lemma 2.2 `eq:g-pointwise` | **BROKEN** — all 2126 triggered pairs tested violate g ≤ 1/H²; 2120 violate g ≤ 1/(d2d3). Smallest counterexample **q=5, m=7**: d2=d3=4, H=4, 4 solutions per 16-cell period, g_V = 1/4 vs claimed ≤ 1/16. (Independently confirms Lane 0's E1 with a smaller witness.) |
| Σ_{3<p≤z} g_V log p = O(1), uniform in m | Prop 2.3 `eq:kappa-claim` | **BROKEN — unconditionally, elementarily.** See "m-uniform kill" below: κ_V ≥ 1 by Mertens; measured per-m slope ≈ 0.99, majorant slope 1.6438 ≈ ζ(2). The family is a **κ = 1 linear sieve**. |
| #S_small(z) ≤ C z/(log z)^{2A} | Lemma 2.4 `eq:small-H-count` | **CORRECTED**: true with C = C(A) (A-dependent) and with huge slack — the truth is poly-log in z, not z/polylog: only **5** primes ≤ 10^6 have H < log z, vs bound ≈ 5239·C. As *literally written* ("absolute constant C_small … for every fixed A ≥ 1 and every z ≥ 100") it is false: at z=100 the required C grows like (log 100)^{2A} (A=3 ⇒ C ≥ 2194; A=6 ⇒ C ≥ 2.1×10^7; table in JSON `lemma24_uniform_constant_slip`). Non-load-bearing (use sites fix A=2). |
| N_j(z) ≤ C√(z·2^j) (Erdős–Pomerance form) | `eq:dyadic-count` | **VERIFIED** (max observed ratio N_j/√(z·2^j) = 0.0104 at j=14, z=10^6 — true with ≥ 96× slack everywhere). |
| N_j(z) ≤ C_Papp z/(log z)^{c0·log z/j} | `eq:papp-refined` (load-bearing) | **BROKEN — provably false for every C, c0 > 0.** Fixed witness p=11 (H=10 ∈ [8,16), j=4): M(z,10) ≥ 1 ∀z ≥ 11, RHS → 0. With C=c0=1 the bound fails for all z > 1.36×10^12; C=100: z > 5.1×10^17; c0=0.5: z > 10^337. Finite threshold exists for every (C,c0). |
| F-integral assembly "= o(1)" | `eq:F-bound` | **BROKEN even granting eq:papp-refined** (C=c0=1): RHS = 4.1×10^3 at z=10^4, 4.7×10^5 at 10^6, 5.2×10^7 at 10^8 — grows ~ z/2. The (log z)^{−c0 log z/log₂H} factor is only polylog-small at H ≈ √z, not "super-polynomially small". |
| z(log z)^{−2A} "is o(1) for A ≥ 1" | Lemma 2.8 `eq:large-H-sum` | **BROKEN** (confirms E2): value at z=10^6, A=1 is 5.2×10^3; at z=10^12 it is 1.3×10^9. Tends to ∞ for every fixed A. |
| Σ 1/H_q = O(loglog z) | Remark 3.4 (cited from §2 data) | **VERIFIED**: Σ 1/H_q = 1.640·loglog z − 1.513, R² = 0.99988. |
| Σ log q/H_q converges (the sum κ_V=0 hinges on) | lane brief framing | **BROKEN**: diverges linearly in log z, slope **1.6438 ≈ ζ(2) = 1.6449** (R² = 0.99989). |
| Σ log q/H_q² converges (paper's intended majorant under the false 1/H² bound) | implicit in §2 | **VERIFIED numerically**: 0.299555 (z=10^3) → 0.303298 (z=10^6), residual slope 1.2×10^−4. Converges — but it is the wrong sum, since g_V = 1/H not ≤ 1/H². |

---

## 1. Partial-sum table (all primes 5 ≤ q ≤ z; exact H_q; floats shown, certified brackets in §5)

| z | Σ 1/H_q | Σ log q/H_q | Σ log q/H_q² | Σ 1/H_q² | Σ_{trig,m=5} log q/H_q (count) |
|---|---|---|---|---|---|
| 10^3 | 1.7120 | 6.3316 | 0.299555 | 0.135740 | 4.6400 (138) |
| 10^3.5 | 1.9202 | 7.8859 | 0.301117 | 0.135953 | 5.7237 (368) |
| 10^4 | 2.1327 | 9.7179 | 0.302673 | 0.136133 | 6.8210 (1019) |
| 10^4.5 | 2.3207 | 11.5548 | 0.303043 | 0.136171 | 7.9543 (2809) |
| 10^5 | 2.4920 | 13.4276 | 0.303206 | 0.136187 | 9.0833 (7922) |
| 10^5.5 | 2.6532 | 15.3734 | 0.303282 | 0.136193 | 10.2219 (22494) |
| 10^6 | 2.7968 | 17.2735 | 0.303298 | 0.136194 | 11.3656 (64636) |

(Full 13-checkpoint table incl. half-decade points in the JSON.)

**Slope fits (z ≥ 10^4):**

| sum | fit | slope | R² |
|---|---|---|---|
| Σ log q/H_q | vs log z | **1.6438** (ζ(2)=1.6449 predicted by E[index]=Σ1/d²) | 0.99989 |
| Σ 1/H_q | vs loglog z | 1.6404 | 0.99988 |
| Σ log q/H_q² | vs log z | 0.000122 (converged) | — |
| triggered m=5 | vs log z | 0.9860 | 0.999987 |
| triggered m=7 | vs log z | 0.9880 | 0.999979 |
| triggered m=11 | vs log z | 0.9964 | 0.999950 |
| triggered m=25 | vs log z | 0.9782 | 0.999958 |
| triggered m=35 | vs log z | 0.9903 | 0.999989 |
| triggered m=49 | vs log z | 0.9848 | 0.999987 |

Decade windows of the per-m triggered sum are flat at ≈ 2.20–2.29 ≈ log 10
per decade for all six m — the signature of κ = 1, not κ = 0 (Def 2.1 with
κ=0 needs every window sum ≤ an absolute constant A).

Index distribution receipt: over the 78,496 primes ≤ 10^6, mean index
(q−1)/H_q = **1.6559** (ζ(2) = 1.6449); fraction with ⟨2,3⟩ the full group =
**0.698227** (rank-2 Artin density ≈ 0.6976).

---

## 2. The m-uniform kill (elementary, unconditional — strongest attack artifact)

Definition 2.1 requires Σ_{w<p≤z} g_V(p,m) log p ≤ κ log(z/w) + A **with one
absolute A for every ordinary m**. Since H_q | q−1, taking m ≡ −1 (mod q)
makes −m^{−1} ≡ 1 ∈ ⟨2,3⟩, i.e. q triggered, with g_V(q,m) = 1/H_q. By CRT
there is an ordinary m* with m* ≡ −1 mod every prime in (w, z]. Hence

  sup_m Σ_{w<q≤z} g_V(q,m) log q = Σ_{w<q≤z} log q/H_q ≥ Σ_{w<q≤z} log q/q = log(z/w) + O(1)

(last step: H_q ≤ q−1; Mertens, explicit via Rosser–Schoenfeld). So
**κ_V ≥ 1 unconditionally** — no Pappalardi input enters anywhere.
Prop 2.3 is not merely unproven; it is false.

Explicit finite witness (kernel-checkable): for the window (10, 100] (21 primes),

  m* = 4·(∏_{10<q≤100} q) − 1 = 43915580265628922376249564711081067  (35 digits, gcd(m*,6)=1)

Every one of the 21 primes is triggered (verified: −m*^{−1} ≡ 1 mod q for each), and

  Σ_{10<q≤100} g_V(q,m*) log q = Σ_{10<q≤100} log q/H_q = 2.540123 > 2.056818 = Σ log q/q.

Certified window growth (exact rational, scaled-integer):

  Σ_{10^4<q≤10^6} log q/H_q ≥ 709·11615123750335/(1024·2^40) = 7.314258.

Repeating the CRT trick on successive windows exceeds any fixed A.

---

## 3. Bucket counts N_j(10^6) vs the paper's two bounds

| j | H range | N_j(10^6) | EP bound √(z·2^j) (C=1) | ratio |
|---|---|---|---|---|
| 1 | [1,2) | 0 | 1414 | 0 |
| 2 | [2,4) | 0 | 2000 | 0 |
| 3 | [4,8) | 2 | 2828 | 0.0007 |
| 4 | [8,16) | 3 | 4000 | 0.0008 |
| 5 | [16,32) | 5 | 5657 | 0.0009 |
| 6 | [32,64) | 10 | 8000 | 0.0013 |
| 7 | [64,128) | 18 | 11314 | 0.0016 |
| 8 | [128,256) | 35 | 16000 | 0.0022 |
| 9 | [256,512) | 52 | 22627 | 0.0023 |
| 10 | [512,1024) | 117 | 32000 | 0.0037 |
| 11 | [1024,2048) | 209 | 45255 | 0.0046 |
| 12 | [2048,4096) | 399 | 64000 | 0.0062 |
| 13 | [4096,8192) | 696 | 90510 | 0.0077 |
| 14 | [8192,16384) | 1334 | 128000 | 0.0104 |

`eq:dyadic-count` (EP form) is true with ≥ 96× slack. `eq:papp-refined` is
false for buckets j=4 (p=11, p=13) and every nonempty fixed bucket once z is
large (thresholds in §VERDICT row 5 and JSON).

Lemma 2.4 spot check: at z=10^6, A=1: #{H < 13.8} = **5** ({5,7,11,13,23})
vs bound 5239·C_small. A=2: #{H < 190.9} = **56** vs 27.4·C_small (needs
C_small ≥ 2.04 at this z if C_small were claimed = 1; statement is fine for a
free constant, and asymptotically the count is polylog ≪ z/(log z)^{2A}).

---

## 4. Complete census of ALL primes (any size) with H_p ≤ 64

Method: any p with H_p = H divides gcd(2^H − 1, 3^H − 1); factor it for
H = 2..64 and keep p with H_p exactly H. Cross-checked against the sieve data
for p ≤ 10^6 (PASS). **The complete list — these are all the primes in the
universe with H ≤ 64:**

| H | primes | | H | primes |
|---|---|---|---|---|
| 4 | 5 | | 35 | 71 |
| 6 | 7 | | 36 | 37, 73 |
| 10 | 11 | | 40 | 41 |
| 11 | 23 | | 42 | 43 |
| 12 | 13 | | 43 | 431 |
| 16 | 17 | | 48 | 97 |
| 18 | 19 | | 52 | 53 |
| 23 | 47 | | 58 | 59 |
| 28 | 29 | | 60 | 61 |
| 30 | 31 | | | |

F(64) = 20 over all primes. All other H ≤ 64 buckets are EMPTY (no prime has
H_p ∈ {2,3,5,7,8,9,13,14,15,17,19,...}). This makes the small-H regime
*finite and enumerable* — far stronger than anything §2 cites.

---

## 5. Certified rational bounds (exact integer arithmetic; Lean-native_decide candidates)

Scaled-integer certificates with SCALE = 2^40, using
(bits−1)·(709/1024) ≤ (bits−1)·log 2 ≤ log q ≤ bits·log 2 ≤ bits·(710/1024),
bits = bit length of q (709/1024 = 0.692382… ≤ log 2 = 0.693147… ≤
710/1024 = 0.693359…):

| z | #primes | Σ 1/H_q certified | Σ log q/H_q certified |
|---|---|---|---|
| 10^4 | 1227 | ∈ [2344880062346, 2344880063570]/2^40 = [2.132655993, 2.132655994] | ∈ [8.969938, 10.461287] (float 9.717858) |
| 10^5 | 9590 | ∈ [2740029737526, 2740029747112]/2^40 = [2.492042529, 2.492042538] | ∈ [12.552836, 14.298422] (float 13.427619) |
| 10^6 | 78496 | ∈ [3075079922129, 3075080000621]/2^40 = [2.796768897, 2.796768968] | ∈ [16.284197, 18.246330] (float 17.273545) |

Exact integers: T1_hi(10^6) = Σ⌈2^40/H_q⌉ = **3075080000621**;
Tb_hi(10^6) = Σ⌈2^40·bits(q)/H_q⌉ = **28934565846105**;
Tb_lo(10^6) = Σ⌊2^40·(bits(q)−1)/H_q⌋ = **25859485806324**;
Tb_lo(10^4) = 14244362055989. Window: Tb_lo(10^6) − Tb_lo(10^4) =
11615123750335 ⇒ Σ_{(10^4,10^6]} log q/H_q ≥ 709·11615123750335/(1024·2^40)
= **7.314258**.

**Lean-formalizable statements (statement text only, no build):**

(A) *Lemma 2.2 falsifier — one-line kernel kill (decide/native_decide):*

```lean
-- d_5(2)=4, d_5(3)=4, H_5=4; Lemma 2.2 claims ≤ 1 solution per d2×d3 period.
-- Truth: 4 solutions of 7·2^k·3^ℓ + 1 ≡ 0 (mod 5) in range 4 × range 4,
-- so g_V(5,7) = 4/16 = 1/4 = 1/H > 1/16 = 1/(d2·d3) = 1/H².
example :
    ((Finset.range 4 ×ˢ Finset.range 4).filter
      (fun kl => (7 * 2 ^ kl.1 * 3 ^ kl.2 + 1) % 5 = 0)).card = 4 := by
  decide
```

(B) *Certified finite sum, z = 10^4 (light native_decide; use modular pow in `ordMod`):*

```lean
def ordMod (a q : ℕ) : ℕ :=             -- least e ≥ 1 with a^e ≡ 1 (mod q);
  (List.range (q - 1)).findIdx (fun e => Nat.powMod a (e + 1) q = 1) + 1
def Hsub (q : ℕ) : ℕ := Nat.lcm (ordMod 2 q) (ordMod 3 q)
def lane1Primes (n : ℕ) : List ℕ :=
  (List.range (n + 1)).filter (fun q => 5 ≤ q && Nat.Prime q)

-- Σ_{5≤q≤10^4 prime} ⌈2^40 / H_q⌉ = 2344880063570,
-- certifying Σ 1/H_q ≤ 2344880063570/2^40 < 2.13266  (and ≥ 2.13265 via floor sum).
theorem lane1_sum_inv_H_1e4 :
    ((lane1Primes 10000).map (fun q => (2 ^ 40 + Hsub q - 1) / Hsub q)).sum
      = 2344880063570 := by native_decide
```

(C) *Certified window growth (10^4, 10^6] — the κ=0 tension made kernel-checkable
(heavier native_decide, ~78k order computations; Nat.log2 q = bits−1):*

```lean
-- Σ_{10^4<q≤10^6 prime} ⌊2^40 · Nat.log2 q / Hsub q⌋ = 11615123750335,
-- certifying Σ log q/H_q over the window ≥ 709·11615123750335/(1024·2^40) > 7.31.
theorem lane1_window_growth :
    (((lane1Primes 1000000).filter (10000 < ·)).map
      (fun q => 2 ^ 40 * Nat.log2 q / Hsub q)).sum = 11615123750335 := by
  native_decide
```

(D) *m-uniform trigger witness (window (10,100], decide-light):*

```lean
-- m* = 4·∏_{10<q≤100} q − 1 satisfies m* % q = q − 1 for each window prime,
-- hence −(m*)⁻¹ ≡ 1 ∈ ⟨2,3⟩ mod q: every q triggered, g_V(q,m*) = 1/H_q.
example :
    [11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97].all
      (fun q => 43915580265628922376249564711081067 % q = q - 1) = true := by
  native_decide
```

---

## 6. Tail beyond 10^6 (what the paper's tail argument should have been)

The paper's tail rests on `eq:papp-refined` (false, §VERDICT). The honest
elementary substitute: every q with H_q = H divides gcd(2^H−1, 3^H−1), and
distinct q multiply into it, so Σ_{H_q=H} log q ≤ log gcd(2^H−1, 3^H−1).
Since H_q > log₂ q, q > 10^6 forces H ≥ 20. Hence, **certified**:

  Σ_{q>10^6} log q/H_q² ≤ Σ_{H≥20} log gcd(2^H−1, 3^H−1)/H².

Computed exactly for H ∈ [20, 2000]: partial value **0.198140**;
max_{20≤H≤2000} log gcd/H = 0.4713 (at H=36) vs the trivial log 2 = 0.6931;
149 values of H ≤ 2000 have gcd ≥ 2^40. For H > 2000 the only elementary
bound is log gcd ≤ H log 2, whose contribution Σ log 2/H **diverges** — so
even the *convergent* majorant Σ log q/H_q² has no elementary unconditional
convergence proof; it genuinely needs an index-distribution / gcd input
(Bugeaud–Corvaja–Zannier-type log gcd(2^H−1,3^H−1) = o(H) is still not
summable; one needs ≪ H/(log H)^{1+ε}). This is the irreducible residue of
L1 — but note it only protects the *wrong* sum: the sum that κ actually
needs (Σ log q/H_q, true g_V = 1/H) diverges regardless (§2).

---

## 7. What survives, corrected (downstream-safe fragments)

1. **True local density (proved structure, kernel-checkable per q):**
   g_V(q,m) = 1/H_q if (−m^{−1})^{H_q} ≡ 1 (mod q), else 0. Verified exactly
   on 2914 (q,m) pairs by two independent brute-force methods.
2. **Correct pointwise bound:** g_V(q,m) ≤ 1/H_q ≤ 1/max(d2,d3) — the *first
   half* of Lemma 2.2's proof (per-ℓ argument giving ≤ 1/d2, ≤ 1/d3) is
   correct; everything after "For the sharper bound" must be deleted.
3. **Correct sieve dimension:** κ_V = 1 (lower: m-uniform CRT + Mertens,
   unconditional; observed per-m slopes 0.978–0.996; m-uniform majorant slope
   1.6438 ≈ ζ(2)). Corrected Prop 2.3: Σ_{3<p≤z} g_V(p,m) log p = κ log z + O(1)
   with κ = 1 per fixed generic m; sup over m has the ζ(2) constant.
4. **Remark 3.4 input verified:** Σ 1/H_q = O(loglog z) holds (slope 1.640).
5. **Small-H structure far stronger than cited:** complete finite census
   F(64) = 20 over all primes (§4); for q ≤ 10^6 only 29 primes have
   H ≤ 100. Any future rewrite should cite the gcd(2^H−1,3^H−1) divisor
   structure, not Pappalardi asymptotics, for the small-H regime.

Consequence for the paper's architecture (other lanes' territory, noted for
the chain): at κ = 1 the "thin regime / no parity barrier / Brun suffices /
F(s) → 1" pillar collapses; the parity barrier applies in full to a κ = 1
linear sieve, and the Lean axiom `wilder_2026_V_family_rosser_iwaniec` is
backed by a proof whose dimension input is false at its first step.
