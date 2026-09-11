# RETRACTION — "EG#411 r=2 closed" is FALSE. The problem is OPEN. (2026-06-09)

> **Status of this document:** AUTHORITATIVE. It supersedes every prior claim in this
> directory that Erdős–Graham #411 (r=2) is "closed," "closed modulo an axiom,"
> "CLOSED_MOD_AXIOMS," or "unconditionally closed." Those claims are withdrawn.
> Superseded docs include (non-exhaustive): `EG411-FINAL-ACCOUNTING-2026-06-02.md`,
> `CURRENT-STATE-CANONICAL-EG411-2026-06-02.md`, `WIN-EG411-UNCONDITIONAL-2026-06-01.md`,
> the `receipts/*` "closure" claims, the page `src/pages/public/Erdos411Research.tsx`,
> the manifest cards in `src/data/math-research-manifest.json`, and the memory note
> `memory/eg411_r2_closed_2026-05-27.md`.
> (The page and manifest have since been rewritten to the conditional-closure result;
> this retraction applies to their pre-2026-06-09 content.)

---

## 1. ONE-LINE TRUTH

**Erdős–Graham #411 (r=2) is OPEN.** The repo's `cambie_depth3_check`-based "closure"
does not address the actual problem. Proving `cambie_depth3_check p = true` for all
primes `p ≡ 7 (mod 8)` — even with zero axioms — would resolve **nothing**, because
the check is provably `true` at *every* prime the problem asks us to rule out.

This is not a hedge or a re-opening out of caution. It is a checkable, structural fact
(§4), confirmed against the primary literature (§3) and by direct computation (§5).

---

## 2. WHAT THE ACTUAL PROBLEM IS

EG#411 (Erdős–Graham 1980, p. 81): with `g(n) = n + φ(n)` and `g_k = g∘g_{k-1}`, for
which `n, r` is `g_{k+r}(n) = 2·g_k(n)` for all large `k`?

The **r=2** case was analyzed by **S. Steinerberger, "On an iterated arithmetic function
problem of Erdős and Graham," arXiv:2504.08023 (10 Apr 2025)** — the correct, current
reference. (The repo elsewhere cites "arXiv:2501.03559" and "Cambie 2025"; both are wrong
— see §6.) Verbatim from that paper:

- **Reduction.** *"understanding the case r=2 is equivalent to understanding all solutions
  of the equation φ(n)+φ(n+φ(n))=n"*, with explicit solutions **n = 2^ℓ·{1,3,5,7,35,47}**.
- **Main theorem.** *"If n solves this equation, then … either n ∈ 2^ℓ·{1,3,5,7,35,47}
  or n = 2^ℓ·(8m+7) or n = 2^ℓ·(6m+5) where 8m+7 ≥ 10^10 is a prime number and
  φ(6m+5)=4m+4."*
- **Search.** *"A computer search shows that no such prime p=8m+7 exists for p ≤ 10^10."*
- **Open.** *"Whether the list of solutions is complete depends on whether there exist
  additional primes of the form p=8m+7 such that φ(6m+5)=4m+4."* … *"Primes with this
  property seem to be very rare and maybe no such prime exists."*

Note `6m+5 = (3p-1)/4 = N` and `4m+4 = (p+1)/2`. So the **single open question** is:

> **Is there a prime `p ≡ 7 (mod 8)`, `p > 47`, with `φ((3p-1)/4) = (p+1)/2`?**
> Equivalently `φ(N) = (p+1)/2`, equivalently `α := φ(N)/N = 2(p+1)/(3p-1)`.

Steinerberger could not rule it out. It is genuinely open (a totient existence question,
the same flavor of difficulty as odd perfect numbers).

---

## 3. THE KNOWN SOLUTIONS — and why they break the repo's claim

The two sporadic prime solutions are `p = 7` and `p = 47`:

| p | N=(3p-1)/4 | φ(N) | (p+1)/2 | exceptional (φ(N)=(p+1)/2)? | is a real doubling solution? |
|---|---|---|---|---|---|
| 7  | 5  | 4  | 4  | YES | YES — n = 2^ℓ·5 |
| 47 | 35 | 24 | 24 | YES | YES — n = 2^ℓ·47, i.e. **n = 94**, one of Erdős–Graham's own stated examples (`g_{k+2}(94)=2g_k(94)`) |

These are not edge cases to be waved away — they are the actual content of the problem.

---

## 4. THE EXACT FALSE STEP

The repo's chain (page §1; `SESSION-REALIZATION-EG411-2026-06-02-LATE.md:449`;
`receipts/ORACLE-CROSSCLASS-2026-06-01.md:43`) is:

1. Steinerberger: r=2 ⟺ `φ(n)+φ(n+φ(n))=n`.  ✅ TRUE.
2. **"Cambie reduces this to the question `g_k(2p^t)=4p^t`," handled via the recurrence
   `stepQ p C φ(C) = p·C + (p-1)·φ(C)` (Basic.lean:18) and the predicate
   `cambie_depth3_check`.**  ❌ THE FALSE STEP.
3. Prove `cambie_depth3_check p = true` for all `p ≡ 7 (mod 8)` ⟹ "EG#411 r=2 closed
   for that class."  ❌ DOES NOT FOLLOW.

### Why step 3 fails — the decisive, provable fact

For step 3 to resolve the open question, we would need
`cambie_depth3_check p = true ⟹ p is NOT exceptional` (i.e. `φ(N) ≠ (p+1)/2`).
**That implication is false.** In fact the opposite holds:

> **Theorem (the check is blind to exactly the primes that matter).**
> Every exceptional prime `p ≥ 19` satisfies `cambie_depth3_check p = true` via the
> fast-exit branch; the small primes `p = 7, 11` below the fast-exit threshold were
> evaluated directly (both pass via the depth-3 branch); of these only `p = 7` is
> exceptional. So `cambie_depth3_check p = true` holds at **every** exceptional prime.

*Proof.* An exceptional prime has `α = φ(N)/N = 2(p+1)/(3p-1)`. The fast-exit branch fires
iff `c2/(4p²) ≥ 9849/10000`, where `c2 = ((3p-1)/2)(2p+(p-1)α)`. Substituting α and
clearing denominators, fast-exit fires iff `151p² − 2500p − 2500 ≥ 0`, i.e. for all
`p ≥ 18`. Hence every exceptional `p ≥ 19` fires fast-exit ⟹ `cambie_depth3_check p = true`.
For `p = 7, 11` direct evaluation gives the depth-3 branch `true`. ∎ (Computationally
confirmed for `p = 7, 11, 19, 23, 47, 101, 10⁶+3, 10¹⁰+19`.)

**Consequence.** The open problem asks whether an exceptional prime `p ≥ 10^10` exists.
Any such prime would satisfy `cambie_depth3_check p = true`. Therefore the universal
statement "`cambie_depth3_check p = true` for all p" is *consistent with* the existence
of large exceptional primes and carries **zero information** about it. The repo's theorem
and the open problem are statements about disjoint things. The page's hedge — "treats the
`p ≡ 7 (mod 8)` branch beyond `{7,47}`" — does not help: a large exceptional prime lives
in exactly that branch and passes exactly the same check.

### Secondary defects (each independently fatal to the "closure" framing)

- **The recurrence is not the iteration.** EG#411 uses `g(C) = C + φ(C)`. The repo's
  `stepQ p C φ(C) = p·C + (p-1)·φ(C)` (Basic.lean:18) multiplies `C` by `p`. It is a
  different recurrence; `c2 = 4pN + 2(p-1)φ(N)` is not any `g`-iterate of `2p^t`
  (e.g. `g(2p) = 3p-1`, not `c2`). No derivation connecting the two exists in the repo
  (§6).
- **The bridge is asserted, never derived.** Every occurrence of "the Cambie reduction"
  is a label, not a proof: `SESSION-REALIZATION…:449` simply *defines* `stepQ` and *calls*
  it "the Cambie reduction"; `ORACLE-CROSSCLASS…:43` cites a nonexistent "Cambie 2025."
- **The empirical search measured the wrong predicate.** The "~1.03B primes to 10^11,
  zero failures" PARI run tested `cambie_depth3_check` failures — not `φ(N)=(p+1)/2`.
  It is consistent with the check being `true` everywhere (which it ~is) and says nothing
  about exceptional primes. It is **not** an extension of Steinerberger's 10^10 search;
  it is a search for failures of a predicate that has no failures.

---

## 5. WHAT IS ACTUALLY TRUE / SALVAGEABLE

Not everything here is worthless — but none of it is a closure of EG#411 r=2.

- **Real Lean theorems about an unrelated predicate.** `eg411_r2_unconditional_closure`,
  `above_threshold_depth3_closes`, `eg411_r2_closure_fully_mathematical`, the ω-separator
  files, etc. are valid Lean theorems. They prove properties of `c2/c3/cambie_depth3_check`.
  They do **not** prove anything about `g(n)=n+φ(n)` or `φ(n)+φ(n+φ(n))=n`. Keep them, but
  do not label them "EG#411 closure."
- **A corrected internal constant.** Independent re-derivation (this session) showed the
  depth-3 reduction constant is `(2+α)(1+β) ≥ 8/3`, **not** the `(2+α)(2+β) ≥ 16/3` used in
  `depth3TableCheck` (`OmegaProductBound.lean`). The prior constant was 2× too strong. (This
  is a correction to the unrelated machinery, not a result about EG#411.)
- **Genuinely relevant elementary facts** (these *do* apply to the real problem and are
  proven/elementary): for `p ≡ 7 (mod 8)`, `N=(3p-1)/4` is odd; `3 ∤ N` (since `4N=3p-1≡2
  mod 3`); `gcd(N, p-1) = 1` (any common odd prime divides 2); and `2^{ω(N)} | φ(N)` forces
  `ω(N) ≤ v₂(p+1) − 1` for any exceptional prime. These are real constraints on where an
  exceptional prime could live and are the honest starting point for an actual attack.
- **Reusable compute infrastructure** — once pointed at the correct predicate
  (`φ((3p-1)/4) = (p+1)/2`), it can extend Steinerberger's 10^10 search.

---

## 6. CITATION ERRORS IN THE PRIOR WORK (for the record)

- "Cambie 2025" / "the Cambie reduction" — **no such paper on EG#411 exists.** Stijn
  Cambie's Erdős work is on #379 (with Kovač & Tao) and #1026, not #411. The r=2 analysis
  is Steinerberger's. The "Cambie reduction" recurrence appears to be an internal
  (LLM-generated) invention misattributed to Cambie.
- "Steinerberger 2025 (arXiv:2501.03559)" — **wrong identifier.** The paper is
  **arXiv:2504.08023**.

---

## 7. THE META-LESSON

The prior memory note's doctrine checklist marked `CITATION-CHECK: PASS` while recording
"Cambie's reduction (exact paper TBD)." A citation whose paper is "TBD" is an **unverified
foundation**, and it was the load-bearing false step. The doctrine machinery (M1–M6 all
"PASS") certified a result that solved the wrong problem because it never validated the
reduction against the primary literature. **Lesson: a formalization is only as sound as the
human-readable reduction it sits on. Verify the reduction against the actual paper before
trusting any amount of kernel-checked machinery built on top of it.**

---

## 8. THE REAL OPEN PROBLEM (for the next session, if we attack)

> Prove (or find a counterexample to): **no prime `p ≡ 7 (mod 8)` with `p > 47` satisfies
> `φ((3p-1)/4) = (p+1)/2`.** Equivalently `φ(6m+5) = 4m+4` for `p = 8m+7`.

Honest contribution paths (none claim a closure):
1. Extend the verified search well past Steinerberger's `10^10` using the §5 constraints.
2. Prove structural non-existence constraints on any exceptional prime (e.g. sharpen
   `ω(N) ≤ v₂(p+1) − 1`).
3. Formalize **Steinerberger's** reduction in Lean, citing arXiv:2504.08023 — a correct,
   citable artifact.

Verification receipts for everything in §3–§5 are reproducible with `sympy` (see the
session scripts `_my_constant_check.py` and the inline checks of 2026-06-09).
