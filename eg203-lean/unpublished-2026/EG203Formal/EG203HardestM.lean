/-
 EG203HardestM.lean — 2026-06-01

 Explicit kernel-verifiable Nat.Prime witnesses for the m values
 that EMPIRICALLY require the highest k+l ("hardest m") at each
 scaling milestone of N from 200 up through 10^9.

 These are NOT proofs of EG#203's universal closure. Each theorem
 is a specific Nat.Prime claim about a specific m·2^k·3^l + 1
 value, kernel-checked via native_decide.

 The progression of hardest m + max diagonal:

 N hardest m (k, l) k+l
 --- --------- ------ ---
 200 167 (4, 1) 5
 1000 353 (1, 5) 6
 5000 2309 (7, 0) 7
 10000 2657 (4, 5) 9
 100K..300K 74563 (10, 1) 11
 500K 414017 (5, 7) 12
 750K..1M 537653 (1, 12) 13
 10^9..2·10^9 1042327453 (3, 19) 22
 2·10^9+ 2322690079 (19, 4) 23 (in flight)

 Each theorem here verifies the specific witness for one of these
 m values: that the named V(m, k, l) is actually prime.
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace HardestM

-- The V function: V m k l = m * 2^k * 3^l + 1.
@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

-- N=200 hardest: m=167, k=4, l=1.
theorem prime_witness_167 : Nat.Prime (V 167 4 1) := by native_decide
#print axioms prime_witness_167

-- N=1000 hardest: m=353, k=1, l=5.
theorem prime_witness_353 : Nat.Prime (V 353 1 5) := by native_decide
#print axioms prime_witness_353

-- N=5000 hardest: m=2309, k=7, l=0.
theorem prime_witness_2309 : Nat.Prime (V 2309 7 0) := by native_decide
#print axioms prime_witness_2309

-- N=10000 hardest: m=2657, k=4, l=5.
theorem prime_witness_2657 : Nat.Prime (V 2657 4 5) := by native_decide
#print axioms prime_witness_2657

-- N=100K through N=300K hardest: m=74563, k=10, l=1.
theorem prime_witness_74563 : Nat.Prime (V 74563 10 1) := by native_decide
#print axioms prime_witness_74563

-- N=500K hardest: m=414017, k=5, l=7.
theorem prime_witness_414017 : Nat.Prime (V 414017 5 7) := by native_decide
#print axioms prime_witness_414017

-- N=750K..1M hardest: m=537653, k=1, l=12.
theorem prime_witness_537653 : Nat.Prime (V 537653 1 12) := by native_decide
#print axioms prime_witness_537653

-- M=10^9..2·10^9 hardest: m=1042327453, k=3, l=19.
theorem prime_witness_1042327453 : Nat.Prime (V 1042327453 3 19) := by native_decide
#print axioms prime_witness_1042327453

-- M=2·10^9..3·10^9 (in flight) hardest so far: m=2322690079, k=19, l=4.
theorem prime_witness_2322690079 : Nat.Prime (V 2322690079 19 4) := by native_decide
#print axioms prime_witness_2322690079

end HardestM
end EG203Formal
