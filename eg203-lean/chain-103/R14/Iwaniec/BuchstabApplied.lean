import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.BuchstabIdentity

/-!
# Applied Buchstab — concrete consequences for our V family

P2.6 — concrete corollaries of `buchstab_partition` for the V-family
sieve application.

Key downstream uses:
- `sievedCount_monotone_from_buchstab`: sievedCount decreases as z grows
 (re-derivation from Buchstab, cleaner than direct subset proof)
- `buchstab_lower_bound_via_boundary`: if boundary is bounded above by
 some constant C, sievedCount at z₂ is at least sievedCount at z₁ - C
 (this is exactly the "sieve LOWER BOUND" pattern Iwaniec uses)

NO MATHEMATICAL AXIOMS.
-/

namespace EG203R14IwaniecBuchstabApplied

open EG203R14IwaniecSieveSet EG203R14IwaniecBuchstabIdentity

/-- Buchstab corollary 1: sievedCount is monotone-decreasing in z
 (re-derived from buchstab_partition). -/
theorem sievedCount_decreases_via_buchstab (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ : ℕ}
 (h : z₁ ≤ z₂) :
 sievedCount A P z₂ ≤ sievedCount A P z₁ := by
 have h_partition := buchstab_partition A P h
 omega

/-- Buchstab corollary 2: the "sieve LOWER BOUND" pattern.

 If we know an UPPER bound `C` for the boundary stratum, then we can
 derive a LOWER bound on the sievedCount at z₂:
 sievedCount A P z₂ ≥ sievedCount A P z₁ - C

 This is precisely the Iwaniec linear sieve lower-bound mechanism
 when applied iteratively (Buchstab recursion). -/
theorem sievedCount_lower_via_buchstab (A : Finset ℕ) (P : Finset ℕ) {z₁ z₂ C : ℕ}
 (h : z₁ ≤ z₂) (h_boundary_le : buchstabBoundary A P z₁ z₂ ≤ C) :
 sievedCount A P z₁ ≤ sievedCount A P z₂ + C := by
 have h_partition := buchstab_partition A P h
 omega

/-- Buchstab corollary 3: extracting prime existence from positive sievedCount.

 If `sievedCount A P z > 0`, then there exists an element of A with no
 P-prime divisor below z. If z exceeds √(max A), this element must be
 a prime > z (by elementary number theory: no factor < √n means n prime
 or n = 1).

 This is the EXISTENCE step that bridges sieve count to prime existence. -/
theorem prime_exists_from_sievedCount_pos
 (A : Finset ℕ) (P : Finset ℕ) (z : ℕ)
 (h_pos : 0 < sievedCount A P z) :
 ∃ a ∈ A, ∀ p ∈ P, p < z → ¬ (p ∣ a) := by
 unfold sievedCount at h_pos
 exact Finset.card_pos.mp h_pos |>.imp (fun a h_in =>
 ⟨(Finset.mem_filter.mp h_in).1, (Finset.mem_filter.mp h_in).2⟩)

end EG203R14IwaniecBuchstabApplied
