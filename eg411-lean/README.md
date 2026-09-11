# Erdős–Graham #411 (r = 2): a kernel-checked conditional closure

**Claim.** With `g(n) = n + φ(n)`, the r = 2 case of Erdős–Graham #411 reduces
(Steinerberger, [arXiv:2504.08023](https://arxiv.org/abs/2504.08023)) to a question about
primes `p ≡ 7 (mod 8)`: is there one, `p > 47`, with `φ((3p−1)/4) = (p+1)/2`?

Setting `N = (3p−1)/4` (so `3p = 4N+1`), that condition is **exactly** the totient equation
`3·φ(N) = 2N+2`, studied by Hercher ([arXiv:2504.19915](https://arxiv.org/abs/2504.19915)).
This reduction — the bridge between EG#411 and that totient equation — is the contribution.
On top of it:

> **EG#411 (r = 2) is closed, conditional on Steinerberger's totient conjecture**
> (that `3·φ(n) = 2n+2` has only the four solutions `{5, 35, 1295, 1679615}`).
> Granting it, the exceptional primes are **exactly 7 and 47**.
> This is a Lean 4 theorem with **no custom axiom** — the conjecture is an explicit
> hypothesis, not an axiom asserting the conclusion.

The reduction and the cascade structure are **unconditional and fully axiom-free**. No
exceptional prime exists below **1.33 × 10¹⁴** (Hercher's `n ≥ 10¹⁴` via the reduction;
up from Steinerberger's `10¹⁰`).

This is **not** an unconditional proof of EG#411 r = 2, and does not claim to be. It is a
correct, machine-checked reduction + conditional closure + new structure. The remaining input
is Steinerberger's conjecture, which is the number theorists' to prove or break.

---

## What's in this package

| File | What it is |
|---|---|
| `RealResult.lean` | The reduction, `master_identity` (`p = 2φ(N)−1`), `mod8_free`, the totient gem, `phi_1679615` (axiom-free), the concrete cascade facts, and **`eg411_r2_conditional_closure`** (fully axiom-free). |
| `CascadeLemma.lean` | **`cascade_lemma`** — the general iff characterizing exactly which base-6 cascade members `6^(2^j)−1` solve the totient equation. Fully axiom-free. |
| `SolutionStructure.lean` | Every solution of `3·φ(n)=2n+2` is odd, coprime to 3, **squarefree**, **chain-free**; the only prime solution is 5; the only two-prime solution is 35. Fully axiom-free. |
| `OmegaLadder.lean` | The only three-prime solution is **1295**; the only four-prime solution is **1679615** — exact factor-eliminations. Fully axiom-free. |
| `OmegaTreeSupport.lean`, `OmegaTree5.lean` | **`omega5_empty`** — the certified 22-leaf ω=5 kill-tree in the kernel: NO solution has five prime factors. |
| `OmegaCapstone.lean` | **`exceptional_high_omega`** (ω(N) ≥ 5, fully axiom-free) and **`exceptional_high_omega_six`** (ω(N) ≥ 6): any exceptional prime beyond 7 and 47. Plus the sharp conditional closures. |
| `omega_tree_enumerator.py`, `omega5/6_tree.json` | The certified kill-tree enumerator + the ω=5 (22-leaf) and ω=6 (410-leaf) trees, both EMPTY. |
| `omega7-kill-tree.zip` (separate download) | The complete **ω=7 tree: 272,676 terminals, EMPTY** — triple-implemented, hostile-reviewed ⟹ any fifth solution needs **≥ 8 prime factors** (beyond the published ω ≥ 7). |
| `RESULT.md` | The full write-up, every claim labeled PROVEN / COMPUTED / CITED / OPEN. |
| `RETRACTION.md` | Full transparency: an earlier "closure" of ours (via a predicate `cambie_depth3_check`) was **not** equivalent to EG#411 and is retracted. This package supersedes it. |
| `lakefile.toml`, `lean-toolchain` | Lean `v4.29.1` + Mathlib `v4.29.1` pin. |

---

## Verify it yourself

These files build against **Lean 4 `v4.29.1` + Mathlib `v4.29.1`**.

1. In a Lean project on that toolchain with Mathlib as a dependency, create a library directory
   `EG411Formal/` and place ALL SEVEN `.lean` files inside it (they import each other as
   `EG411Formal.<Name>`; the shipped `lakefile.toml` + `lean-toolchain` give the exact pins). Then:
   ```
   lake build EG411Formal.RealResult EG411Formal.CascadeLemma EG411Formal.OmegaCapstone
   ```
   (building `OmegaCapstone` pulls in `SolutionStructure`, `OmegaLadder`, `OmegaTreeSupport`,
   and `OmegaTree5` automatically).
2. Check the axiom footprints — this is the whole point:
   ```lean
   import EG411Formal.RealResult
   import EG411Formal.CascadeLemma
   import EG411Formal.OmegaCapstone
   #print axioms EG411RealResult.eg411_r2_conditional_closure
   #print axioms EG411Cascade.cascade_lemma
   #print axioms EG411Capstone.exceptional_high_omega
   #print axioms EG411Capstone.exceptional_high_omega_six
   ```

### Expected output

```
'EG411RealResult.eg411_r2_conditional_closure' depends on axioms:
  [propext, Classical.choice, Quot.sound]      -- fully axiom-free

'EG411Cascade.cascade_lemma' depends on axioms:
  [propext, Classical.choice, Quot.sound]      -- fully axiom-free

'EG411Capstone.exceptional_high_omega' depends on axioms:
  [propext, Classical.choice, Quot.sound]      -- fully axiom-free (ω ≥ 5)

'EG411Capstone.exceptional_high_omega_six' depends on axioms:
  [propext, Classical.choice, Quot.sound, <33 omega5_empty native_decide certificates>]
                                               -- ω ≥ 6: 33 disclosed scan certificates
```

`propext, Classical.choice, Quot.sound` are the three logical axioms every Mathlib theorem uses.
The conditional closure, the cascade lemma, the full solution-structure chain, and the ω ≥ 5
bound trust **nothing** beyond the kernel. The ω ≥ 6 bound additionally trusts `native_decide`
on the 33 finite scans of the ω=5 kill-tree (each one a bounded, independently re-verifiable
computation; the hostile audit additionally brute-forced 1,370,754 prime 5-subsets — empty).
There is **no** project-local "assume the conclusion" axiom anywhere — that was the defect in the
retracted work (see `RETRACTION.md`), and it is gone.

---

## The headline theorems

```lean
-- EG#411 (r=2), conditional on Steinerberger's totient conjecture:
theorem eg411_r2_conditional_closure (H : TotientConjecture)
    (N p : ℕ) (hN : 3 * Nat.totient N = 2 * N + 2)
    (hp : 3 * p = 4 * N + 1) (hpr : Nat.Prime p) :
    p = 7 ∨ p = 47

-- The cascade, fully characterized (fully axiom-free):
theorem cascade_lemma (j : ℕ) :
    3 * Nat.totient (6 ^ 2 ^ j - 1) = 2 * (6 ^ 2 ^ j - 1) + 2
      ↔ ∀ k, k < j → Nat.Prime (6 ^ 2 ^ k + 1)
```

## References
- S. Steinerberger, *On an iterated arithmetic function problem of Erdős and Graham*, arXiv:2504.08023 (2025).
- C. Hercher, *On positive integers n with φ(n) = (2/3)(n+1)*, arXiv:2504.19915 (2025).
- Erdős Problems #411 (T. F. Bloom), https://www.erdosproblems.com/411
