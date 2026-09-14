import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# EG203 Micro-Sieve Layer — Basic definitions

This is the local engineering layer for replacing the broad
`brun_hooley_V_family_unconditional` axiom with a smaller explicit sieve target.

The point is not to formalize all analytic number theory in one jump. The point
is to stop using a one-line theorem-shaped closure axiom and expose the actual
objects:

* the V-family `m * 2^k * 3^l + 1`;
* triangular boxes `k+l ≤ D`;
* residue obstructions mod primes;
* a positive-count theorem implying EG203.

This file is meant to compile in a normal EG203 project after import-path
adjustment.
-/

namespace EG203.MicroSieve

/-- The Erdős-Graham #203 V-family. -/
@[reducible] def V (m k l : Nat) : Nat :=
 m * 2 ^ k * 3 ^ l + 1

/-- Ordinary moduli for EG203: coprime to 6. -/
def Ordinary (m : Nat) : Prop :=
 Nat.Coprime m 6

/-- The EG203 universal closure statement. -/
def EG203Closed : Prop :=
 ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/-- Triangular exponent box. -/
def InTriBox (D k l : Nat) : Prop :=
 k + l ≤ D

/-- A prime witness inside a triangular box. -/
def PrimeWitnessInBox (m D : Nat) : Prop :=
 ∃ k l : Nat, InTriBox D k l ∧ Nat.Prime (V m k l)

/-- Count-level positivity predicate. -/
def PositivePrimeCountInBox (m D : Nat) : Prop :=
 PrimeWitnessInBox m D

/-- Local alias for the final constructive output. -/
def HasPrimeWitness (m : Nat) : Prop :=
 ∃ k l : Nat, Nat.Prime (V m k l)

/-- A boxed witness gives an unboxed witness. -/
theorem witness_of_box
 {m D : Nat}
 (h : PrimeWitnessInBox m D) :
 HasPrimeWitness m := by
 rcases h with ⟨k,l,_hbox,hp⟩
 exact ⟨k,l,hp⟩

/-- Positive prime count implies the EG203 witness for that m. -/
theorem witness_of_positive_count
 {m D : Nat}
 (h : PositivePrimeCountInBox m D) :
 HasPrimeWitness m :=
 witness_of_box h

/-- A uniform positive-count theorem closes EG203. -/
theorem close_from_uniform_positive_count
 (H : ∀ m : Nat, Ordinary m → ∃ D : Nat, PositivePrimeCountInBox m D) :
 EG203Closed := by
 intro m hm
 rcases H m hm with ⟨D,hD⟩
 exact witness_of_positive_count hD

/-- `V m k l` is always positive. -/
theorem V_pos (m k l : Nat) : 0 < V m k l := by
 unfold V
 omega

/-- `V m k l` is never zero. -/
theorem V_ne_zero (m k l : Nat) : V m k l ≠ 0 := by
 exact Nat.ne_of_gt (V_pos m k l)

/-- If `V m k l` is prime, then it is at least 2. -/
theorem two_le_of_V_prime
 {m k l : Nat}
 (hp : Nat.Prime (V m k l)) :
 2 ≤ V m k l :=
 hp.two_le

/-- Triangle box is downward closed in D. -/
theorem box_mono
 {D E k l : Nat}
 (hDE : D ≤ E)
 (h : InTriBox D k l) :
 InTriBox E k l := by
 unfold InTriBox at *
 omega

/-- A witness in a smaller box is a witness in a larger box. -/
theorem prime_witness_box_mono
 {m D E : Nat}
 (hDE : D ≤ E)
 (h : PrimeWitnessInBox m D) :
 PrimeWitnessInBox m E := by
 rcases h with ⟨k,l,hbox,hp⟩
 exact ⟨k,l,box_mono hDE hbox,hp⟩

/-- Positive count is monotone in the box size. -/
theorem positive_count_mono
 {m D E : Nat}
 (hDE : D ≤ E)
 (h : PositivePrimeCountInBox m D) :
 PositivePrimeCountInBox m E :=
 prime_witness_box_mono hDE h

/-- The finite triangular box as a list of pairs. -/
def triBoxPairs (D : Nat) : List (Nat × Nat) :=
 (List.range (D+1)).flatMap fun k =>
 (List.range (D+1-k)).map fun l => (k,l)

/-- Boolean primality check over the triangular box. -/
def hasPrimeWitnessBool (m D : Nat) : Bool :=
 (triBoxPairs D).any fun kl =>
 Nat.Prime (V m kl.1 kl.2)

/-- A direct witness implies the Boolean checker would accept if the pair is in the list.
This is a target helper; the membership proof is intentionally separated. -/
def PairWitnessListed (D k l : Nat) : Prop :=
 (k,l) ∈ triBoxPairs D

/-- Listed prime pair implies Boolean witness. -/
theorem hasPrimeWitnessBool_eq_true_of_listed
 {m D k l : Nat}
 (hmem : PairWitnessListed D k l)
 (hp : Nat.Prime (V m k l)) :
 hasPrimeWitnessBool m D = true := by
 unfold hasPrimeWitnessBool PairWitnessListed at *
 exact List.any_eq_true.mpr ⟨(k,l), hmem, decide_eq_true hp⟩

/-- Boolean witness implies existence of a prime V-pair in the enumerated box. -/
theorem exists_of_hasPrimeWitnessBool
 {m D : Nat}
 (h : hasPrimeWitnessBool m D = true) :
 ∃ k l : Nat, PairWitnessListed D k l ∧ Nat.Prime (V m k l) := by
 unfold hasPrimeWitnessBool at h
 rcases List.any_eq_true.mp h with ⟨kl,hmem,hp⟩
 exact ⟨kl.1, kl.2, hmem, of_decide_eq_true hp⟩

end EG203.MicroSieve
