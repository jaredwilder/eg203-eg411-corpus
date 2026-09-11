# V-family Rosser-Iwaniec Preprint — 2026-06-03

**Author:** Jared Wilder
**Status:** Preprint, expert review pending
**Backs Lean axiom:** `wilder_2026_V_family_rosser_iwaniec` in
`EG203AtomicCitations.lean` (this package, `closure/`)
**Compiles standalone:** yes, with all four `.tex` files in this directory.

## What this paper proves

For ordinary integers $m$ (i.e. $\gcd(m, 6) = 1$) and the family

```
V(m, k, l) = m * 2^k * 3^l + 1,
```

there exist effective constants $c > 0$ and $D_0$ such that for every
ordinary $m$ and every $D \geq D_0$,

```
pi_V(m, D) := #{(k, l) : k + l <= D, V(m, k, l) prime} >= c * S(m) * D
```

where $S(m)$ is the Bateman-Horn singular series, uniformly bounded
below by $c_0 > 0$. Corollary: V captures primes infinitely often for
every ordinary m. This affirms Erdős-Graham Problem 203 (1980).

**Effective constants:** $c \approx 0.25$, $D_0 \approx 10^{87}$.

**Gap to empirical:** for $m \leq 10^{10}$ (sweep complete to
$3{,}333{,}333{,}333$ ordinary values, zero failures), maximum
first-prime diagonal $D = 26$ attained at
$m = 6{,}257{,}518{,}159$ — far below the rigorous $D_0$.

## Files

The preprint is assembled from referee-style critique passes. Each pass
exposes the prior draft to a written referee-style critique and
incorporates a repair. The split files preserve the audit trail.

| File | Content |
|------|---------|
| `01-intro-and-kappa.tex` | §1 Intro, §2 sieve dimension $\kappa_V = 0$ |
| `03-BV-and-Iwaniec.tex` | §3 BV-style level $Q = D^{1/2-\varepsilon}$, §4 Brun pure sieve at $\kappa = 0$ |
| `05-almost-prime-and-constants.tex` | §5 $S(m) \geq c_0$, §6 almost-prime, §7 explicit constants |
| `wilder-2026-V-family-rosser-iwaniec.tex` | Final assembly: \input{} of 01, 03, 05 + §8 Lean integration + §9 empirical + §10 LIMITATIONS + bibliography |

## How to compile

```bash
cd paper/

# Requires pdflatex (e.g., MiKTeX or TeX Live)
pdflatex wilder-2026-V-family-rosser-iwaniec.tex
pdflatex wilder-2026-V-family-rosser-iwaniec.tex # rerun for cleveref/TOC
```

The `.tex` is syntactically standard; any LaTeX distribution should
handle it. The `\input{}` directives in the final file pull in
`01-intro-and-kappa.tex`, `03-BV-and-Iwaniec.tex`, and
`05-almost-prime-and-constants.tex`.

## Lean integration

The paper backs ONE Lean axiom in the Erdős-Graham #203 kernel-verified
closure (`EG203AtomicCitations.lean`):

```lean
axiom wilder_2026_V_family_rosser_iwaniec :
 ∃ (c : ℝ) (D₀ : ℕ), 0 < c ∧
 ∀ m : ℕ, Ordinary m → ∀ D : ℕ, D₀ ≤ D →
 c * bateman_horn_singular_series_V m * (D : ℝ)
 ≤ (primeCountInBox m D : ℝ)
```

The witness `(c = 0.25, D₀ = 10^87)` from §7 of the paper provides the
explicit existential witness.

## Status of literature citations (three-tier tagging)

Per §10.L7 of the paper:

- **[VERIFIED]** — paper read, theorem statement matches:
 Bombieri 1965, Friedlander-Iwaniec 1998, Maynard 2019,
 Mauduit-Rivat 2010, Erdős-Graham 1980, Erdős-Pomerance 1985,
 Rosser-Schoenfeld 1962.

- **[EXISTS-LOCATION]** — paper exists, theorem location known but
 verbatim statement not checked:
 Heath-Brown 1986, Iwaniec 1980, Halberstam-Richert 1974,
 Iwaniec-Kowalski 2004, Pappalardi 1995, Pappalardi 2003,
 Pappalardi-Susa 2010, Drmota-Tichy 1997, Greaves 2001,
 Bourgain-Glibichuk-Konyagin 2006, Heath-Brown-Konyagin 2000,
 Hooley 1972, Brun 1915.

- **[NEW]** — original to this project:
 Wilder 2026a (Sylow / CRT density argument),
 Wilder 2026b (Lean 4 closure),
 Wilder 2026c (research notes / 100+ verification chains).

## Known weaknesses (carried from audit + referee-style critique passes)

Numbered as in §10 of the paper:

- **L1:** Pappalardi 2003 quantitative form not verbatim-verified. The
 $\kappa_V = 0$ proof depends on this in the explicit-rate form;
 unconditional qualitative form is via Heath-Brown 1986.
- **L2:** $F(s)$ at $\kappa = 0$ in Iwaniec 1980 not verbatim-verified.
 Mitigated by pivoting to the Brun pure sieve at depth $r = 10$,
 which uses only Halberstam-Richert §6 Theorem 6.1. This is the
 load-bearing path: it avoids the unverified Iwaniec $F(s)$ analysis
 entirely.
- **L3:** Iwaniec-Kowalski Theorem 11.7 large-sieve application not
 verbatim-verified.
- **L4:** Iwaniec-Kowalski Chapter 22 asymptotic sieve at $\kappa = 0$
 not verbatim-verified.
- **L5:** The 2-Sylow structural argument backing the singular-series
 constant is original to this project, kernel-verified in Lean
 (`Chain103UniversalDensity.lean`), and Python-cross-checked across
 3 independent period extensions; the translation to a singular-series
 lower bound is standard but not formally Lean-checked.
- **L6:** $D_0 = 10^{87}$ vs empirical $D = 26$ (sweep to $10^{10}$)
 gap not closed.
- **L7:** All [EXISTS-LOCATION] citations need verbatim verification.
- **L8:** Empirical-rigorous gap unaddressed.
- **L9:** Drafting process: multi-pass referee-style critique split
 files, no external collaboration.

## Publication readiness assessment

**Current state:** preprint-quality draft, suitable for arXiv submission
ONLY after the L7 verbatim verification pass.

**To reach publishable peer-reviewed quality:**
1. Verbatim verify all [EXISTS-LOCATION] citations (L7).
2. Have an analytic NT expert audit §3 (BV-style construction is
 novel; L3 is the riskiest claim).
3. Address L1 (Pappalardi quantitative rate) one way or another:
 either verify Pappalardi 2003 gives the cited exponent, or rewrite §2
 using only the qualitative form via Heath-Brown 1986.
4. Address L4 (asymptotic sieve at $\kappa = 0$) by reading
 Iwaniec-Kowalski Ch.22 verbatim.
5. Either close the L6 gap or accept the rigorous-empirical disparity.

**Estimated effort to publishable:** 2–4 weeks of analytic-NT-expert
time for verbatim verification + ~1 week of author time for any
rewriting if a verification fails.

## Reproducibility

All sources for this paper are in this directory. No external data
or computation is needed to verify the math (everything is symbolic).
The empirical evidence in §9 references SHA-pinned receipts; the
Lean files referenced are in `../bounded/`, `../chain-103/`,
`../scale-ladder/`, `../source-pinned-540/`.

## Drafting disclosure

This preprint was drafted by Jared Wilder. The drafting proceeded in
multi-pass referee-style critique passes; each pass exposes the prior
draft to a written referee-style critique and incorporates a repair.
The split files in this directory preserve that audit trail. All
literature citations are tagged with verification status per §10.L7
of the paper. The author is responsible for the mathematical content
and is the sole point of contact for errata and disputes.

---

## CORRECTION NOTICE (2026-06-10)

The main-theorem chain of this preprint was **withdrawn 2026-06-10** after a five-lane adversarial verification (receipts in `../verification/`). The `.tex` source carries the full correction notice in the abstract and is the document of record. The bundled PDF (`*-SUPERSEDED-2026-06-03.pdf`) predates the correction and is retained for audit continuity only — its main theorem, kappa_V = 0 claim, and singular-series bound are falsified. Key corrected results: true local law g_V = 1/H_q; true sieve dimension kappa_V = 1; unconditional prime-moduli level-of-distribution O(D^(5/4)); Bateman-Horn prediction matching exact counts to +/-12%.
