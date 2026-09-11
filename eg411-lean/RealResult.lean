import Mathlib.Data.Nat.Totient
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum.Prime

/-!
# EG#411 (r=2): kernel-checked TRUE results (2026-06-09)

This file formalizes the reduction EG#411 r=2 ⟺ the totient equation, and the structure that
follows. HEADLINES (all kernel-checked):
  • `reduction`        — EG#411 r=2 ⟺ `3·φ(N) = 2N+2`                       (axiom-free)
  • `master_identity`  — every solution has `p = 2·φ(N) − 1`                (axiom-free)
  • `mod8_free`        — the `p ≡ 7 (mod 8)` clause is automatic; it carries (axiom-free)
                         NO information, so the problem is purely primality of `p`
  • `cascade_lemma`    — (in CascadeLemma.lean) `6^(2^j) − 1` solves the eq  (FULLY axiom-free)
                         ⟺ every `6^(2^k) + 1`, `k < j`, is prime
  • `eg411_r2_conditional_closure` — assuming Steinerberger's conjecture,    (no custom axiom)
                         the exceptional primes are EXACTLY `{7, 47}`

EG#411 r=2 is **unconditionally OPEN** (at least as hard as Steinerberger's totient conjecture —
Hercher: any further solution is square-free, has ≥7 prime factors, and is ≥10^14). Nothing
here claims to close it unconditionally. The point is that every step is machine-checked and
there is **NO project-local axiom** — contrast the RETRACTED `cambie_depth3_check` closure
(see `RETRACTION.md`), whose axiom asserted its own conclusion.

Steinerberger (arXiv:2504.08023) reduced the open r=2 question to: does a prime
`p ≡ 7 (mod 8)`, `p > 47`, satisfy `φ((3p−1)/4) = (p+1)/2`?  With `N = (3p−1)/4`
(so `3p = 4N+1`) this is the totient equation `3·φ(N) = 2N+2` studied by Hercher
(arXiv:2504.19915).

Algebraic results below are axiom-free (`propext, Classical.choice, Quot.sound` only).
The concrete computational facts use `native_decide` (adds the standard `Lean.ofReduceBool`).

VERIFIED axiom footprints (`#print axioms`, 2026-06-09):
  reduction, master_identity, mod8_free, telescope, totient_le_sub_one,
  phi_1679615, cascade_solution_1679615  →  {propext, (Classical.choice,) Quot.sound}
      i.e. NO custom math axiom — contrast the RETRACTED `rosser_schoenfeld_1962_thm7_cambie`,
      a project-local axiom that asserted the very conclusion it was used to prove.
  cascade_exceptional_primes and the other native_decide facts  →  the above PLUS the standard
      `native_decide` compiler-trust axiom, on the primality checks only.
-/

set_option linter.style.nativeDecide false

namespace EG411RealResult

/-! ## 1. The reduction and master identity (axiom-free, over ℤ) -/

/-- The exceptional condition `2·φ(N) = p+1` is exactly the totient equation
`3·φ(N) = 2N+2`, given `3p = 4N+1`. -/
theorem reduction (N p t : ℤ) (hp : 3 * p = 4 * N + 1) :
    2 * t = p + 1 ↔ 3 * t = 2 * N + 2 := by
  constructor <;> intro h <;> linarith

/-- **Master identity:** every solution has `p = 2·φ(N) − 1`. -/
theorem master_identity (N p t : ℤ) (hp : 3 * p = 4 * N + 1) (heq : 3 * t = 2 * N + 2) :
    p = 2 * t - 1 := by linarith

/-! ## 2. The `≡ 7 (mod 8)` clause is automatic (axiom-free) -/

/-- For any odd `N`, `p = (4N+1)/3` satisfies `p ≡ 7 (mod 8)`. So the entire mathematical
content of EG#411 r=2 is the **primality** of `p`; the residue clause carries no information. -/
theorem mod8_free (N p : ℤ) (hp : 3 * p = 4 * N + 1) (hodd : N % 2 = 1) : p % 8 = 7 := by
  omega

/-! ## 3. Telescoping identity (axiom-free) — the backbone of the cascade lemma -/

/-- `6^(2^(j+1)) − 1 = (6^(2^j) − 1)·(6^(2^j) + 1)` over ℤ. -/
theorem telescope (j : ℕ) :
    (6 : ℤ) ^ (2 ^ (j + 1)) - 1 = (6 ^ (2 ^ j) - 1) * (6 ^ (2 ^ j) + 1) := by
  have h : (2 : ℕ) ^ (j + 1) = 2 ^ j * 2 := by rw [pow_succ]
  rw [h, pow_mul]
  ring

/-! ## 4. The totient gem (axiom-free): `φ(m) ≤ m − 1`, with equality iff `m` prime.
This is what makes the cascade lemma exact — a product of factors `φ(F_k)/(F_k−1) ≤ 1`
equals 1 iff every `F_k` is prime. -/

theorem totient_le_sub_one {m : ℕ} (hm : 1 < m) : Nat.totient m ≤ m - 1 := by
  have := Nat.totient_lt m hm; omega

/-- One direction of the gem (the elementary `only-if`): if `m` is prime then
`φ(m) = m − 1`. (Mathlib `Nat.totient_prime`.) -/
theorem totient_prime_eq {m : ℕ} (hm : m.Prime) : Nat.totient m = m - 1 :=
  Nat.totient_prime hm

/-! ## 5. The cascade and its termination (native_decide) -/

/-- The known totient solutions `5, 35, 1295` satisfy `3·φ(n) = 2n+2`. -/
theorem cascade_solutions_small :
    3 * Nat.totient 5 = 2 * 5 + 2 ∧
    3 * Nat.totient 35 = 2 * 35 + 2 ∧
    3 * Nat.totient 1295 = 2 * 1295 + 2 := by
  native_decide

/-- `φ(1679615) = 1119744` via the prime factorization `5·7·37·1297`
(avoids a totient over a 1.68M range). -/
theorem phi_1679615 : Nat.totient 1679615 = 1119744 := by
  have e : (1679615 : ℕ) = 5 * 7 * 37 * 1297 := by norm_num
  rw [e, Nat.totient_mul (by decide), Nat.totient_mul (by decide), Nat.totient_mul (by decide),
      Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num),
      Nat.totient_prime (by norm_num), Nat.totient_prime (by norm_num)]

/-- The fourth known solution `1679615` also satisfies the equation. -/
theorem cascade_solution_1679615 : 3 * Nat.totient 1679615 = 2 * 1679615 + 2 := by
  rw [phi_1679615]

/-- **Cascade termination:** `6^8 + 1` is composite (`= 17 · 98801`), so the base-6
generalized-Fermat cascade `6^(2^j) − 1` yields no totient solution past `j = 3`. -/
theorem six8_factor : 6 ^ 8 + 1 = 17 * 98801 := by native_decide

theorem six8_not_prime : ¬ Nat.Prime (6 ^ 8 + 1) := by native_decide

/-! ## 6. The cascade's exceptional primes are EXACTLY {7, 47} (native_decide).
`p_j = 2^(2^j+2) · 3^(2^j−1) − 1`. -/

theorem p0_eq : 2 ^ 3 * 3 ^ 0 - 1 = 7 := by native_decide
theorem p1_eq : 2 ^ 4 * 3 ^ 1 - 1 = 47 := by native_decide
theorem p0_prime : Nat.Prime (2 ^ 3 * 3 ^ 0 - 1) := by native_decide
theorem p1_prime : Nat.Prime (2 ^ 4 * 3 ^ 1 - 1) := by native_decide
theorem p2_composite : ¬ Nat.Prime (2 ^ 6 * 3 ^ 3 - 1) := by native_decide   -- 1727 = 11·157
theorem p3_composite : ¬ Nat.Prime (2 ^ 10 * 3 ^ 7 - 1) := by native_decide  -- 2239487 = 23·97369

/-- Within the base-6 cascade, exactly two candidate primes `p_j` are prime: `p_0 = 7`
and `p_1 = 47`. (Their successors `p_2 = 1727`, `p_3 = 2239487` are composite, and the
cascade terminates at `j = 3` by `six8_not_prime`.) These are the two known EG#411
exceptional primes. -/
theorem cascade_exceptional_primes :
    Nat.Prime (2 ^ 3 * 3 ^ 0 - 1) ∧ Nat.Prime (2 ^ 4 * 3 ^ 1 - 1) ∧
    ¬ Nat.Prime (2 ^ 6 * 3 ^ 3 - 1) ∧ ¬ Nat.Prime (2 ^ 10 * 3 ^ 7 - 1) :=
  ⟨p0_prime, p1_prime, p2_composite, p3_composite⟩

/-! ## 7. CONDITIONAL CLOSURE of EG#411 (r=2).

Steinerberger's conjecture — that the totient equation `3·φ(n) = 2n+2` has ONLY the four
solutions `{5, 35, 1295, 1679615}` — is the clean, named, independently-studied open
statement. Hercher (arXiv:2504.19915) proved any further solution is square-free with ≥7
distinct prime factors and `≥ 10^14`; it is verified computationally well beyond that. We do
NOT prove it — that is the number theorists' problem. We prove that **it IMPLIES EG#411 r=2 is
resolved**: the only exceptional primes are 7 and 47. The hypothesis is strictly stronger than
the conclusion and is not a restatement of it (it rules out ALL further totient solutions, even
the ones whose `(4n+1)/3` is composite). This is a genuine conditional theorem, in the same
sense as "assuming RH, …". -/

/-- Steinerberger's totient conjecture, as an explicit hypothesis (NOT an axiom). -/
def TotientConjecture : Prop :=
  ∀ n : ℕ, 3 * Nat.totient n = 2 * n + 2 → n = 5 ∨ n = 35 ∨ n = 1295 ∨ n = 1679615

/-- **Conditional closure of EG#411 (r=2).** Assuming Steinerberger's totient conjecture,
every EG#411 exceptional prime `p` — i.e. every prime with `3p = 4N+1` for a solution `N` of
`3·φ(N) = 2N+2` — is `7` or `47`. -/
theorem eg411_r2_conditional_closure (H : TotientConjecture)
    (N p : ℕ) (hN : 3 * Nat.totient N = 2 * N + 2)
    (hp : 3 * p = 4 * N + 1) (hpr : Nat.Prime p) :
    p = 7 ∨ p = 47 := by
  rcases H N hN with h | h | h | h
  · left;  omega                       -- N = 5     ⟹ 3p = 21   ⟹ p = 7
  · right; omega                       -- N = 35    ⟹ 3p = 141  ⟹ p = 47
  · exfalso                            -- N = 1295  ⟹ p = 1727  = 11·157  (not prime)
    have hp' : p = 1727 := by omega
    rw [hp'] at hpr; exact absurd hpr (by norm_num)
  · exfalso                            -- N = 1679615 ⟹ p = 2239487 = 23·97369 (not prime)
    have hp' : p = 2239487 := by omega
    rw [hp'] at hpr; exact absurd hpr (by norm_num)

/-- Same closure phrased directly on the prime `p` (Steinerberger's exceptional condition
`φ((3p−1)/4) = (p+1)/2`, here `2·φ(N) = p+1` with `3p = 4N+1`). -/
theorem eg411_r2_conditional_closure' (H : TotientConjecture)
    (N p : ℕ) (hp : 3 * p = 4 * N + 1) (hexc : 2 * Nat.totient N = p + 1)
    (hpr : Nat.Prime p) :
    p = 7 ∨ p = 47 := by
  refine eg411_r2_conditional_closure H N p ?_ hp hpr
  omega

end EG411RealResult
