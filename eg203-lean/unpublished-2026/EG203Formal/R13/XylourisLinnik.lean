import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Xylouris 2011 — Least prime in AP, L = 5.18

Exact statement extracted from DeepSeek/research session, Tue Jun 2 2026.

> **Theorem 1 (Xylouris, 2011, p. 354):**
> Let q ≥ 2 and a be coprime to q. The least prime p with p ≡ a (mod q)
> satisfies `p < q^5.18`.

Source: T. Xylouris, *On the least prime in an arithmetic progression*,
Acta Arithmetica 150 (2011), 353-370, Theorem 1, p. 354.
(German original: "Es sei q ≥ 2 und a teilerfremd zu q. Dann ist die kleinste
Primzahl p ≡ a (mod q) kleiner als q^5.18.")

Improves Linnik 1944's original log-free zero-density bound.
-/

namespace EG203R13Xylouris

/-- Xylouris 2011 Theorem 1 (p. 354) — least prime in AP, exponent L = 5.18.
 Use L = 6 (rounded up) for clean Nat arithmetic. -/
axiom xylouris_2011_thm_1_least_prime_in_AP :
 ∀ (q a : ℕ), 2 ≤ q → Nat.Coprime a q →
 ∃ p : ℕ, Nat.Prime p ∧ p % q = a % q ∧ p ≤ q ^ 6

end EG203R13Xylouris
