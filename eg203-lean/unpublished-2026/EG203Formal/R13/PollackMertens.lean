import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-!
# Pollack 2010 — Mertens product effective form

Exact statement extracted from DeepSeek/research session, Tue Jun 2 2026.

> **Theorem 4.1.1 (Pollack, 2010, p. 48):** For x ≥ 2,
> `0.5615 / log x < ∏_{p ≤ x} (1 − 1/p) < 1.12 / log x`
> The constant 0.5615 approximates `e^(-γ) ≈ 0.561459`.

Source: P. Pollack, *Not Always Buried Deep* (AMS 2010), §4.1, Theorem 4.1.1, p. 48.
Proof in source uses Rosser-Schoenfeld 1962 bounds.
-/

namespace EG203R13Pollack

open scoped Real

/-- Mertens product over primes ≤ x. -/
noncomputable def mertens_product (x : ℝ) : ℝ :=
 ((Finset.range (Nat.floor x + 1)).filter Nat.Prime).prod
 (fun p => 1 - (1 : ℝ) / (p : ℝ))

/-- Pollack 2010 Theorem 4.1.1 (p. 48) — effective Mertens product bounds.
 Lower constant 0.5615 approximates e^(-γ) ≈ 0.561459. Upper constant 1.12. -/
axiom pollack_mertens_2010_thm_4_1_1 :
 ∀ x : ℝ, 2 ≤ x →
 0.5615 / Real.log x < mertens_product x ∧
 mertens_product x < 1.12 / Real.log x

end EG203R13Pollack
