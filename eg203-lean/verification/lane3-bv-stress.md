# LANE 3 — Prop 3.1 BV-level stress test (receipt)

**Date:** 2026-06-10 · **Target:** `paper/03-BV-and-Iwaniec.tex` §3 (`prop:BV`, `lem:per-q`,
the Erdős–Turán–Koksma "sharper per-q bound", `rem:1-over-H-sum`) and the §4-required
squarefree extension (limitation **L3**).
**Generators:** `lane3_bv_stress.py` (panels A–D), `lane3_etk_family.py` (panels E, E2).
**Data:** `lane3-bv-stress.json`, `lane3-etk-family.json`.
**Arithmetic:** exact integers / `Fraction` throughout (lattice counting via exact
floor-sum; floats only in report columns).

**Definitions used** (recomputed from scratch, not trusted from the paper):
V(m,k,l) = m·2^k·3^l + 1; T_D = {k,l ≥ 0, k+l ≤ D}, |T_D| = (D+1)(D+2)/2;
d2 = ord_q(2), d3 = ord_q(3); H_q = |⟨2,3⟩ mod q| (computed as actual subgroup size);
e_q = ord_q(2·3⁻¹) (the "diagonal order", relevant to the hypotenuse direction of T_D);
λ1(q) = shortest vector (L2) of the kernel lattice Λ_q = {(a,b) ∈ Z² : 2^a·3^b ≡ 1 mod q}.

**Internal validations, all PASS:** 600 random floor-sum/lattice-count checks vs naive;
46 + 4 + 2 brute-force O(D²) recounts of full rows (incl. D=3000 at q∈{7,53,1009} and
D=1500 family primes); 508 per-row verifications that the per-period solution count is
exactly d2·d3/H (the kernel claim inside `lem:per-q`'s proof — that part is TRUE);
70 subgroup-closure verifications H = lcm(d2,d3); 182 lattice-index checks d2·b\* = H;
6 brute-force joint (composite-modulus) recounts.

**Ground truth re-established (matches Lane 0):** when q is triggered the density of
{q | V} cells is exactly **1/H_q** per cell (d2·d3/H solutions per d2×d3 period).
Not 1/H², not (1/H)/q.

---

## 1. VERDICT TABLE

| Claim | Verdict | Evidence |
|---|---|---|
| `eq:E-defn` main term (g_V/q)·\|T_D\| with §1's density g_V | **BROKEN** (normalization; = Lane 0's E3) | "error" = 0.20·\|T_D\| at q=5: first-order, grows like c·D², ratio to BV RHS grows monotonically (§2.1) |
| `lem:per-q` claimed density 1/h² ("Hence the density … is 0 or 1/h²") | **BROKEN** (= Lane 0's E4) | own proof derives d2·d3/h per period; correct division gives 1/h. 508 exact instances |
| `lem:per-q` inequality `eq:per-q` as stated (with either paper main term) | **BROKEN numerically** | violated ×20.0 (eq:E-defn version) and ×18.8 (own 1/h² version) at m=1000003, D=800, q=5 (§2.2) |
| `lem:per-q` inequality with CORRECTED main term \|T_D\|/H | VERIFIED (slack ×30) | max \|E\|/(D·h) = 0.0325 over all 508+625 rows — but the bound is never the binding input |
| ETK refinement \|E\| = O(D·log h/h) | **BROKEN as a shape, inside BV range** | in-range ratio reaches **1404** along q \| 3^e−2^e family at D ∈ [q⁴,3q⁴]; already >1 inside the mandated grid (q=13, D=400, ratio 1.017) (§3) |
| `rem:1-over-H-sum` corollary "Σ 1/h = O((log z)^{1/2})" as used in final summation | UNTESTABLE-TONIGHT as asymptotics; numerically harmless | Σ 1/H_q over triggered q ≤ 3162 is ~0.9–1.0 (small); the slip Lane 0 found (loglog vs (log)^{1/2} attribution) does not change my panel outcomes |
| **Prop 3.1 CONCLUSION, corrected main term, prime moduli** | **VERIFIED with huge margin + elementary proof route** | Σ\|E\| ≤ 1.8·D observed up to D=10⁷ vs claimed D²/(log D)^A: margin ×1357 (A=3, D=10⁷); unconditional elementary O(D^{5/4}) proof sketch in §5 |
| Squarefree extension (L3): g_V multiplicative on d = q1·q2, needed by §4's R(A,Q) | **BROKEN** (not just unproven) | exact joint densities are 0×, 2×, or 3× the product g(q1)g(q2) depending on m; 33/87 pairs deviate; \|E_BH\|/D up to 4.2 (§4) |

Net for the lane: **MIXED — the proposition's conclusion survives (after correcting the
main term, for PRIME moduli) by a huge margin and by an elementary argument; but every
quantitative tool §3 actually offers (E-definition, per-q density, ETK bound) is broken
as stated, and the composite-modulus extension that §4 consumes is false, not open.**

---

## 2. The paper's literal statements vs exact computation

### 2.1 Main-term normalizations are first-order wrong (E3/E4 quantified)

Exact row (m=1000003, D=800, q=5): d2=d3=H=4, count = 80200, |T_D| = 321201.

| main term | value | "error" E | vs corrected E |
|---|---|---|---|
| corrected |T_D|/H | 80300.25 | **−401/4 = −100.25** | — |
| `eq:E-defn`: (g/q)·\|T_D\| = \|T_D\|/(H·q) | 16060.05 | +64139.95 | ×640 larger |
| `lem:per-q`: \|T_D\|/h² | 20075.06 | +60124.94 | ×600 larger |

Summed over the BV range, the literal-paper "errors" are the main term itself:
for m=5, Σ_q |E_qslip| / (D²/log D) = 0.30, 0.34, 0.84, 1.27, **1.71** at
D = 50, 100, 200, 400, 800 (monotone growth ⇒ no constant C(ε, A=1) can ever absorb it;
same for the 1/h² version: 0.29 → 1.67). **Prop 3.1 is numerically FALSE as literally
stated** under either reading of its own E-definition.

### 2.2 Lemma 3.2's inequality is violated by its own numbers

`eq:per-q` bounds |E| by min(|T_D|/h², 1) + O(D·h). Taking the implied constant = 1,
the worst grid violations (using the paper's own main terms inside E):

- m=1000003, D=800, q=5: |E_paper| = 64140 (eq:E-defn) vs bound 3201 → **ratio 20.0**
- m=1000003, D=800, q=5: |E_paper| = 60125 (own 1/h²) vs bound 3201 → **ratio 18.8**
- m∈{5,55,115}, D=800, q=7: ratio 9.3

With the corrected main term |T_D|/H the same inequality holds everywhere with max ratio
0.0325 — i.e. the lemma is true only after the density slip is fixed, and then its O(D·h)
term is ~30× slack and never the binding input to the summation.

---

## 3. The ETK "sharper per-q bound" is refuted INSIDE the BV range

Paper claim ("Sharper per-q bound via Erdős–Turán", used for the final summation):
|E_V(D,q,0)| ≤ O(D·log h_q / h_q).

**Structure of the counterexample.** T_D is sliced by diagonals k+l = j; on a diagonal
the congruence reduces to (2/3)^k ≡ const, with period e_q = ord_q(2·3⁻¹). If
q | 3^e − 2^e then (e,−e) ∈ Λ_q is parallel to the hypotenuse, e_q | e is small, and the
discrepancy is governed by the diagonal ramp: measured |E| ≈ (0.34–0.50)·D/e_q
(max constant over all panels: |E|·e_q/D = 0.89), while H_q can be q−1 (full). The ETK
bound D·ln H/H is then too small by a factor ≈ H/(2·e_q·ln H) → ∞.

**In-range test:** every sample uses D ∈ [q⁴, 3q⁴], i.e. q ≤ D^{1/4} ≤ D^{1/2−ε} for every
ε ≤ 1/4 — these primes are inside the level at which Prop 3.1's proof invokes the bound.
28 offset-randomized D per q (D = q⁴ exactly is degenerate: D ≡ 1 mod (q−1) aligns T_D
with the period lattice and |E| collapses ~3.5 orders of magnitude — itself a verified
observation, see `lane3_etk_family.py` header note).

| q | family | H_q | e_q | max ratio \|E\|/(D ln H/H) | median |
|---|---|---|---|---|---|
| 211 | 3⁵−2⁵ | 210 | 5 | 3.8 | 2.2 |
| 3571 | 3¹⁵−2¹⁵ | 3570 | 15 | 14.0 | 7.0 |
| 29927 | 3¹³−2¹³ | 14963 | 13 | 59.8 | 37.6 |
| 35839 | 3²²−2²² | 35838 | 22 | 76.2 | 20.6 |
| 369181 | 3²⁸−2²⁸ | 369180 | 28 | 347.7 | 201.9 |
| 555029 | 3³⁸−2³⁸ | 555028 | 38 | 484.1 | 458.1 |
| **745181** | **3¹⁹−2¹⁹** | **745180** | **19** | **1404.0** | **740.5** |

Monotone growth tracking H/(e_q·ln H) ⇒ **no absolute implied constant exists**; the
claim fails as a uniform statement exactly where Prop 3.1 uses it. (Already inside the
mandated grid: q=13 (H=12, d3=3, λ1=3), D=400, m∈{95,115,1000003}: |E| = 337/4 = 84.25 >
82.83 = D·ln(12)/12, ratio 1.017.) Since primitive prime divisors of 3^e−2^e exist for
every e (Zsygmondy/Birkhoff–Vandiver), the family is infinite.

**Why Prop 3.1 still survives:** the violating primes obey the corrected bound
|E| ≤ C₀·D/e_q (C₀ ≤ 0.9 observed), and Σ_q D/e_q is controlled (§5).

---

## 4. Squarefree moduli (the L3 extension §4 consumes): multiplicativity is FALSE

§4's remainder R(A,Q) = Σ_{d|P(z)} |E_V(D,d,0)| needs densities at squarefree composite
d with g_V(d) = Π g_V(q_i) (the standard sieve axiom; also implicit in W(z) = Π(1−g(p))).
Exact joint computation at D=800 for all triggered pairs (q1,q2), q ≤ 28, all 10 m:

- **87 pairs total: 54 exactly multiplicative; 22 with joint density 2× or 3× the product; 11 with joint density 0 (both primes triggered, joint system EMPTY).**
- Mechanism: joint solutions live on Λ_{q1} ∩ Λ_{q2}; with r := [Z² : Λ_{q1}+Λ_{q2}] > 1
  the affine cosets either miss (density 0) or pile up (density r/(H1·H2)). Which case
  occurs depends on m. Examples (D=800, |T_D| = 321201):
  - m=55, d=13·19=247: true density 3/(216) → count 4444, E_true = −17.1, **E_BH = +2957**
  - m=5, d=11·13=143: ratio 2 → count 5346, E_true = −7.3, **E_BH = +2669**
  - m=5, d=7·17=119: both triggered, count = **0** (empty), **E_BH = −3346** (|E_BH|/D = 4.2)
  - inconsistent list (all 11): (m;q1,q2) = (5;7,17), (5;13,19), (25;7,17), (25;11,13),
    (25;13,19), (35;13,19), (85;11,13), (115;13,19), (1000003;5,19), (1000003;11,13),
    (1000003;13,19).

So the squarefree-level statement the paper delegates to IK Thm 11.7 is not merely
unverified (L3): **with g(d) := Πg(p) it is false** — per-d errors are first-order
(≈ (r−1)·|T_D|/(H1H2), or |T_D|/(H1H2) in the empty case) and these are *small* H's, the
common case for small primes. Any repaired §4 must use the true joint densities
g_V(d) = [consistency]·r/(H1H2) (equivalently the index of Λ_∩ and a coset condition) —
this changes the Brun main term W(z) itself, not just the remainder. (Average over m of
the true density equals the product — Bateman–Horn on average survives — but the sieve
needs it pointwise in m, and the theorem claims uniformity in m.)

---

## 5. What IS true (corrected statements + margins)

**Corrected per-q lemma (replaces lem:per-q + the ETK paragraph).** For prime q ∤ 6m
triggered, with corrected main term:
|E_V^corr(D,q)| := |#{(k,l) ∈ T_D : q|V} − |T_D|/H_q| ≤ C₀ · D/e_q  (≤ C₀·D since e_q ≥ 2)
Observed: C₀ = 0.893 suffices across all 1,874 exact evaluations in panels A/B/C/E
(11 ≤ q ≤ 1.2·10⁶, 50 ≤ D ≤ 3·10²³, adversarially chosen families included; the
all-panel max of |E|/D alone is 0.211, at q=13). Elementary proof route (diagonal
slicing): each diagonal k+l=j contributes a count of an AP in [0,j] with modulus e_q
(error ≤ 1 per active diagonal) and the active-diagonal pattern is periodic; needs a
careful write-up but no exponential sums, no ETK, no Pappalardi.

**Corrected Prop 3.1 (prime moduli).** For every ε > 0, A > 0:
Σ_{q ≤ D^{1/2−ε}, q prime, q∤6m} |E_V^corr(D,q)| = O(D^{5/4}) ≪ D²/(log D)^A.
Elementary route, unconditional: #{q : e_q = e} ≤ ω(3^e−2^e) ≤ e·log₂3, so
Σ_{q≤Q} 1/e_q ≤ 2√(log₂3 · π(Q)) = O(D^{1/4}/√(log D)); multiply by C₀·D.
No κ_V input, no ETK, no Pappalardi–Susa, no IK 11.7 needed at prime level.
**This rescues the BV-level conclusion for prime moduli even though every quantitative
step in the §3 proof is broken** — but note it does NOT rescue §4, which needs composite
d (§4 above) and correct main terms downstream.

**Measured margins (corrected E, prime moduli):**

| D | m | Σ\|E\| (exact) | D²/(ln D)³ | ratio | Σ\|E\|/D |
|---|---|---|---|---|---|
| 800 | 5 | 188.003 | 2.14×10⁵ | 0.088 | 0.235 |
| 800 | 1000003 | 444.663 | 2.14×10⁵ | 0.208 | 0.556 |
| 10000 | 5 | 5771.9 | 1.28×10⁵·10³ | 0.045 | 0.577 |
| 10⁷ | 5 | 1.4273×10⁷ | 2.388×10¹⁰ | **0.000598** | 1.427 |
| 10⁷ | 1000003 | 1.7597×10⁷ | 2.388×10¹⁰ | **0.000737** | 1.760 |

Worst ratio vs D²/(ln D)³ anywhere: 0.290 (D=50) and it *decreases* in D — margin at
D=10⁷ is ×1357 (m=1000003) to ×1673 (m=5), growing like (log D)^A·D^{~3/4}. Pooled
log-log slope of Σ|E| vs D: 1.39 (per-m 1.35–1.60; m=5005 flat because no prime q ≤ 14
is coprime to it); observed Σ|E| ≤ 0.36·D^{1.1} on the mandated grid and ≤ 1.8·D at 10⁷.
Number of triggered primes at D=10⁷: 368 (m=5), 373 (m=1000003) of 444 primes ≤ 3162.

---

## 6. Precisely what is empirically validated vs analytically open

- VALIDATED (empirically, huge margin): corrected-main-term Prop 3.1 conclusion for
  **prime** moduli, m ∈ grid, D ≤ 10⁷; plus an elementary unconditional proof route (§5).
- BROKEN (exact computation): eq:E-defn normalization; lem:per-q density 1/h²;
  lem:per-q's stated inequality; the ETK per-q shape (in-range, unboundedly);
  multiplicativity of g_V over squarefree d (the L3 target — false, not open).
- ANALYTICALLY OPEN (not breakable numerically tonight): the formal write-up of the
  corrected per-q diagonal bound |E| ≤ C₀·D/e_q; the repaired composite-modulus theory
  (true joint densities → reworked W(z) and R(A,Q) in §4); uniformity in m beyond the
  10 sampled m (no m-dependence of any conclusion was observed; all bounds m-uniform
  across panels).

## 7. Lean-formalizable finite statements (statement only)

1. (Counting instance) `#{p : ℕ × ℕ | p.1 + p.2 ≤ 800 ∧ 5 ∣ (1000003 * 2^p.1 * 3^p.2 + 1)} = 80200` — and the 507 sibling instances tabulated in `lane3-bv-stress.json` (decidable; native_decide-scale: 321,201 cells).
2. (Kernel/period count) `#{a ∈ Finset.range 12 ×ˢ Finset.range 3 | 2^a.1 * 3^a.2 ≡ 9 [MOD 13]} = 3` (9 = −95⁻¹ mod 13), = d2·d3/H — the corrected density numerator; 508 instances verified.
3. (ETK violation witness, exact rationals) with count(95,400,13) = 6801: `|6801 - 80601/12| = 337/4 > 400 * (5/2) / 12` together with `Real.exp (5/2) > 12` (so 5/2 > ln 12); kernel-checkable refutation instance of the ETK inequality at implied constant 1.
4. (Non-multiplicativity witness) `#{p : ℕ × ℕ | p.1 + p.2 ≤ 800 ∧ 119 ∣ (5 * 2^p.1 * 3^p.2 + 1)} = 0` while `#{… 7 ∣ …} = 53600` and `#{… 17 ∣ …} = 20050` (joint EMPTY despite both factors triggered; predicted-by-multiplicativity joint count ≈ 321201/96 ≈ 3346).

— end of receipt —
