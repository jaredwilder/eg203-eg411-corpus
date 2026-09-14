import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Range
import Mathlib.Data.Finset.Prod

open Finset

namespace OracleCRT

def residueProducts95 : Finset Nat :=
  ((range 36) ×ˢ (range 36)).image (fun pair => (2 ^ pair.1 * 3 ^ pair.2) % 95)

def residuePowers5 : Finset Nat :=
  (range 4).image (fun exponent => (2 ^ exponent) % 5)

def residuePowers19 : Finset Nat :=
  (range 18).image (fun exponent => (2 ^ exponent) % 19)

set_option maxRecDepth 100000 in
theorem residue_products_95_card : residueProducts95.card = 36 := by decide

theorem powers_2_mod_5_card : residuePowers5.card = 4 := by decide

theorem powers_2_mod_19_card : residuePowers19.card = 18 := by decide

set_option maxRecDepth 100000 in
theorem local_full_global_defect_95 :
    residuePowers5.card = 4 ∧
    residuePowers19.card = 18 ∧
    residueProducts95.card = 36 ∧
    36 < 4 * 18 := by decide

#print axioms residue_products_95_card
#print axioms local_full_global_defect_95

end OracleCRT
