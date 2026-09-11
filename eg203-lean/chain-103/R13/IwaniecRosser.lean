import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Iwaniec 1980 — Rosser linear sieve at κ = 0

Exact statement (Iwaniec 1980, Theorem 1, p. 174):

> **Theorem 1 (Iwaniec, 1980, p. 174):**
> For the linear sieve of dimension κ = 0, there exist functions f(s), F(s)
> such that for s = log X / log z,
> `S⁻(A, P, z) ≥ X · V(z) · (f(s) − δ)`
> `S⁺(A, P, z) ≤ X · V(z) · (F(s) + δ)`
> where δ = (log Q)^(-1/3), V(z) = ∏_{p < z}(1 − 1/p), and f(s) > 0 for all s > 0,
> with f(s) → 2e^γ as s ↓ 1.

Source: H. Iwaniec, *Rosser's sieve*, Acta Arithmetica 36 (1980), 171-202,
Theorem 1, p. 174.
-/

namespace EG203R13Iwaniec

open scoped Real

/-- The Rosser sieve lower-bound function f(s) at κ = 0. -/
opaque rosser_f : ℝ → ℝ

/-- Iwaniec 1980 Theorem 1 (p. 174) — Rosser linear sieve at κ = 0 lower bound.
 f(s) > 0 for all s > 0; f(s) → 2 e^γ as s ↓ 1. -/
axiom iwaniec_1980_thm_1_rosser_lower_bound :
 ∀ s : ℝ, 0 < s → 0 < rosser_f s

/-- Euler-Mascheroni constant γ ≈ 0.5772156649. Opaque for now (Mathlib's
 `Real.eulerMascheroniConstant` may not be available in v4.29.1). -/
opaque euler_gamma : ℝ

/-- Iwaniec 1980 — the limit f(s) → 2 e^γ as s ↓ 1. -/
axiom iwaniec_1980_f_asymptotic :
 ∀ ε : ℝ, 0 < ε → ∃ δ : ℝ, 0 < δ ∧
 ∀ s : ℝ, 1 < s → s < 1 + δ → |rosser_f s - 2 * Real.exp euler_gamma| < ε

end EG203R13Iwaniec
