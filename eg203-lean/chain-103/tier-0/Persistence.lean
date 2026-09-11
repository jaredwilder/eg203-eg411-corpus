/-
 EG203Formal/Persistence.lean -- Erdős–Graham #203, the V18 Ferrari persistence lemma.

 STATUS: DRAFT. Verified only once `lake build` is clean and every
 `#print axioms` line shows no `sorryAx`.

 This file discharges the `persistence_lemma` that the V18 Ferrari recursive
 danger-closure search (v18_ferrari_theorem_packet.json) carried as an
 unproved Lean `sorry` stub.

 SETTING. In a covering-system attack on EG203 one studies, for a prime `q`,
 the q-mask: the exponent pairs `(k, ℓ)` with `a ^ k * b ^ ℓ + c = 0` in
 `ZMod q`, where `a, b` are the images of the two generators (`2`, `3`) and
 `c` absorbs the multiplier `m`:
 `m * 2 ^ k * 3 ^ ℓ + 1 = 0 ↔ 2 ^ k * 3 ^ ℓ + m⁻¹ = 0`,
 so `c = m⁻¹`. The packet hypothesis "q ∤ a·b·c" becomes `a ≠ 0`, `b ≠ 0` in
 the field `ZMod q` (the proof does not even need `c ≠ 0`).

 RESULT. If `q` ENLARGES the k-period -- `orderOf a ∤ K` for the base
 k-period `K` -- then no base cell can have its whole q-lift fiber inside the
 q-mask: the two fiber points `(k, ℓ)` and `(k + K, ℓ)` cannot both satisfy
 the mask equation, so at least one lift survives. The ℓ-coordinate case
 (`orderOf b ∤ L`, fiber points `(k, ℓ)` and `(k, ℓ + L)`) is symmetric.

 SCOPE (unchanged from the packet). This is a ONE-PRIME persistence statement
 over a fixed base lattice. It does NOT prove that multi-prime extension
 sequences cannot eventually cover -- that is the open multi-prime
 generalization the V18 Ferrari Race-2 search was probing by enumeration.
-/
import Mathlib

namespace EG203Formal.Persistence

/-- **Persistence core, k-direction.** In a field, if `a ^ K ≠ 1` and
`a, b ≠ 0`, the two q-lift fiber points `(k, ℓ)` and `(k + K, ℓ)` cannot both
lie on the mask `a ^ k * b ^ ℓ + c = 0`.

Proof: the two mask equations give `a ^ k * b ^ ℓ = a ^ (k + K) * b ^ ℓ`,
hence `a ^ k * b ^ ℓ * (1 - a ^ K) = 0`; the field has no zero divisors and
`a ^ k * b ^ ℓ ≠ 0`, so `a ^ K = 1`, contradicting `hK`. -/
theorem persistence_core {F : Type*} [Field F]
 (a b c : F) (ha : a ≠ 0) (hb : b ≠ 0) (k K ℓ : ℕ)
 (hK : a ^ K ≠ 1) :
 ¬ (a ^ k * b ^ ℓ + c = 0 ∧ a ^ (k + K) * b ^ ℓ + c = 0) := by
 rintro ⟨h1, h2⟩
 have hak : a ^ k ≠ 0 := pow_ne_zero k ha
 have hbl : b ^ ℓ ≠ 0 := pow_ne_zero ℓ hb
 have hprod : a ^ k * b ^ ℓ * (1 - a ^ K) = 0 := by linear_combination h1 - h2
 have hne : a ^ k * b ^ ℓ ≠ 0 := mul_ne_zero hak hbl
 rcases mul_eq_zero.mp hprod with h | h
 · exact hne h
 · exact hK (sub_eq_zero.mp h).symm

/-- **Persistence core, ℓ-direction.** Symmetric to `persistence_core`:
if `b ^ L ≠ 1`, the fiber points `(k, ℓ)` and `(k, ℓ + L)` cannot both lie
on the mask. -/
theorem persistence_core_b {F : Type*} [Field F]
 (a b c : F) (ha : a ≠ 0) (hb : b ≠ 0) (k L ℓ : ℕ)
 (hL : b ^ L ≠ 1) :
 ¬ (a ^ k * b ^ ℓ + c = 0 ∧ a ^ k * b ^ (ℓ + L) + c = 0) := by
 rintro ⟨h1, h2⟩
 have hak : a ^ k ≠ 0 := pow_ne_zero k ha
 have hbl : b ^ ℓ ≠ 0 := pow_ne_zero ℓ hb
 have hprod : a ^ k * b ^ ℓ * (1 - b ^ L) = 0 := by linear_combination h1 - h2
 have hne : a ^ k * b ^ ℓ ≠ 0 := mul_ne_zero hak hbl
 rcases mul_eq_zero.mp hprod with h | h
 · exact hne h
 · exact hL (sub_eq_zero.mp h).symm

/-- **Persistence lemma, k-direction.** The "q enlarges the k-period"
hypothesis stated with multiplicative order: `orderOf a ∤ K` (equivalently
`a ^ K ≠ 1`). No base cell has its whole q-lift fiber inside the mask. -/
theorem persistence_enlarging {F : Type*} [Field F]
 (a b c : F) (ha : a ≠ 0) (hb : b ≠ 0) (k K ℓ : ℕ)
 (hK : ¬ orderOf a ∣ K) :
 ¬ (a ^ k * b ^ ℓ + c = 0 ∧ a ^ (k + K) * b ^ ℓ + c = 0) :=
 persistence_core a b c ha hb k K ℓ
 (fun h => hK (orderOf_dvd_iff_pow_eq_one.mpr h))

/-- **Persistence lemma, ℓ-direction.** "q enlarges the ℓ-period":
`orderOf b ∤ L`. -/
theorem persistence_enlarging_b {F : Type*} [Field F]
 (a b c : F) (ha : a ≠ 0) (hb : b ≠ 0) (k L ℓ : ℕ)
 (hL : ¬ orderOf b ∣ L) :
 ¬ (a ^ k * b ^ ℓ + c = 0 ∧ a ^ k * b ^ (ℓ + L) + c = 0) :=
 persistence_core_b a b c ha hb k L ℓ
 (fun h => hL (orderOf_dvd_iff_pow_eq_one.mpr h))

/-- **Surviving lift exists** (positive form of `persistence_enlarging`).
If `q` enlarges the k-period, at least one of the two fiber lifts is *not*
on the mask -- "every base-uncovered cell has at least one surviving lift",
the conclusion phrasing of the V18 packet's persistence lemma. -/
theorem persistence_survivor {F : Type*} [Field F]
 (a b c : F) (ha : a ≠ 0) (hb : b ≠ 0) (k K ℓ : ℕ)
 (hK : ¬ orderOf a ∣ K) :
 a ^ k * b ^ ℓ + c ≠ 0 ∨ a ^ (k + K) * b ^ ℓ + c ≠ 0 :=
 not_and_or.mp (persistence_enlarging a b c ha hb k K ℓ hK)

/-- **Mod-`q` instantiation.** The actual covering-system setting: `q` prime,
the mask lives in the field `ZMod q`; `a ≠ 0`, `b ≠ 0` is exactly the packet
hypothesis `q ∤ a·b`. An enlarging prime cannot trap a whole fiber. -/
theorem persistence_zmod {q : ℕ} (hq : q.Prime)
 (a b c : ZMod q) (ha : a ≠ 0) (hb : b ≠ 0) (k K ℓ : ℕ)
 (hK : ¬ orderOf a ∣ K) :
 ¬ (a ^ k * b ^ ℓ + c = 0 ∧ a ^ (k + K) * b ^ ℓ + c = 0) := by
 haveI : Fact q.Prime := ⟨hq⟩
 exact persistence_enlarging a b c ha hb k K ℓ hK

#print axioms persistence_core
#print axioms persistence_core_b
#print axioms persistence_enlarging
#print axioms persistence_enlarging_b
#print axioms persistence_survivor
#print axioms persistence_zmod

end EG203Formal.Persistence
