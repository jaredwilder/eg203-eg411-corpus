/-
Copyright (c) 2026.

 EG203 — Finite Diagonal Witness Bound (substantive close target).

 Anchored to: ROUND-005 in-chat packet (2026-05-31) named the target.
 extension on this repo (M up to 1,000,000) measured
 D(M) ≈ ⌈log₃ M⌉ — see
 oracle/localruns/r23-eg203-coset-540/in-chat-rounds/
 ROUND-005-CLAUDE-EXTENSION/FINDINGS.md

 This file:
 • Restates EG203Closed.
 • Defines FiniteDiagonalWitnessBound D (substantive S-unit prime-production
 statement parameterized by an explicit diagonal bound).
 • Proves the reduction `FiniteDiagonalWitnessBound D → EG203Closed`
 (kernel-checkable, zero sorry/admit/axiom).

 EXPLICIT BOUNDARY: this is a substantive REDUCTION, not a proof of either
 the hypothesis or EG#203. The hypothesis `FiniteDiagonalWitnessBound D` is
 itself an open theorem; empirical evidence over m ≤ 10⁶ supports D(M) ≈
 ⌈log₃ M⌉ with a multiplicative constant around 0.65 vs log₂ M.

 Two attack routes for the hypothesis:
 (1) Bateman-Horn for the 2D S-unit family `m·2^k·3^l + 1` (conditional).
 (2) Filaseta-Mason-Stothers ruling out algebraic-exception m (Wave 4
 Rank 1 publishable climb, ~2 weeks).
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203

/-- The 2D S-unit value at (m, k, l). -/
def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/-- EG#203 closed: every ordinary m has SOME (k,l) with V m k l prime. -/
def EG203Closed : Prop :=
 ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, Nat.Prime (V m k l)

/-- Finite-diagonal witness bound: every ordinary m has a prime witness
 with k + l ≤ D. Substantive S-unit prime-production statement. -/
def FiniteDiagonalWitnessBound (D : Nat) : Prop :=
 ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, k + l ≤ D ∧ Nat.Prime (V m k l)

/-- Substantive reduction: a uniform finite-diagonal bound implies EG#203
 closure. Kernel-checkable, axiom-clean. -/
theorem closed_from_finite_diagonal_bound
 {D : Nat} (h : FiniteDiagonalWitnessBound D) : EG203Closed := by
 intro m hm
 rcases h m hm with ⟨k, l, _hkl, hp⟩
 exact ⟨k, l, hp⟩

/-- Diagonal-bound monotonicity: if FDWB holds at D, it holds at any D' ≥ D. -/
theorem fdwb_mono {D D' : Nat} (hle : D ≤ D')
 (h : FiniteDiagonalWitnessBound D) : FiniteDiagonalWitnessBound D' := by
 intro m hm
 rcases h m hm with ⟨k, l, hkl, hp⟩
 exact ⟨k, l, Nat.le_trans hkl hle, hp⟩

/-- M-dependent variant: bound depends on the size of m. Closer to the
 empirical conjecture `D(M) ≈ ⌈log₃ M⌉`. -/
def FiniteDiagonalWitnessBoundFun (F : Nat → Nat) : Prop :=
 ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, k + l ≤ F m ∧ Nat.Prime (V m k l)

/-- M-dependent variant also closes EG#203 — the function F can be unbounded
 as long as it's defined on every ordinary m. -/
theorem closed_from_fdwb_fun
 {F : Nat → Nat} (h : FiniteDiagonalWitnessBoundFun F) : EG203Closed := by
 intro m hm
 rcases h m hm with ⟨k, l, _hkl, hp⟩
 exact ⟨k, l, hp⟩

end EG203
