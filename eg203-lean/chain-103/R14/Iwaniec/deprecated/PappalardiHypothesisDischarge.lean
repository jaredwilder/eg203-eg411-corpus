import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.IwaniecAxiomTightened
import EG203Formal.R14.Iwaniec.PappalardiDischargeFinite

/-!
# P2.6 — Pappalardi hypothesis of TIGHTENED Iwaniec axiom is DISCHARGED

The tightened Iwaniec axiom has a hypothesis:
 (∀ q : ℕ, q.Prime → 5 ≤ q → q < z →
 (q - 1) / 2 ≤ (subgroup_2_3 q).card)

For our application with z = 23, this means we need the subgroup density
bound for q ∈ {5, 7, 11, 13, 17, 19}. ALL discharged in
PappalardiDischargeFinite.lean.

This file shows that the Pappalardi hypothesis is SATISFIED for our use
case with z = 23, providing a witness theorem.

NO MATHEMATICAL AXIOMS.
-/

namespace EG203R14IwaniecPappalardiHypothesisDischarge

open EG203R14IwaniecPappalardiDischargeFinite

/-- Pappalardi hypothesis of tightened Iwaniec, INSTANTIATED for z = 23.

 Asserts: for every prime q with 5 ≤ q < 23 (i.e., q ∈ {5,7,11,13,17,19}),
 the subgroup ⟨2, 3⟩ ≤ (ℤ/qℤ)* has order ≥ (q-1)/2.

 This is the κ=0 sieve dimension hypothesis. DISCHARGED via the
 per-prime `pappalardi_discharged_q*` theorems. -/
theorem pappalardi_hypothesis_for_z_23 :
 ∀ q : ℕ, q.Prime → 5 ≤ q → q < 23 →
 (q - 1) / 2 ≤ (subgroup_2_3 q).card := by
 intro q hq h5 h23
 -- q is prime and 5 ≤ q < 23, so q ∈ {5, 7, 11, 13, 17, 19}
 interval_cases q
 · exact pappalardi_discharged_q5
 · exact absurd hq (by decide) -- 6 not prime
 · exact pappalardi_discharged_q7
 · exact absurd hq (by decide) -- 8 not prime
 · exact absurd hq (by decide) -- 9 not prime
 · exact absurd hq (by decide) -- 10 not prime
 · exact pappalardi_discharged_q11
 · exact absurd hq (by decide) -- 12 not prime
 · exact pappalardi_discharged_q13
 · exact absurd hq (by decide) -- 14 not prime
 · exact absurd hq (by decide) -- 15 not prime
 · exact absurd hq (by decide) -- 16 not prime
 · exact pappalardi_discharged_q17
 · exact absurd hq (by decide) -- 18 not prime
 · exact pappalardi_discharged_q19
 · exact absurd hq (by decide) -- 20 not prime
 · exact absurd hq (by decide) -- 21 not prime
 · exact absurd hq (by decide) -- 22 not prime

end EG203R14IwaniecPappalardiHypothesisDischarge
