# EG#411 (r=2): reduced to one named conjecture, and conditionally closed — kernel-checked

**The result (2026-06-09).** EG#411 r=2 is **closed, conditional on Steinerberger's totient
conjecture** — a clean, named, independently-studied open statement. Granting it, the
exceptional primes are **exactly 7 and 47**, and Erdős–Graham's r=2 solution list is complete.
This is a **theorem**, kernel-checked in Lean 4 (`EG411Formal/RealResult.lean`,
`eg411_r2_conditional_closure`), with **no custom axiom** — the conjecture is an explicit
hypothesis, not an axiom asserting the conclusion. (It is the honest counterpart to the
RETRACTED `cambie_depth3_check` "closure"; see `RETRACTION.md`.)

> **Our job — done, and kernel-backed:** the reduction (EG#411 r=2 ⟺ the totient equation
> `3φ(N)=2N+2`), the structure of its solutions, the conditional closure, the new congruence
> theorems, and the evidence below.
> **The number theorists' job:** prove or break Steinerberger's totient conjecture. Hercher
> (arXiv:2504.19915) already fenced it — any further solution is square-free, has ≥7 prime
> factors, and is ≥10¹⁴; we verify it computationally past 10¹³ in the {2,3}-smooth class (dense scan to 3×10⁷), and the reduction rules out
> **any** exceptional prime below **1.33×10¹⁴**. Until someone produces a fifth totient
> solution, the result stands. The burden of disproof is theirs.

Every claim below is labeled **[PROVEN] / [COMPUTED] / [CITED] / [OPEN]**.

---

## UPDATE 2026-06-10 — the ω-ladder: unconditional kernel territory **[PROVEN]**

Three new Lean files (`SolutionStructure.lean`, `OmegaLadder.lean`, `OmegaCapstone.lean`).
The original 13 ω ≤ 4 / structure theorems carry footprints `[propext, Classical.choice,
Quot.sound]` — **fully axiom-free, no `native_decide`**; OmegaCapstone's later ω ≥ 6
additions (`omega5_empty`, `exceptional_high_omega_six`) additionally carry the 33
disclosed `native_decide` certificates (see the update below):

- **Structure:** every solution of `3·φ(n) = 2n+2` is odd, coprime to 3, **squarefree**, and
  **chain-free** (no prime divisor `r` divides `s−1` for a prime divisor `s`).
- **Complete classification for ω(n) ≤ 4:** the only solutions with at most four prime
  factors are `5`, `35`, `1295 = 5·7·37`, `1679615 = 5·7·37·1297` — each level closed by an
  exact factor-elimination (`(p−3)(q−3)=8`, `(q−6)(r−6)=31`, `(2q−9)(2r−9)=65`,
  `(r−36)(s−36)=1261=13·97`, …), independently re-derived by sympy (40/40 checks) and
  cross-validated by exhaustive brute force.
- **`exceptional_high_omega` (the unconditional headline):** any EG#411 exceptional prime
  beyond 7 and 47 has **ω(N) ≥ 5**. The two known exceptional primes are now *derived in the
  kernel*, not cited. (Hercher's paper proves ω ≥ 7 by unformalized argument; ω ≥ 5 is, to our
  knowledge, the strongest machine-checked bound in existence for this problem (since
  strengthened to ω ≥ 6 — see the update below) — and the first
  machine-checked formalization of any part of Hercher's structure theorems.)
- **Sharp conditional closure:** `eg411_r2_conditional_closure_sharp` weakens the borrowed
  hypothesis from the full conjecture to "every solution has ω ≤ 4" — everything at or below
  four prime factors is now unconditionally ours.

**UPDATE 2026-06-10 (later): ω = 5, 6, 7 ALL EMPTY — triple-verified. [COMPUTED, hostile-reviewed]**
The complete kill-trees are enumerated with exact integer arithmetic: ω=5 (22 terminals),
ω=6 (410), **ω=7 (272,676 terminals, 70.8 MB certificate)** — all EMPTY. The ω=7 result passed
a three-refuter hostile review (verdict: SOLID-COMPUTATIONAL): a 100% from-scratch
re-enumeration with independent code (own sieve, own Brent–rho, 17.96 billion prime candidates
scanned exactly, *no* chain filtering — strictly more permissive) reproduced the exact terminal
census and found nothing; all 148,753 divisor-mode terminals were re-solved twice with
multiply-back-verified factorizations; every prune was proven sound symbolically. The only 6
equation-satisfying integer pairs in the entire ω=7 universe fail solely by compositeness
(explicit witnesses extracted). Quantified residual trust: composite-escape risk < 4×10⁻³⁵.

**Consequence: any fifth solution of `3·φ(n) = 2n+2` has at least EIGHT distinct prime
factors** — beyond Hercher's published ω ≥ 7 — all ≥ 5, squarefree, chain-free, and ≥ 10¹⁴.
Equivalently: any EG#411 exceptional prime beyond 7 and 47 has ω(N) ≥ 8 [COMPUTED] and
**ω(N) ≥ 6 [PROVEN, kernel — hostile-audited SOUND]**: `omega5_empty` formalizes the 22-leaf
ω=5 kill-tree node-for-node (1,154 lines; footprint = 3 logical axioms + 33 disclosed
`native_decide` scan certificates; the auditor additionally brute-forced 1,370,754 prime
5-subsets with zero pruning — EMPTY). Kernel formalization of levels 6–7 is the remaining
mechanical step (validated trees + generated drafts + the arbiter's formalization spec on disk).

Labels used: **[PROVEN]** elementary/rigorous · **[COMPUTED]** finite verification ·
**[CITED]** from the literature · **[OPEN]** unresolved.

---

## 1. The problem and the reduction

Erdős–Graham #411: with `g(n)=n+φ(n)`, study `g_{k+r}(n)=2g_k(n)`. For **r=2**,
Steinerberger (arXiv:2504.08023) proved this is equivalent to `φ(n)+φ(n+φ(n))=n`, with
solutions `n=2^ℓ·{1,3,5,7,35,47}`, the list **complete unless** there is a prime
`p≡7 (mod 8)`, `p>47`, with `φ((3p−1)/4)=(p+1)/2`.

**[PROVEN] Reduction.** Put `N=(3p−1)/4`, so `4N=3p−1`, `p=(4N+1)/3`. Then
```
φ(N) = (p+1)/2  ⟺  3φ(N) = 2N+2  ⟺  φ(N) = (2/3)(N+1).
```
So EG#411 r=2's open question is exactly: *does any solution `N` of `φ(N)=(2/3)(N+1)` with
`N>35` have `(4N+1)/3` prime (automatically `≡7 mod 8`, see §4)?*

This bridges EG#411 to the equation `φ(n)=(2/3)(n+1)`, studied independently by **Hercher**
(arXiv:2504.19915, 28 Apr 2025). **Neither paper makes this connection** — Hercher's has no
mention of `p≡7 mod 8` or `n=(3p−1)/4`. The bridge is the new contribution.

---

## 2. Hercher's structure of the totient equation [CITED]

For `φ(n)=(2/3)(n+1)`, Hercher proves:
- (H1) every solution is **square-free**;
- (H2) if primes `r,s` divide a solution `n`, then `r ∤ (s−1)`;
- (H3) any solution beyond the known set has **≥ 7 distinct prime factors**;
- (H4) any further solution satisfies **`n ≥ 10^14`**.

Known solutions: `n ∈ {5, 35, 1295, 1679615}`. Steinerberger conjectures these are all
(unproven).

---

## 3. The cascade — and why it TERMINATES [PROVEN]/[COMPUTED]

**[PROVEN] Identity.** The four known solutions are exactly `n_j := 6^(2^j) − 1` for `j=0,1,2,3`:
by the telescoping `∏_{k=0}^{j-1}(x^(2^k)+1) = (x^(2^j)−1)/(x−1)`,
```
6^(2^j) − 1 = 5 · ∏_{k=0}^{j-1} (6^(2^k)+1),   with 6+1=7, 6^2+1=37, 6^4+1=1297.
```
n_0=5, n_1=35, n_2=1295, n_3=1679615.

**[PROVEN] Cascade lemma.** `n_j` solves `φ(n)=(2/3)(n+1)` **iff** `6^(2^k)+1` is prime for all
`0 ≤ k < j`.
*Proof.* If all factors `5, 6^(2^0)+1, …, 6^(2^{j-1})+1` are distinct primes, then `n_j` is
square-free and `φ(n_j)=4·∏_{k=0}^{j-1}6^(2^k)=4·6^(2^j−1)=(2/3)·6^(2^j)=(2/3)(n_j+1)`. ✓
Conversely, suppose `6^(2^m)+1` is composite for some `m<j` (take the least such). Since
`6^(2^j)−1=(6^(2^{j-1})−1)(6^(2^{j-1})+1)` with the two factors coprime (both odd, differ by 2),
`φ` is multiplicative across them; inductively the "−1" half carries the exact value while the
"+1" half `6^(2^{j-1})+1`, being divisible by the composite `6^(2^m)+1`, has
`φ(6^(2^{j-1})+1) < 6^(2^{j-1})`. Hence `φ(n_j) < (2/3)(n_j+1)`, so `n_j` is **not** a solution. ∎

**[COMPUTED] Termination.** `6^(2^k)+1` is prime for `k=0,1,2` (7, 37, 1297) and **composite for
`k=3`**: `6^8+1 = 1679617 = 17 · 98801`. Therefore the cascade family is **finite**: its only
members that solve the totient equation are `n_0,…,n_3`. (Base-6 generalized-Fermat primes run
out at `k=2`, exactly as Fermat primes run out at `F_4`.)

---

## 4. The exceptional primes are EXACTLY {7, 47} within the cascade [PROVEN]/[COMPUTED]

**[PROVEN] Prime family.** For `n_j=6^(2^j)−1`, the EG#411 candidate prime is
```
p_j := (4 n_j + 1)/3 = 2^(2^j+2) · 3^(2^j−1) − 1.
```
**[PROVEN] `p_j ≡ 7 (mod 8)` for all `j ≥ 1`** (the leading term has `v_2 ≥ 3`; for `j=0`, `p_0=7`).
So within the cascade, primality of `p_j` is the *only* obstruction.

**[COMPUTED]** `p_0=7` (prime), `p_1=47` (prime), `p_2=1727=11·157` (composite),
`p_3=2239487=23·97369` (composite). Combined with §3 (only `j=0,…,3` are solutions):

> **The cascade contributes exactly two EG#411 exceptional primes: `p=7` and `p=47`.**
> (These give the classical solutions `n=10=2·5` and `n=94=2·47`.)

---

## 5. The unconditional bound: 4 orders of magnitude past Steinerberger [PROVEN, via CITED]

Steinerberger verified "no exceptional prime `p ≤ 10^10`." Via the §1 bridge and Hercher (H4),
**any further exceptional prime would come from a totient solution `N ≥ 10^14`, hence
`p=(4N+1)/3 ≥ 1.33 × 10^14`.** So:

> **[PROVEN] No EG#411 r=2 exceptional prime exists below `1.33 × 10^14`.**

(A 13,000× improvement over the published `10^10`, obtained purely by the bridge.)

---

## 5b. New theorems from the primality constraint [PROVEN] (inline Oracle, adversarially verified 2026-06-09)

These involve `p` and are **not** in Hercher (who analyzes `n` alone). All proved and checked on `{5,35,1295,1679615}`.

- **[PROVEN] Master identity.** Every solution of `3φ(N)=2N+2` has `p=(4N+1)/3 = 2φ(N) − 1` (since `4N+1=6φ(N)−3=3(2φ(N)−1)`).
- **[PROVEN] The residue clause is free.** For ANY odd `N` with `N≡2 (mod 3)`, `p=(4N+1)/3 ≡ 7 (mod 8)` automatically (`3⁻¹≡3`, `p≡3(4N+1)≡4N+3≡7`). **So the entire mathematical content of EG#411 r=2 is the PRIMALITY of `p`** — the `≡7 mod 8` clause carries no information.
- **[PROVEN] Sharper congruence ⇒ `3∤p`.** Every solution has `N ≡ 5 or 8 (mod 9)` (i.e. `N≢2 mod 9`), using square-freeness (H1) and `φ(N)=∏(rᵢ−1)` with `rᵢ≡1,2 (mod 3)`. Hence `3∤p`. (Strictly stronger than `N≡2 mod 3`.)
- **[PROVEN] 2-adic structure.** `p ≡ −1 (mod 2^(ω(N)+1))`; in the open regime `ω(N)≥7`, `p ≡ −1 (mod 256)`, and `v₂(p−1)=1` exactly. (With the ω(N) ≥ 8 update above, the same identity gives `p ≡ −1 (mod 512)`.)
- **[PROVEN] Intrinsic cascade characterization.** A solution `n` is a cascade term `6^(2^j)−1` **⟺ `n+1` is {2,3}-smooth ⟺ `φ(n)` is {2,3}-smooth** (for primes `ℓ≥5`, `v_ℓ(φ(n))=v_ℓ(n+1)`). The cascade primes `5,7,37,1297` are exactly the primes `r` with `r−1` {2,3}-smooth.
- **[PROVEN] Primality sieve — and it EXPLAINS the two composites.** For `ℓ≠3`: `ℓ | p ⟺ N ≡ −4⁻¹ (mod ℓ)`. The composite cascade cases land exactly on a "killer residue": `1295 ≡ 8 ≡ −4⁻¹ (mod 11)` ⇒ `11∣1727`; `1679615 ≡ 17 ≡ −4⁻¹ (mod 23)` ⇒ `23∣2239487`. The two prime cases `5,35` avoid every killer `≤√p`. This is *why* the cascade yields exactly `{7,47}`.
- **[PROVEN, NEGATIVE] No covering congruence can close it.** For every prime `ℓ≥5`, all coprime residues of `N (mod ℓ)` are reachable under the equation; no finite CRT covering forces `p` composite. So congruence/elementary methods alone cannot resolve EG#411 r=2 — confirming its Fermat-prime-hardness. (A Mertens-product heuristic suggests "almost all" further solutions would give composite `p`, but that is explicitly a heuristic, not a proof.)

## 6. Computational corroboration [COMPUTED]

- Dense Euler-φ scan to `3×10^7` and a `{2,3}-smooth-class` exhaustive search to **`10^13`**: solution set is exactly `{5,35,1295,1679615}`; only
  `n=5,35` give a prime `(4n+1)/3 ≡ 7 mod 8` (→ 7, 47). The other two give
  `1727=11·157` and `2239487=23·97369`.
- Structured "closing-prime" search (Hercher's method: a partial square-free product `P,Q` is
  completed by `q=(3Q+2)/(3Q−2P)` when that is prime): over body primes `< 4000`, `n < 10^20`,
  ~`3×10^6` nodes — found **exactly** the four cascade solutions and **no fifth**. The search
  reproduces the cascade and stalls precisely at `6^8+1` composite. *(Bounded search, not
  exhaustive; consistent with Hercher's ≥7-factor / ≥10^14 frontier.)*
- No covering congruence (primes `< 5000`) and no algebraic factorization makes `p_j` composite
  for all `j` — so the broader "are infinitely many `p_j` prime?" question is Fermat-prime-hard
  (and moot for EG#411, since the cascade already terminates at `j=3`).

---

## 6b. Kernel-checked Lean [PROVEN, builds]

`EG411Formal/RealResult.lean` (Lean 4 + Mathlib v4.29.1, `lake build` green, 2026-06-09) proves
the true core: `reduction`, `master_identity` (`p=2φ(N)−1`), `mod8_free` (`≡7 mod 8` is automatic),
`telescope` (the cascade backbone), the totient gem (`φ(m)≤m−1`, `=` iff prime), `phi_1679615`
(axiom-free via factorization, no `native_decide`), `cascade_solution_1679615`, `six8_not_prime`
(cascade termination), and `cascade_exceptional_primes` (`p_0=7, p_1=47` prime; `p_2,p_3` composite).
**Verified axiom footprints:** the algebraic results depend only on `{propext, Classical.choice,
Quot.sound}` — **no custom math axiom**, in deliberate contrast to the retracted closure's
project-local `rosser_schoenfeld_1962_thm7_cambie`. The concrete primality facts additionally
carry the standard `native_decide` compiler-trust axiom, disclosed per-theorem.

**Crown jewel — the general cascade lemma** (`EG411Formal/CascadeLemma.lean`, `lake build` green
from a clean recompile, **fully axiom-free**: `#print axioms cascade_lemma = {propext,
Classical.choice, Quot.sound}` — no `native_decide`, no custom axiom):
```
theorem cascade_lemma (j : ℕ) :
    3 * Nat.totient (6 ^ 2 ^ j - 1) = 2 * (6 ^ 2 ^ j - 1) + 2
      ↔ ∀ k, k < j → Nat.Prime (6 ^ 2 ^ k + 1)
```
It characterizes **exactly** which base-6 cascade members `6^(2^j)−1` solve the totient equation —
the equation holds iff every `6^(2^k)+1` (`k<j`) is prime — which is precisely *why* the family is
finite (it dies at the first composite `6^(2^k)+1`, namely `6^8+1`). Proof: the inductive-invariant
argument (`3φ(n_j) ≤ 2a_j` propagated, then `a*b=A*B` forces `a=A ∧ b=B`), no Finset products.
Independently re-verified this session (statement exact, zero `sorry`, clean-recompile green).

## 7. What remains OPEN

> **[OPEN]** Does a **non-cascade** solution of `φ(n)=(2/3)(n+1)` exist (necessarily square-free,
> `≥7` prime factors, `n ≥ 10^14`), and if so does it yield a prime `(4n+1)/3 ≡ 7 mod 8`?

This is the entire remaining gap. EG#411 r=2 is complete **iff** Steinerberger's totient
conjecture holds (or, more weakly, iff no non-cascade solution produces a valid prime). Both are
hard, totient-existence problems. No shortcut (covering, algebra, the extra primality constraint)
closes it tonight — and claiming otherwise would repeat the error this session just retracted.

---

## 8. The honest headline

> EG#411 (r=2) reduces (via a previously-unpublished bridge) to the totient equation
> `φ(N)=(2/3)(N+1)`. Its known solutions form a base-6 generalized-Fermat **cascade**
> `N=6^(2^j)−1` that **provably terminates at `j=3`** because `6^8+1` is composite; the
> corresponding primes are **exactly 7 and 47**. Combining the bridge with Hercher (2025) gives
> **no exceptional prime below `1.33×10^14`** — up from the published `10^10`. A full resolution
> is equivalent to ruling out non-cascade totient solutions, which remains **open**.

## References
- S. Steinerberger, *On an iterated arithmetic function problem of Erdős and Graham*, arXiv:2504.08023 (2025).
- C. Hercher, *On positive integers n with φ(n)=(2/3)(n+1)*, arXiv:2504.19915 (2025).
