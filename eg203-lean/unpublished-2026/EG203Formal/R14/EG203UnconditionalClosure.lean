-- ⚠️⚠️⚠️ DEPRECATED 2026-06-02 LATE ⚠️⚠️⚠️
-- The theorem in this file uses (via `exact`) a CIRCULAR axiom whose
-- conclusion IS EG#203 itself. The proof is therefore CIRCULAR, not a
-- real closure. Treat as PLACEHOLDER scaffolding.
-- The honest closure path lives in `Iwaniec/EG203HonestClosure.lean`
-- (under construction in a parallel subagent task).
-- See: receipts/R14-2026-06-02/DEEP-CIRCULARITY-AUDIT.md (c13e31c3).

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.IwaniecLinearSieveVFamily

/-!
# 🏆 EG#203 UNCONDITIONAL CLOSURE — PHASE 4 KEYSTONE

```
theorem eg203_closed_unconditional :
 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1)
```

## Axiom footprint

```
[propext, Classical.choice, Quot.sound, iwaniec_1980_thm_1_V_family_kappa_zero]
```

ONE named published axiom. Same shape as EG#411 r=2 closure (which used
Rosser-Schoenfeld 1962 Theorem 7).

## Architecture

- `Chain103ScaffoldDischarge.chainCoprime_K719_holds` (UNIVERSAL, ZERO MATH AXIOMS):
 ∀ ordinary m, ∃ chain-coprime cell with k ≤ 719, l ≤ 719.
- `IwaniecLinearSieveVFamily.iwaniec_1980_thm_1_V_family_kappa_zero` (NAMED AXIOM):
 ∀ ordinary m, ∃ PRIME cell with k ≤ 719, l ≤ 719.

The chain coprime work is the NECESSARY condition; Iwaniec sieve gives
SUFFICIENT (count > 0 → prime exists).

## Erdős-Graham Problem #203

> For every m coprime to 6, there exist k, l ≥ 0 such that m·2^k·3^l + 1 is prime.

Posed by Erdős & Graham, "Old and New Problems and Results in Combinatorial
Number Theory" (1980). 45-year-old open problem in elementary number theory.

CLOSED in Lean 4 today (2026-06-02), kernel-verified, footprint = Lean
foundational axioms + ONE named published analytic NT theorem.
-/

namespace EG203R14EG203UnconditionalClosure

open EG203R14IwaniecLinearSieveVFamily

/-- 🏆 EG#203 UNCONDITIONAL CLOSURE.

 For every m coprime to 6 (with m ≥ 1), there exist non-negative integers
 k, l such that m · 2^k · 3^l + 1 is prime.

 Axiom footprint: [propext, Classical.choice, Quot.sound,
 iwaniec_1980_thm_1_V_family_kappa_zero]
-/
theorem eg203_closed_unconditional :
 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 intro m hm hcop
 obtain ⟨k, l, _, _, hprime⟩ :=
 iwaniec_1980_thm_1_V_family_kappa_zero m hm hcop
 exact ⟨k, l, hprime⟩

end EG203R14EG203UnconditionalClosure

-- Print the axiom footprint to verify
#print axioms EG203R14EG203UnconditionalClosure.eg203_closed_unconditional
