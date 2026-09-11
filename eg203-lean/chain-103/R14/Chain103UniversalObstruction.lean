import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Chain103FullLatticeBound

/-!
# Chain 103 universal obstruction bound — UNIVERSAL in m

P0.3 — extend per-residue full-lattice bounds (P0.2) to ALL m ≥ 0 via:
 obstr_full_q q m = obstr_full_q q (m mod q)

NO MATHEMATICAL AXIOMS.
-/

set_option maxRecDepth 4000

namespace EG203R14Chain103UniversalObstruction

open EG203R14Chain103FullLatticeBound

/-- For any positive q, the obstruction count for V(m, k, l) mod q
 depends only on m mod q. -/
theorem obstr_full_q_eq_mod (q m : ℕ) (hq : 0 < q) :
 obstr_full_q q m = obstr_full_q q (m % q) := by
 unfold obstr_full_q
 congr 1
 apply Finset.filter_congr
 intro kl _
 unfold V
 constructor
 · intro h
 have h_mod : m ≡ m % q [MOD q] := (Nat.mod_modEq m q).symm
 have h_eq : m * 2^kl.1 * 3^kl.2 + 1 ≡ (m % q) * 2^kl.1 * 3^kl.2 + 1 [MOD q] := by
 apply Nat.ModEq.add_right 1
 apply Nat.ModEq.mul_right
 apply Nat.ModEq.mul_right
 exact h_mod
 exact (Nat.modEq_zero_iff_dvd).mp
 (h_eq.symm.trans ((Nat.modEq_zero_iff_dvd).mpr h))
 · intro h
 have h_mod : m % q ≡ m [MOD q] := Nat.mod_modEq m q
 have h_eq : (m % q) * 2^kl.1 * 3^kl.2 + 1 ≡ m * 2^kl.1 * 3^kl.2 + 1 [MOD q] := by
 apply Nat.ModEq.add_right 1
 apply Nat.ModEq.mul_right
 apply Nat.ModEq.mul_right
 exact h_mod
 exact (Nat.modEq_zero_iff_dvd).mp
 (h_eq.symm.trans ((Nat.modEq_zero_iff_dvd).mpr h))

/-- Universal bound for q=5: obstr_full_q 5 m ≤ 64800 for ALL m. -/
theorem obstr_full_q5_universal (m : ℕ) : obstr_full_q 5 m ≤ 64800 := by
 rw [obstr_full_q_eq_mod 5 m (by norm_num : (0:ℕ) < 5)]
 apply obstr_full_q5_residue_le_64800
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 5)

theorem obstr_full_q7_universal (m : ℕ) : obstr_full_q 7 m ≤ 43200 := by
 rw [obstr_full_q_eq_mod 7 m (by norm_num : (0:ℕ) < 7)]
 apply obstr_full_q7_residue_le_43200
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 7)

theorem obstr_full_q11_universal (m : ℕ) : obstr_full_q 11 m ≤ 25920 := by
 rw [obstr_full_q_eq_mod 11 m (by norm_num : (0:ℕ) < 11)]
 apply obstr_full_q11_residue_le_25920
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 11)

theorem obstr_full_q13_universal (m : ℕ) : obstr_full_q 13 m ≤ 21600 := by
 rw [obstr_full_q_eq_mod 13 m (by norm_num : (0:ℕ) < 13)]
 apply obstr_full_q13_residue_le_21600
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 13)

theorem obstr_full_q17_universal (m : ℕ) : obstr_full_q 17 m ≤ 16200 := by
 rw [obstr_full_q_eq_mod 17 m (by norm_num : (0:ℕ) < 17)]
 apply obstr_full_q17_residue_le_16200
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 17)

theorem obstr_full_q19_universal (m : ℕ) : obstr_full_q 19 m ≤ 14400 := by
 rw [obstr_full_q_eq_mod 19 m (by norm_num : (0:ℕ) < 19)]
 apply obstr_full_q19_residue_le_14400
 exact Nat.mod_lt m (by norm_num : (0:ℕ) < 19)

end EG203R14Chain103UniversalObstruction
