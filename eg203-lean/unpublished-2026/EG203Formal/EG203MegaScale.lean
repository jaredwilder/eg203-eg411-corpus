/-
 EG203MegaScale.lean — 2026-06-01

 Kernel-verified Nat.Prime witnesses for ordinary m values at the
 10^10, 10^11, and 10^12 scales. Each (m, k, l) was Python-verified
 via sympy.isprime BEFORE being committed here; this file then
 re-verifies them via the Lean kernel's native_decide.

 Source: oracle/localruns/r23-eg203-coset-540/kernel/find_megascale_witnesses.py
 (random sampling with fixed seed 42 over m ∈ [scale, scale + 10^7])
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace MegaScale

@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

-- 10^10 scale (each is an 11-digit m)
theorem prime_witness_10000419611 : Nat.Prime (V 10000419611 1 0) := by native_decide
#print axioms prime_witness_10000419611

theorem prime_witness_10003744855 : Nat.Prime (V 10003744855 1 2) := by native_decide
#print axioms prime_witness_10003744855

theorem prime_witness_10009149733 : Nat.Prime (V 10009149733 3 3) := by native_decide
#print axioms prime_witness_10009149733

-- 10^11 scale
theorem prime_witness_100000499915 : Nat.Prime (V 100000499915 2 1) := by native_decide
#print axioms prime_witness_100000499915

theorem prime_witness_100003668137 : Nat.Prime (V 100003668137 7 0) := by native_decide
#print axioms prime_witness_100003668137

-- 10^12 scale (each is a 13-digit m)
theorem prime_witness_1000003903403 : Nat.Prime (V 1000003903403 4 4) := by native_decide
#print axioms prime_witness_1000003903403

theorem prime_witness_1000003335943 : Nat.Prime (V 1000003335943 5 1) := by native_decide
#print axioms prime_witness_1000003335943

end MegaScale
end EG203Formal
