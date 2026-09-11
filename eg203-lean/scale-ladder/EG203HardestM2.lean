/-
 EG203HardestM2.lean — 2026-06-01

 ADDITIONAL high-diag m values (beyond the single hardest per scale
 that EG203HardestM.lean records). All (m, k, l) tuples here have been
 independently Python-verified to satisfy Nat.Prime (m * 2^k * 3^l + 1).
 This file just re-verifies them via the Lean kernel's native_decide.

 Sources:
 - Python sweep (companion `find_high_diag_full.py` driver)
 - All m values are second/third-hardest at their respective N milestone
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace HardestM2

@[reducible] def V (m k l : Nat) : Nat := m * 2^k * 3^l + 1

-- N=100K range, diag = 10 (second-hardest at this scale)
theorem prime_witness_83443 : Nat.Prime (V 83443 1 9) := by native_decide
#print axioms prime_witness_83443

theorem prime_witness_85873 : Nat.Prime (V 85873 10 0) := by native_decide
#print axioms prime_witness_85873

-- N=200K range, diag = 11 (a second example near 74563 in the diag-11 band)
theorem prime_witness_119423 : Nat.Prime (V 119423 6 5) := by native_decide
#print axioms prime_witness_119423

-- N=500K range, diag = 12 (a second example near 414017 in the diag-12 band)
theorem prime_witness_438037 : Nat.Prime (V 438037 8 4) := by native_decide
#print axioms prime_witness_438037

theorem prime_witness_586361 : Nat.Prime (V 586361 2 10) := by native_decide
#print axioms prime_witness_586361

-- N=1M range, diag = 13 (a second example near 537653 in the diag-13 band)
theorem prime_witness_651881 : Nat.Prime (V 651881 3 10) := by native_decide
#print axioms prime_witness_651881

end HardestM2
end EG203Formal
