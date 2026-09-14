import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.IntervalCases
import Mathlib.Tactic.NormNum

/-!
# Exact refutation of the current L1 Pappalardi experiment

The experiment in `forge_brain/constants/forge_pappalardi_fit.py` includes the slice
`k = l = 0` while allowing `m` to range across a complete residue system.  On that slice
`V(m,0,0) = m + 1`, a translation of `ZMod p`, so the measured generator set is already
all residue classes.  This theorem is deliberately about the experiment's representation;
it is not a statement of Pappalardi's index-distribution theorem.
-/

namespace WinEngine.PappalardiExperiment

/-- The `k = l = 0` slice used by the current experiment is surjective modulo every `p`. -/
theorem zeroExponentSlice_surjective (p : ℕ) :
    Function.Surjective (fun m : ZMod p => m * (2 : ZMod p) ^ 0 * (3 : ZMod p) ^ 0 + 1) := by
  intro residue
  refine ⟨residue - 1, ?_⟩
  simp

/-- Consequently, adding other exponent slices cannot make the represented residue set smaller. -/
theorem zeroExponentSlice_covers (p : ℕ) (residue : ZMod p) :
    ∃ m : ZMod p, m * (2 : ZMod p) ^ 0 * (3 : ZMod p) ^ 0 + 1 = residue :=
  zeroExponentSlice_surjective p residue

/-! The corrected fixed-subgroup census also found an exact boundary object.  It refutes
the tempting universal strengthening `|⟨2,3⟩ mod p| ≥ p^(2/3)`; Pappalardi's actual theorem
is an almost-all-primes statement, so this is a boundary certificate rather than a refutation
of Pappalardi. -/

theorem prime_6553 : Nat.Prime 6553 := by native_decide

theorem orderOf_two_mod_6553 : orderOf (2 : ZMod 6553) = 117 := by
  apply (orderOf_eq_iff (x := (2 : ZMod 6553)) (by norm_num)).2
  constructor
  · native_decide
  · intro m hm hm0
    interval_cases m <;> native_decide

theorem orderOf_three_mod_6553 : orderOf (3 : ZMod 6553) = 39 := by
  apply (orderOf_eq_iff (x := (3 : ZMod 6553)) (by norm_num)).2
  constructor
  · native_decide
  · intro m hm hm0
    interval_cases m <;> native_decide

theorem gamma_order_6553 :
    Nat.lcm (orderOf (2 : ZMod 6553)) (orderOf (3 : ZMod 6553)) = 117 := by
  rw [orderOf_two_mod_6553, orderOf_three_mod_6553]
  native_decide

theorem gamma_6553_below_twoThirdsFloor : 117 ^ 3 < 6553 ^ 2 := by norm_num

end WinEngine.PappalardiExperiment
