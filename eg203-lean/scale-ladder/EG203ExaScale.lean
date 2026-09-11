/-
 EG203ExaScale.lean — 2026-06-01

 Prime witnesses at 10^16 scale m. The V values are 17-18 digits,
 putting them at the upper edge of practical native_decide primality
 testing (native_decide does trial division up to sqrt V).

 Each (m, k, l) Python-verified by sympy.isprime before commit.

 Source: find_16scale.py
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace ExaScale

@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

-- 10^16 scale, low diag (small V to keep build manageable)
theorem prime_witness_10000000031227217 :
 Nat.Prime (V 10000000031227217 1 1) := by native_decide
#print axioms prime_witness_10000000031227217

theorem prime_witness_10000000080801587 :
 Nat.Prime (V 10000000080801587 1 1) := by native_decide
#print axioms prime_witness_10000000080801587

-- A larger V (18-digit) to push the corpus max
theorem prime_witness_10000000003356887 :
 Nat.Prime (V 10000000003356887 3 1) := by native_decide
#print axioms prime_witness_10000000003356887

end ExaScale
end EG203Formal
