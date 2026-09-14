import Mathlib.GroupTheory.OrderOfElement
import Mathlib.GroupTheory.Sylow
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203R12Chain103

/-- The cardinality of cells (k, l) ∈ [0, 2520) × [0, 5040) with k % 8 = 0
 and l % 16 = 0 is 99225 (= 315 × 315). Provable by native_decide. -/
theorem chain_103_cell_count :
 (((Finset.range 2520).product (Finset.range 5040)).filter
 (fun kl => kl.1 % 8 = 0 ∧ kl.2 % 16 = 0)).card = 99225 := by
 native_decide

/-- The product of the first seven odd primes. -/
def odd_prime_product : Nat := 3 * 5 * 7 * 11 * 13 * 17 * 19

theorem odd_prime_product_eq : odd_prime_product = 4849845 := by
 unfold odd_prime_product
 native_decide

end EG203R12Chain103
