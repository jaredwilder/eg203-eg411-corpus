import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.SieveSet

/-!
# Buchstab identity — combinatorial partition for the linear sieve

P2.5 — kernel-verified Buchstab partition for `sievedCount`.

The Buchstab identity is the combinatorial backbone of every sieve:

 Φ(A, P, z₁) = Φ(A, P, z₂) + B(A, P, z₁, z₂)

where `B(A, P, z₁, z₂)` counts elements of `A` that have NO P-prime factor
below `z₁`, but DO have a P-prime factor in `[z₁, z₂)`.

This file proves the partition WITHOUT any analytic input — pure
`Finset.card_filter_add_card_filter_not` on a sharper predicate.

NO MATHEMATICAL AXIOMS. NO SORRIES.
-/

namespace EG203R14IwaniecBuchstabIdentity

open EG203R14IwaniecSieveSet

/-- The Buchstab "boundary stratum": elements of `A` that survive the
 `z₁`-sieve but get killed when we extend to `z₂`. Equivalently:
 elements with NO P-prime divisor `< z₁`, but SOME P-prime divisor
 in `[z₁, z₂)`. -/
def buchstabBoundary (A : Finset ℕ) (P : Finset ℕ) (z₁ z₂ : ℕ) : ℕ :=
 (A.filter (fun a =>
 (∀ p ∈ P, p < z₁ → ¬ (p ∣ a)) ∧
 (∃ p ∈ P, z₁ ≤ p ∧ p < z₂ ∧ p ∣ a))).card

/-- For `z₁ ≤ z₂`: the `z₁`-survivors are exactly the `z₂`-survivors PLUS
 the boundary stratum. This is a finite-cardinality identity, no analysis. -/
theorem buchstab_partition (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ : ℕ}
 (h : z₁ ≤ z₂) :
 sievedCount A P z₁ =
 sievedCount A P z₂ + buchstabBoundary A P z₁ z₂ := by
 classical
 -- Step 1: rewrite `Φ(A,P,z₁)` as the cardinality of a filter on `A`.
 -- The predicate "(no p < z₂ divides a)" PLUS its negation "(some p < z₂ divides a)"
 -- partitions the `z₁`-survivors.
 -- We use `card_filter_add_card_filter_not` on the SUB-FILTER:
 -- inside `A.filter (z₁-surviving)`, split by "z₂-surviving" vs not.
 set S₁ : Finset ℕ := A.filter (fun a => ∀ p ∈ P, p < z₁ → ¬ (p ∣ a)) with hS₁
 have hcard₁ : sievedCount A P z₁ = S₁.card := rfl
 rw [hcard₁]
 -- Define the predicate "all P-primes < z₂ avoid a" on S₁.
 -- The split: a ∈ S₁ is "z₂-survivor" OR has a P-prime in [z₁, z₂) dividing it.
 have hsplit :
 S₁.card =
 (S₁.filter (fun a => ∀ p ∈ P, p < z₂ → ¬ (p ∣ a))).card +
 (S₁.filter (fun a => ¬ (∀ p ∈ P, p < z₂ → ¬ (p ∣ a)))).card := by
 exact (Finset.card_filter_add_card_filter_not
 (s := S₁) (fun a => ∀ p ∈ P, p < z₂ → ¬ (p ∣ a))).symm
 rw [hsplit]
 congr 1
 · -- LHS first summand: S₁ filtered by (z₂-survivor) = A filtered by (z₂-survivor)
 -- because (z₂-survivor) ⇒ (z₁-survivor) when z₁ ≤ z₂.
 show (S₁.filter (fun a => ∀ p ∈ P, p < z₂ → ¬ (p ∣ a))).card =
 sievedCount A P z₂
 unfold sievedCount
 congr 1
 ext a
 simp only [hS₁, Finset.mem_filter]
 constructor
 · rintro ⟨⟨haA, _⟩, hz₂⟩
 exact ⟨haA, hz₂⟩
 · rintro ⟨haA, hz₂⟩
 refine ⟨⟨haA, ?_⟩, hz₂⟩
 intro p hp_in hp_lt
 exact hz₂ p hp_in (lt_of_lt_of_le hp_lt h)
 · -- RHS second summand: S₁ filtered by ¬(z₂-survivor) = boundary stratum.
 -- For a ∈ S₁ (i.e., no p < z₁ divides a), failing the z₂-survival
 -- means ∃ p ∈ P with p < z₂ AND p ∣ a; combined with z₁-survival
 -- such p must have z₁ ≤ p.
 show (S₁.filter (fun a => ¬ (∀ p ∈ P, p < z₂ → ¬ (p ∣ a)))).card =
 buchstabBoundary A P z₁ z₂
 unfold buchstabBoundary
 congr 1
 ext a
 simp only [hS₁, Finset.mem_filter, not_forall, not_not]
 constructor
 · rintro ⟨⟨haA, hz₁⟩, hex⟩
 refine ⟨haA, hz₁, ?_⟩
 -- hex : ∃ p, ∃ (_ : p ∈ P), ∃ (_ : p < z₂), p ∣ a
 obtain ⟨p, hp⟩ := hex
 -- hp : ∃ (_ : p ∈ P), ∃ (_ : p < z₂), p ∣ a
 rcases hp with ⟨hp_in, hp_lt_z₂, hp_div⟩
 refine ⟨p, hp_in, ?_, hp_lt_z₂, hp_div⟩
 -- Need z₁ ≤ p. Suppose p < z₁; then by z₁-survival ¬ (p ∣ a), contradiction.
 by_contra hlt
 exact hz₁ p hp_in (Nat.lt_of_not_le hlt) hp_div
 · rintro ⟨haA, hz₁, p, hp_in, hp_ge, hp_lt_z₂, hp_div⟩
 refine ⟨⟨haA, hz₁⟩, ?_⟩
 exact ⟨p, hp_in, hp_lt_z₂, hp_div⟩

/-- Corollary: the boundary stratum equals the "drop" in the sieved count. -/
theorem buchstab_boundary_eq_drop (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ : ℕ}
 (h : z₁ ≤ z₂) :
 buchstabBoundary A P z₁ z₂ = sievedCount A P z₁ - sievedCount A P z₂ := by
 have := buchstab_partition A P h
 omega

/-- Degenerate case: `z₁ = z₂` ⇒ boundary stratum is empty. -/
theorem buchstab_boundary_self (A : Finset ℕ) (P : Finset ℕ) (z : ℕ) :
 buchstabBoundary A P z z = 0 := by
 unfold buchstabBoundary
 rw [Finset.card_eq_zero]
 apply Finset.filter_eq_empty_iff.mpr
 rintro a _ ⟨_, p, _, hpge, hplt, _⟩
 omega

/-- Monotonicity check: extending `z₂` upward only ADDS to the boundary. -/
theorem buchstab_partition_mono (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ : ℕ}
 (h : z₁ ≤ z₂) :
 sievedCount A P z₂ ≤ sievedCount A P z₁ := by
 rw [buchstab_partition A P h]
 exact Nat.le_add_right _ _

end EG203R14IwaniecBuchstabIdentity
