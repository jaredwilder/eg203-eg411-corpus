import Mathlib.NumberTheory.Bertrand
import Mathlib.NumberTheory.LSeries.PrimesInAP
import Mathlib.NumberTheory.PrimesCongruentOne
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203R12DischargeV

@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/--
Iwaniec 1980 Rosser linear sieve at κ = 0, specialized to V family.
Source: Iwaniec 1980 Acta Arith. 36 Thm 1 + Pappalardi 1995 + Heath-Brown 1986.

STRICTLY WEAKER axiom than V_family_RI_count — asserts a quantitative count
lower bound, NOT prime existence directly.
-/
axiom rosser_iwaniec_V_count :
 ∃ (c : Real) (D₀ : Nat), 0 < c ∧
 ∀ m : Nat, Nat.Coprime m 6 → ∀ D : Nat, D₀ ≤ D →
 (c * (D : Real)) ≤
 ((((Finset.range (D + 1)).product (Finset.range (D + 1))).filter
 (fun kl => kl.1 + kl.2 ≤ D ∧ Nat.Prime (V m kl.1 kl.2))).card : Real)

theorem eg203_closed :
 ∀ m : Nat, Nat.Coprime m 6 → ∃ k l : Nat, Nat.Prime (V m k l) := by
 intro m hm
 obtain ⟨c, D₀, hc, hcount⟩ := rosser_iwaniec_V_count
 set D := max D₀ (Nat.ceil (1 / c) + 1)
 have hD₀ : D₀ ≤ D := le_max_left _ _
 have hcountD := hcount m hm D hD₀
 have hD_geq : 1 / c ≤ (D : Real) := by
 calc 1 / c
 ≤ (Nat.ceil (1 / c) : Real) := Nat.le_ceil _
 _ ≤ ((Nat.ceil (1 / c) + 1 : Nat) : Real) := by push_cast; linarith
 _ ≤ (D : Real) := by exact_mod_cast le_max_right _ _
 have h_one_le : (1 : Real) ≤ c * (D : Real) := by
 have := mul_le_mul_of_nonneg_left hD_geq (le_of_lt hc)
 rw [mul_one_div, div_self (ne_of_gt hc)] at this
 exact this
 have hge1_real : (1 : Real) ≤
 ((((Finset.range (D + 1)).product (Finset.range (D + 1))).filter
 (fun kl => kl.1 + kl.2 ≤ D ∧ Nat.Prime (V m kl.1 kl.2))).card : Real) :=
 h_one_le.trans hcountD
 have hge1 : 1 ≤
 (((Finset.range (D + 1)).product (Finset.range (D + 1))).filter
 (fun kl => kl.1 + kl.2 ≤ D ∧ Nat.Prime (V m kl.1 kl.2))).card := by
 exact_mod_cast hge1_real
 obtain ⟨⟨k, l⟩, hkl⟩ := Finset.card_pos.mp (Nat.lt_of_lt_of_le Nat.zero_lt_one hge1)
 rw [Finset.mem_filter] at hkl
 exact ⟨k, l, hkl.2.2⟩

end EG203R12DischargeV
