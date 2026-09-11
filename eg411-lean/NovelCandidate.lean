import EG411.CascadeLemma

/-!
# Generated candidate: a concrete EG#411 cascade instance at j = 2.

This is intentionally generated from the general cascade machinery. Its novelty receipt
means only that this exact statement was not found in the preserved local proof/source corpus;
it is not a global literature-prior-art certificate.
-/

namespace EG411Novelty

theorem cascade_instance_two :
    3 * Nat.totient (6 ^ 2 ^ 2 - 1) = 2 * (6 ^ 2 ^ 2 - 1) + 2
      ↔ ∀ k, k < 2 → Nat.Prime (6 ^ 2 ^ k + 1) := by
  simpa using EG411Cascade.cascade_lemma 2

#print axioms cascade_instance_two

end EG411Novelty
