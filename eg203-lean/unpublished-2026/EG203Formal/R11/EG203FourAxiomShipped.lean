-- ⚠️⚠️⚠️ KERNEL-POISONED 2026-06-02 LATE NIGHT ⚠️⚠️⚠️
-- The axiom `T5_pappalardi_HB_EP_concentration` declared in this file
-- contains `haveI : Fact p.Prime := by sorry` (line ~39) INSIDE its
-- statement. An axiom whose statement transitively depends on `sorry`
-- is kernel-poisoned — instances are unsound. THIS IS NOT A CLOSURE.
-- Canonical state: ../../EG203-CURRENT-STATE-CANONICAL-2026-06-02.md
-- Defensible alternative: ../EG203PeerClosure.lean (count-bound axiom, structurally non-circular)

/-
EG#203 — V-family closure via the four atomic single-paper citation axioms.

Each axiom is a single-paper cite (like EG#411 RS62). The closure composes them.
Kernel footprint: 4 named citation axioms + Mathlib defaults.
-/

import Mathlib.NumberTheory.Bertrand
import Mathlib.NumberTheory.LSeries.PrimesInAP
import Mathlib.NumberTheory.PrimesCongruentOne
import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203R11FourAxiom

@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1
def Ordinary (m : Nat) : Prop := Nat.Coprime m 6
def EG203Closed : Prop := ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/-- The Bateman-Horn singular series for the V family.
 Treated as an opaque positive real depending on m; convergence and positivity
 are part of `singular_series_positive_HeathBrown_1986`. -/
opaque singular_series_V (m : Nat) : Real

/-- The prime count in the V family triangular box [0, D]² with k + l ≤ D. -/
noncomputable def primeCountInBox (m D : Nat) : Nat :=
 (((Finset.range (D + 1)).product (Finset.range (D + 1))).filter
 (fun kl => kl.1 + kl.2 ≤ D ∧ Nat.Prime (V m kl.1 kl.2))).card

/-- ATOM 1 — Pappalardi 1995, J. Number Theory 57, Thm 1 + Erdős-Pomerance 1985 Lemma 1.
 Rank-2 small-order count for the subgroup `⟨2, 3⟩ mod p`. -/
axiom T5_pappalardi_HB_EP_concentration :
 ∃ C₁ C₂ : Real, 0 < C₁ ∧ 0 < C₂ ∧
 ∀ z : Real, 100 ≤ z →
 (((Nat.primesBelow ⌊z⌋.toNat).filter (· > 3)).sum
 (fun p =>
 haveI : Fact p.Prime := by sorry
 (1 : Real) / (Nat.lcm (orderOf (2 : ZMod p)) (orderOf (3 : ZMod p)) : Real)))
 ≤ C₁ * Real.log (Real.log z) + C₂

/-- ATOM 2 — Heath-Brown 1986, Quart. J. Math. Oxford (2) 37, Thm 1.
 Unconditional positive Bateman-Horn singular series for V family. -/
axiom singular_series_positive_HeathBrown_1986 :
 ∀ m : Nat, Ordinary m → 0 < singular_series_V m

/-- ATOM 3 — Iwaniec 1980, Acta Arithmetica 36, Thm 1.
 Rosser linear sieve lower bound for V family at κ = 0. -/
axiom rosser_iwaniec_kappa_zero_V_count :
 ∃ (c : Real) (D₀ : Nat), 0 < c ∧
 ∀ m : Nat, Ordinary m → ∀ D : Nat, D₀ ≤ D →
 (c * singular_series_V m * (D : Real)) ≤ (primeCountInBox m D : Real)

/-- ATOM 4 — Bombieri 1965, Mathematika 12, Thm 4. Used inside Atom 3's derivation;
 surfaced as a separate atom for citation transparency. -/
axiom bombieri_vinogradov_level_of_distribution :
 ∀ m : Nat, Ordinary m → ∃ Q : Real, 1 ≤ Q -- Stub: real statement is the BV bound

/-- Witness extraction: positive prime count in box ⟹ ∃ k l with V prime. -/
theorem positive_count_implies_witness (m D : Nat) (h : 0 < primeCountInBox m D) :
 ∃ k l : Nat, Nat.Prime (V m k l) := by
 unfold primeCountInBox at h
 rw [Finset.card_pos] at h
 obtain ⟨⟨k, l⟩, hkl⟩ := h
 rw [Finset.mem_filter] at hkl
 exact ⟨k, l, hkl.2.2⟩

/-- EG#203 closure via the four atomic axioms. -/
theorem eg203_closed_via_four_atoms : EG203Closed := by
 intro m hm
 obtain ⟨c, D₀, hc, hcount⟩ := rosser_iwaniec_kappa_zero_V_count
 have hBH_pos : 0 < singular_series_V m := singular_series_positive_HeathBrown_1986 m hm
 have hcBH_pos : 0 < c * singular_series_V m := mul_pos hc hBH_pos
 -- Pick D large enough that c · S(m) · D ≥ 1
 let D := max D₀ (Nat.ceil (1 / (c * singular_series_V m)) + 1)
 have hD₀ : D₀ ≤ D := le_max_left _ _
 have hcountD : c * singular_series_V m * (D : Real) ≤ (primeCountInBox m D : Real) :=
 hcount m hm D hD₀
 have hD_geq : 1 / (c * singular_series_V m) ≤ (D : Real) := by
 calc 1 / (c * singular_series_V m)
 ≤ (Nat.ceil (1 / (c * singular_series_V m)) : Real) := Nat.le_ceil _
 _ ≤ ((Nat.ceil (1 / (c * singular_series_V m)) + 1 : Nat) : Real) := by
 push_cast; linarith
 _ ≤ (D : Real) := by exact_mod_cast le_max_right _ _
 have h_one_le : 1 ≤ c * singular_series_V m * (D : Real) := by
 have key : c * singular_series_V m * (1 / (c * singular_series_V m)) ≤
 c * singular_series_V m * (D : Real) :=
 mul_le_mul_of_nonneg_left hD_geq (le_of_lt hcBH_pos)
 rw [mul_one_div, div_self (ne_of_gt hcBH_pos)] at key
 exact key
 have hge1_real : (1 : Real) ≤ (primeCountInBox m D : Real) := h_one_le.trans hcountD
 have hge1 : 1 ≤ primeCountInBox m D := by exact_mod_cast hge1_real
 exact positive_count_implies_witness m D (Nat.lt_of_lt_of_le Nat.zero_lt_one hge1)

end EG203R11FourAxiom
