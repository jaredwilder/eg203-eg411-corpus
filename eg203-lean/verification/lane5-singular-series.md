# LANE 5 — Singular Series (L5, §5) + Constants (§6–7): receipt

Generator: `lane5_singular_series.py` (this directory). Machine receipt:
`lane5-singular-series-receipts.json`. All numbers below recomputed from scratch;
exact integers/rationals wherever stated. Date: 2026-06-10.

Conventions (verified against the paper §1/§5 and re-derived):
`H_q = |⟨2,3⟩ mod q| = lcm(ord_q 2, ord_q 3)` (brute-force subgroup check for all
q ≤ 2000: 0 mismatches); `g_V(q,m) = 1/H_q` if `−m⁻¹ mod q ∈ ⟨2,3⟩` ("triggered"),
else 0 (brute-force check of eq:gV-defn on 386 (q,m) pairs: 0 mismatches);
`𝔖_Q(m) = Π_{3<q≤Q} (1 − g_V(q,m)·q/(q−1))` (truncation of eq:S-defn; every factor
≤ 1, so `𝔖(m) = inf_Q 𝔖_Q(m)`). Survey: all 500 ordinary m ≤ 1500, 60 random
12-digit ordinary m, the paper's record m = 6,257,518,159, and 4 adversarial
primorial constructions. 9590 primes in (3, 10⁵].

---

## 1. ATTACK — Prop 5.2 (𝔖(m) ≥ c₀ > 0) is BROKEN; 𝔖(m) per eq:S-defn is 0

**Measured decay (the E5 confirmation at scale).** For all 560 surveyed m,
`𝔖_Q(m)·ln Q` is constant in Q (pure Mertens-type decay `𝔖_Q ≈ C(m)/ln Q`):

| Q | min over 500 m | median | max | median·ln Q |
|------|---------|---------|---------|---------|
| 10³ | 0.16262 (m=389) | 0.19828 | 0.40267 | **1.3697** |
| 10⁴ | 0.12288 (m=1433) | 0.14875 | 0.30347 | **1.3701** |
| 10⁵ | 0.09862 (m=1433) | 0.11941 | 0.24370 | **1.3747** |

Per-m constancy test `(𝔖_{10⁵}·ln10⁵)/(𝔖_{10³}·ln10³)`: median 1.0052
(IQR ≈ [0.99, 1.02]); if there were no decay the ratio would be 1.667.
Per-m log-deficit growth `Σ_trig q/((q−1)H_q)` from Q=10³ to 10⁵: median 0.5056 vs
`lnln10⁵ − lnln10³ = 0.5108`. The 60 random 12-digit m show the identical
distribution (median 0.1196 at Q=10⁵). **Conclusion: 𝔖(m) = lim_Q 𝔖_Q(m) = 0 for
every tested m; the Lean axiom `V_family_singular_series_uniform_lower_bound`
(𝔖 ≥ c₀ > 0) is FALSE for eq:S-defn, and `wilder_2026_V_family_rosser_iwaniec`
becomes vacuous (c·0·D ≤ π_V).** Note the truncations themselves never dip near
c₀ = 6.6×10⁻⁴ at feasible Q (min 0.0986 at Q=10⁵ is 149× above c₀); the bound
fails only in the limit — but there it fails totally. Crossing scale:
Q* ≈ exp(1.37/6.6×10⁻⁴) ≈ e^2076 ≈ 10^901.

**The precise broken proof step (§5, tail paragraph).** The proof asserts
`Σ_{p>P₀} 1/H_p ≤ C/log P₀` (a bounded, vanishing tail). Measured:
`Σ_{7<p≤z} 1/H_p` = 1.2953 (z=10³) → 1.7320 (10⁴) → 2.0754 (10⁵) — unbounded,
growing ~ lnln z, exactly as the paper's own Remark 3.4 (`Σ 1/H = O(loglog z)`)
implies. A divergent series has no finite tail; the §5 tail bound is
self-contradictory with Remark 3.4. The "Strategy" item 1 sum
`Σ 1/(H_p(p−1))` does converge (= 0.1285 at 10⁵) but is the wrong object: the
per-factor deficit of eq:S-defn is `q/((q−1)H_q) ≈ 1/H_q`, not `1/(H_q(q−1))` —
the recurring /q normalization slip (cf. E3/E5).
The two micro-steps that ARE correct: `1 − p/((p−1)H) ≥ 1 − 1/(H−1)` (algebra:
H ≤ p−1) and `≥ 1/2 for H ≥ 4` (and indeed min H = 4, attained at q = 5, so the
global per-factor minimum is 1 − 5/16 = 11/16).

**Uniformity is dead even after renormalization (new attack, beyond E5).**
The natural salvage is the true Bateman–Horn normalization
`𝔖_BH,Q(m) = Π_{3<q≤Q} (1 − g_V q/(q−1))/(1 − 1/q)`, whose factors average
1 + O(1/q²) over random m, so it converges in distribution. But the uniform-in-m
lower bound still fails. Construction: `m_B = primorial(B) − 1` (≡ −1 mod every
prime ≤ B, ordinary since ≡ 5 mod 6) has `−m_B⁻¹ ≡ 1 ∈ ⟨2,3⟩ mod q` for ALL
3 < q ≤ B — every prime triggered. Measured at truncation Q = 10⁵:

| m | 𝔖_{10⁵} | 𝔖_BH,10⁵ |
|---|---------|----------|
| 500-sample min / median | 0.0986 / 0.1194 | 0.6743 / 0.8164 |
| primorial(100)−1 (37 digits) | 0.09889 | 0.67612 |
| primorial(1000)−1 (416 digits) | 0.08505 | 0.58151 |
| primorial(5000)−1 (2134 digits) | 0.07852 | 0.53687 |
| primorial(10⁵)−1 (43293 digits) | 0.06512 | 0.44523 |

primorial(1000)−1 already sits below the entire 500-m sample in BOTH columns.
**Unconditional divergence mechanism:** every prime q ≡ ±1 (mod 24) has 2 and 3
both quadratic residues, so ⟨2,3⟩ ⊆ QR and H_q ≤ (q−1)/2 (index ≥ 2); for such a
triggered q the BH log-deficit is ≥ (1/H_q − 1/q) ≥ 1/q + O(1/q²); by Dirichlet,
`Σ_{q≡±1(24)} 1/q = ∞` (density 1/4 of primes; measured index≥2 fraction
2857/9590 = 29.8%). Hence `inf_m 𝔖_BH,B(m) → 0` as B → ∞. **No re-normalization
of the local factors can restore a uniform-in-m positive constant; only per-m
positivity (𝔖_BH(m) > 0 for each fixed m) is potentially salvageable, and that
changes both Lean axioms from uniform to m-dependent form.** (Conversely
`sup_m 𝔖_Q(m) = 1` for every Q — take m divisible by every prime ≤ Q — so no
uniform truncated upper bound exists either; the m-uniform structure of §5 is
irrecoverable in both directions.)

**Hunt result (lane task b).** Within natural m (all ordinary m ≤ 1500 + 60
random 12-digit), no m approaches 0 at fixed Q: the distribution is tight
(IQR ≈ [0.112, 0.130] at Q=10⁵). Approach to 0 happens (i) for every m as
Q → ∞ (Mertens decay, rate C(m)/ln Q with C(m) ∈ [1.14, 2.81] measured), and
(ii) adversarially in m via the primorial construction at any fixed truncation.

## 2. Verification of the claimed constants (lane task a)

- **(2520/8)×(5040/16):** 315 × 315 = **99225**; 99225 × 128 = 12,700,800 =
  2520 × 5040 exactly. Uncovered density = exactly **1/128**. VERIFIED
  (arithmetic only; the Chain103 structural claim itself is not re-proved here).
- **1/128 vs 1/256, who claims what:** §5/§7/L5 and the public page
  (`README.md`, `MANIFEST.md`) consistently say `c_pre = 1/256` (= 1/128
  uncovered density × 1/2 tail normalization) and `c₀ ≈ 6.6×10⁻⁴`. The main-tex
  **executive summary** instead says `c_pre = 1/128` and `c₀ ≈ 1.1×10⁻⁴`, and
  also floats "≈10⁻³ under joint sharpening". CORRECTED: the exec-summary pair is
  doubly inconsistent — its 1.1×10⁻⁴ equals (1/256)·e^{−2·1.78} = 1.1109×10⁻⁴,
  i.e. the Mertens correction applied **twice** (or C_Mertens = 1.78 used where
  0.89 is intended); with its own c_pre = 1/128 it would give 1.32×10⁻³, not
  1.1×10⁻⁴. No combination of in-paper constants yields 1.1×10⁻⁴ except the
  double-application slip.
- **c₀ arithmetic:** (1/256)·e^{−1.78} = **6.5874×10⁻⁴** ≈ 6.6×10⁻⁴. Arithmetic
  VERIFIED. But **C_Mertens ≈ 0.89 is UNDERIVED**: §5 gives no formula ("Mertens
  product head to P₀ ≤ 7"); tested candidates — Σ_{p≤7}1/p = 1.176,
  −Σ_{p≤7}log(1−1/p) = 1.476, −Σ_{5≤p≤7}log(1−1/p) = 0.377, Mertens M = 0.261 —
  none equals 0.89; the only numerical match is e^γ/2 = 0.8905, which has no
  stated connection. And 1/256 = 3.90625×10⁻³ matches the paper's "≈3.91×10⁻³".
- **Head/tail mis-attribution (new finding):** the §5 head bound assigns 1/128 to
  the Euler product over p ≤ P₀ = 7. The true worst-case head over p ∈ {5,7} is
  (1−5/16)(1−7/36) = **319/576 = 0.5538** — a factor 70.9 LARGER than 1/128. The
  1/128 is a (2520,5040)-cell-covering density over ALL eligible q (including
  q > 7, e.g. q = 13 with d2=12|2520, d3=3|5040); equating it with the p ≤ 7
  Euler head is a category error, conservative in direction (it understates the
  head) but symptomatic of the unproven "translation" the paper itself flags in
  L5. Irrelevant to the verdict anyway, since the tail diverges (§1 above).

## 3. §6–7 constants pipeline (lane task d)

- `c = c_Brun/(2 ln 6)·0.9`: 2 ln 6 = 3.58352; 0.999/3.58352 × 0.9 = **0.25090**
  ≥ 0.25 ✓. The §8 witness inequality `0.25 ≤ c_Brun/(2 log 6)·0.9` holds with
  **0.36% margin** — razor-thin, and conditional on (i) c_Brun = 0.999 from the
  unverified HR Thm 6.1 constants (L2) and (ii) the o(1) ≤ 0.1 assumption from
  the L4 folklore sieve, and (iii) κ_V = 0, which is BROKEN (Lane 0 E1: true
  κ = 1). At κ = 1 the entire §4/§6 architecture (Brun-suffices, F(s)→1) fails,
  so c ≈ 0.25 has no surviving derivation.
- Brun depth-10 loss `C^10/10! ≤ 10⁻³` requires C ≤ 2.2699; C is unstated.
  UNTESTABLE-TONIGHT (depends on HR Thm 6.1 verbatim constants).
- `eq:asymp-sieve` algebra `|T_D|·𝔖/log(m·6^D) ~ 𝔖·D/(2 ln 6)`: VERIFIED as
  algebra (for fixed m). eq:num-factors middle expression is mangled
  (denominator reads log D/D^{1/3}, should be (log D)/3) but the final bound is
  the correct ⌊3(D ln6 + ln m)/ln D⌋ — typo only (E7).
- `D₀ = max(e^200, 10^50) = e^200`: e^200 = 10^{86.8589} > 10^50 ✓, "≈10^87" ✓,
  and quoting D₀ = 10^87 ≥ e^200 in thm:main is directionally fine. The claimed
  "10^2433 improvement" over 10^2520 ✓ arithmetic. `z = D^{1/3} ≥ 100 ⟺ D ≥ 10⁶` ✓.
- **But both binding inputs are bare assertions:** D₁ = e^200 ("for A = 10 and
  𝔖 ≥ 10⁻³") has no in-paper derivation — under the paper's own remainder form
  `O(D^{5/4}/(log D)^A)` vs main term 𝔖·D², ANY D ≥ 13 suffices, so e^200 is
  unmotivated; under the most adverse misreading (remainder D^{5/4}·(log D)^A)
  one gets D₁ ≈ e^65, which e^200 covers with 3× exponent margin. D₂ = 10^50 is
  literally "by a rough estimate" — no formula. VERDICT: the §7 pipeline's
  max/compare arithmetic is VERIFIED; its two quantitative inputs are UNDERIVED.
- **Internal inconsistency:** the §7 BV bullet assumes 𝔖(m) ≥ 10⁻³ while §5's own
  c₀ = 6.6×10⁻⁴ < 10⁻³ — the pipeline assumes a stronger singular-series bound
  than the one it just derived (and per §1 above, the true bound is 0 anyway).

## 4. STRENGTHEN — kernel-grade artifacts (all finite, exact)

**K1 — Uniform truncated floor (the TRUE uniform statement at any fixed level).**
For EVERY ordinary m and the paper's local model g_V:
`𝔖_Q(m) ≥ W_Q := Π_{3<q≤Q} (1 − q/((q−1)·H_q))`,
since each factor of 𝔖_Q is either 1 (untriggered or q|m) or exactly the
corresponding W-factor. Exact value at Q = 1000 (166 primes):
**W_1000 = 0.14212082…**, exact 603-digit rational stored in the JSON
(`W_1000_exact_fraction`). Floats: W_{10⁴} = 0.0932820, W_{10⁵} = 0.0651181.
Lean-formalizable statement (no analysis, finite order computations +
per-factor case split):
```
theorem trunc_singular_floor (m : ℕ) (hm : Nat.gcd m 6 = 1) :
    SQ m 1000 ≥ (W1000num : ℚ) / W1000den
-- SQ m Q := ∏ q in primesIn (3,Q], localFactor q m
-- localFactor q m = 1 - q/((q-1)*H q) if triggered else 1
```
**K2 — Attainment.** m* = primorial(10⁵) − 1 triggers ALL 9590 primes in
(3,10⁵] and realizes 𝔖_Q(m*) = W_Q exactly for every Q ≤ 10⁵ (measured log-diff
2.7×10⁻¹⁵; exact because m* ≡ −1 mod q ⇒ −m*⁻¹ ≡ 1 ∈ ⟨2,3⟩). Kernel form: 166
(or 9590) divisibility facts `q ∣ primorial(Q)` + the trigger equivalence.
**K3 — Bounded-m exact minimum.** For all 500 ordinary m ≤ 1500:
`𝔖_1000(m) ≥ 𝔖_1000(389) = 0.1626243…` (exact 531-digit rational in JSON,
`exact_min_S_1000_over_m_le_1500`). native_decide-able (500 × 166 modular
membership tests via `t^{H_q} ≡ 1`).
**K4 — 2-Sylow arithmetic.** `315·315 = 99225 ∧ 99225·128 = 2520·5040`. Trivial
kernel fact backing the 1/128 density arithmetic (NOT the structural claim).

**Margins:** W_1000 (uniform, kernel-grade) = 0.1421 is 215× above the paper's
c₀; the survey min at Q=10⁵ is 149× above c₀; i.e. no finite truncation at
feasible Q contradicts c₀ — the failure is the divergence (rate lnln Q in the
log), provable unconditionally for the index-≥2 subfamily via q ≡ ±1 mod 24.
Index-1 fraction measured 6733/9590 = 0.7021 vs rank-2 Artin constant 0.6979
(+0.6% — consistent; index-1 primes are triggered for every m coprime to them,
which is what drives the universal decay).

## 5. Verdict line

- Prop 5.2 / eq:S-defn / both Lean axioms' uniform constant: **BROKEN** (𝔖 ≡ 0;
  tail bound self-contradictory; uniformity unrecoverable under any
  renormalization — primorial attack).
- (2520/8)×(5040/16) = 99225, density 1/128: **VERIFIED** (arithmetic).
- c_pre: §5/page say 1/256, exec says 1/128: **CORRECTED** (1/256 is the
  paper-internal consistent value; exec's 1.1×10⁻⁴ = double-Mertens slip).
- c₀ = (1/256)e^{−1.78} ≈ 6.6×10⁻⁴: arithmetic **VERIFIED**, C_Mertens = 0.89
  **UNDERIVED**, and the bound itself is FALSE in the limit.
- §6 c ≈ 0.25: arithmetic **VERIFIED** (0.36% margin), derivation **BROKEN**
  upstream (κ=0 false), inputs L2/L4 UNTESTABLE-TONIGHT.
- §7 D₀ = e^200 ≈ 10^87: comparison arithmetic **VERIFIED**; D₁ = e^200 and
  D₂ = 10^50 **UNDERIVED** (assertions); 𝔖 ≥ 10⁻³ vs c₀ = 6.6×10⁻⁴ internal
  inconsistency **CONFIRMED**.
