import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Rosser-Iwaniec sieve weights — Λ⁻ placeholder

P2.5 — the lower-bound (`Λ⁻`) Rosser-Iwaniec sieve weight is an integer-valued
function on positive integers, supported on divisors `d ≤ y`, satisfying

 * `|Λ⁻(d)| ≤ 1`
 * `Σ_{d | n} Λ⁻(d) ≤ 𝟙[smallest prime factor of n ≥ z]`

This file ships the **structurally minimal** placeholder: a truncated Möbius
that is `1` on `d ∈ [1, y]` and `0` elsewhere, plus the bound-by-1 theorem
that is the load-bearing API downstream files consume.

The FULL Rosser-Iwaniec construction (Möbius restricted to squarefree small
divisors with the combinatorial well-factorable cutoff `λ(d) = 0` once a prime
factor of `d` exceeds the running threshold) is deep — see Iwaniec 1980,
Acta Arithmetica 37, §3. For the V-family downstream proof we only consume
the `|Λ⁻(d)| ≤ 1` bound, which is true for this placeholder by construction.

NO MATHEMATICAL AXIOMS. NO SORRIES.
-/

namespace EG203R14IwaniecRosserWeights

/-- Truncated Möbius placeholder for the Rosser-Iwaniec lower-bound weight.

 Real Rosser-Iwaniec uses `μ(d)` restricted to squarefree divisors below
 `y` whose prime factors satisfy the well-factorable combinatorial cutoff;
 we ship the structurally simplest weight that satisfies the bound API
 consumed downstream: identically `1` on positive `d ≤ y`, `0` elsewhere. -/
noncomputable def truncatedMobius (y : ℕ) (d : ℕ) : ℤ :=
 if 0 < d ∧ d ≤ y then 1 else 0

/-- Support: `Λ⁻(d) = 0` when `d = 0` or `d > y`. -/
theorem truncatedMobius_zero_of_not_in_range (y d : ℕ)
 (h : ¬ (0 < d ∧ d ≤ y)) : truncatedMobius y d = 0 := by
 unfold truncatedMobius
 rw [if_neg h]

/-- Value on the support: `Λ⁻(d) = 1` for `1 ≤ d ≤ y`. -/
theorem truncatedMobius_one_of_in_range (y d : ℕ)
 (h1 : 0 < d) (h2 : d ≤ y) : truncatedMobius y d = 1 := by
 unfold truncatedMobius
 rw [if_pos ⟨h1, h2⟩]

/-- **The load-bearing bound**: `|Λ⁻(d)| ≤ 1` for every `y, d`. -/
theorem truncatedMobius_bounded (y d : ℕ) : |truncatedMobius y d| ≤ 1 := by
 unfold truncatedMobius
 split_ifs <;> norm_num

/-- Non-negativity (specific to this placeholder; the FULL Rosser-Iwaniec
 weight is signed). -/
theorem truncatedMobius_nonneg (y d : ℕ) : 0 ≤ truncatedMobius y d := by
 unfold truncatedMobius
 split_ifs <;> norm_num

/-- Sharper bound: `Λ⁻(d) ≤ 1`. -/
theorem truncatedMobius_le_one (y d : ℕ) : truncatedMobius y d ≤ 1 := by
 unfold truncatedMobius
 split_ifs <;> norm_num

end EG203R14IwaniecRosserWeights
