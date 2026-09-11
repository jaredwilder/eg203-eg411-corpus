/-
 EG203TeraScale.lean — 2026-06-01

 Prime witnesses at 10^15 scale (m has 16 digits). The resulting
 V = m * 2^k * 3^l + 1 has 17 digits, putting it at the upper end
 of practical native_decide primality.

 Each (m, k, l) was Python-verified via sympy.isprime BEFORE commit.
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace TeraScale

@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

-- 10^15 scale, k+l small (V = 17-digit prime)
theorem prime_witness_1000000000419611 :
 Nat.Prime (V 1000000000419611 2 1) := by native_decide
#print axioms prime_witness_1000000000419611

theorem prime_witness_1000000003744855 :
 Nat.Prime (V 1000000003744855 3 2) := by native_decide
#print axioms prime_witness_1000000003744855

end TeraScale
end EG203Formal
