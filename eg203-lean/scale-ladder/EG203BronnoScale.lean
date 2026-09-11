/-
 EG203BronnoScale.lean — 2026-06-01

 ONE prime witness at 10^19 scale m (20-digit m).
 V = 20-digit prime — pushing the practical native_decide envelope.

 Python-verified BEFORE commit (sympy.isprime).
 Expected native_decide time: 5-10 min for 20-digit primality.
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace BronnoScale

@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

theorem prime_witness_10000000052894468093 :
 Nat.Prime (V 10000000052894468093 1 0) := by native_decide
#print axioms prime_witness_10000000052894468093

end BronnoScale
end EG203Formal
