/-
 EG203Formal/PersistenceMulti.lean -- attempted MULTI-PRIME persistence.

 STATUS: SKETCH / DIAGNOSTIC. This file does NOT close. It is the
 honest record of what breaks when you try to lift the one-prime
 V18 persistence lemma (Persistence.lean) to multi-prime joint coverage.

 THE QUESTION. One-prime persistence proves: for a single prime `q`,
 the two fiber points `(k, ℓ)` and `(k + K, ℓ)` cannot both lie on
 the `q`-mask. Each base cell has at least one fiber lift that
 survives `q`. The natural gap (flagged by GPT in the V18 audit) is
 that DIFFERENT primes can cover DIFFERENT fiber points: prime `q₁`
 covers `(k, ℓ)`, prime `q₂` covers `(k + K, ℓ)`, neither alone
 traps the fiber, but the union does. We try to rule this out.

 WHAT WORKS. The "homogeneous" / per-prime statement extends
 trivially: indexing one-prime persistence over a finite family of
 primes is bookkeeping. See `persistence_family_each_prime`.

 WHAT BLOCKS. The actually-strong multi-prime claim --
 "no PAIR of fiber points can be JOINTLY covered by ANY pair of
 primes from the family" -- does NOT follow from the algebraic kernel
 of the one-prime proof. The blocker is identified at the marked
 `sorry` in `joint_cover_attempt` below: the two surviving equations
 live in DIFFERENT fields, so the field-cancellation step
 (`a^k·b^ℓ·(1 - a^K) = 0` ⇒ `a^K = 1`) has no shared ambient ring
 in which to fire. CRT-combining into `ZMod (q₁·q₂)` is not a field,
 so `mul_eq_zero` (which the V18 proof critically uses) fails.

 CONCLUSION (research verdict, recorded below the code). The
 one-prime persistence lemma does NOT generalize to a multi-prime
 joint-coverage obstruction by the same algebraic route. This is
 why the V18 Ferrari Race-2 search was an ENUMERATION, not a uniform
 algebraic argument. A real advance route would need either:
 (i) a numeric / size argument bounding |union of masks| below the
 fiber size (this is the density / inclusion-exclusion lane,
 compare PrimeGapInclusionExclusion.lean), or
 (ii) an extra structural hypothesis tying the order vectors
 `(orderOf a_{q_i})_i` across primes (Chebotarev-style), which
 would require a NEW algebraic input not present in the V18 packet.
-/
import Mathlib
import EG203Formal.Persistence

namespace EG203Formal.PersistenceMulti

open EG203Formal.Persistence

/-! ### Part 1 — the EASY (essentially bookkeeping) multi-prime lifts. -/

/-- **Per-prime persistence over a finite family.** If EVERY prime
in the family enlarges the k-period, then for EVERY prime the two
fiber points `(k,ℓ)` and `(k+K,ℓ)` cannot both be on that prime's
mask. This is just `persistence_zmod` quantified over `i`. It is
NOT joint coverage. -/
theorem persistence_family_each_prime
 {ι : Type*} (qs : ι → ℕ) (hqs : ∀ i, (qs i).Prime)
 (a b c : ∀ i, ZMod (qs i))
 (ha : ∀ i, a i ≠ 0) (hb : ∀ i, b i ≠ 0)
 (k K ℓ : ℕ)
 (hK : ∀ i, ¬ orderOf (a i) ∣ K) :
 ∀ i,
 ¬ ((a i) ^ k * (b i) ^ ℓ + c i = 0
 ∧ (a i) ^ (k + K) * (b i) ^ ℓ + c i = 0) := by
 intro i
 haveI : Fact (qs i).Prime := ⟨hqs i⟩
 exact persistence_enlarging (a i) (b i) (c i) (ha i) (hb i) k K ℓ (hK i)

/-- **Survivor (positive form) over a family.** Same content as above:
for EACH prime, at least one of the two fiber points evades THAT
prime's mask. Still NOT joint coverage. -/
theorem persistence_family_survivor
 {ι : Type*} (qs : ι → ℕ) (hqs : ∀ i, (qs i).Prime)
 (a b c : ∀ i, ZMod (qs i))
 (ha : ∀ i, a i ≠ 0) (hb : ∀ i, b i ≠ 0)
 (k K ℓ : ℕ)
 (hK : ∀ i, ¬ orderOf (a i) ∣ K) :
 ∀ i,
 (a i) ^ k * (b i) ^ ℓ + c i ≠ 0
 ∨ (a i) ^ (k + K) * (b i) ^ ℓ + c i ≠ 0 := by
 intro i
 exact not_and_or.mp (persistence_family_each_prime qs hqs a b c ha hb k K ℓ hK i)


/-! ### Part 2 — the HARD claim (joint coverage) and where it breaks. -/

/-- A fiber point `(k,ℓ)` is **covered by prime `i`** if it lies on
that prime's mask. -/
def coveredBy
 {ι : Type*} (qs : ι → ℕ)
 (a b c : ∀ i, ZMod (qs i))
 (k ℓ : ℕ) (i : ι) : Prop :=
 (a i) ^ k * (b i) ^ ℓ + c i = 0

/-- The fiber point is **covered by the family** if SOME prime in the
family covers it. -/
def coveredByFamily
 {ι : Type*} (qs : ι → ℕ)
 (a b c : ∀ i, ZMod (qs i))
 (k ℓ : ℕ) : Prop :=
 ∃ i, coveredBy qs a b c k ℓ i

/-- **The multi-prime joint-coverage claim** (STATEMENT ONLY, NOT
PROVED). If every prime in the family enlarges the k-period, then
the two fiber points `(k,ℓ)` and `(k+K,ℓ)` cannot BOTH be covered
by the family.

This is the statement that, if true, would close the gap GPT
identified. Below we attempt the proof and pinpoint the failure. -/
def MultiPrimeJointPersistence
 {ι : Type*} (qs : ι → ℕ) (hqs : ∀ i, (qs i).Prime)
 (a b c : ∀ i, ZMod (qs i))
 (ha : ∀ i, a i ≠ 0) (hb : ∀ i, b i ≠ 0)
 (k K ℓ : ℕ)
 (hK : ∀ i, ¬ orderOf (a i) ∣ K) : Prop :=
 ¬ ( coveredByFamily qs a b c k ℓ ∧ coveredByFamily qs a b c (k + K) ℓ )

/-- **Attempted proof.** We unfold and try to reproduce the
one-prime kernel. The proof breaks; the blocker is marked. -/
example
 {ι : Type*} (qs : ι → ℕ) (hqs : ∀ i, (qs i).Prime)
 (a b c : ∀ i, ZMod (qs i))
 (ha : ∀ i, a i ≠ 0) (hb : ∀ i, b i ≠ 0)
 (k K ℓ : ℕ)
 (hK : ∀ i, ¬ orderOf (a i) ∣ K) :
 MultiPrimeJointPersistence qs hqs a b c ha hb k K ℓ hK := by
 -- Unfold definitions.
 unfold MultiPrimeJointPersistence coveredByFamily coveredBy
 rintro ⟨⟨i, hi⟩, ⟨j, hj⟩⟩
 -- We have:
 -- hi : (a i) ^ k * (b i) ^ ℓ + c i = 0 in ZMod (qs i)
 -- hj : (a j) ^ (k + K) * (b j) ^ ℓ + c j = 0 in ZMod (qs j)
 --
 -- Case 1: i = j. Then `persistence_zmod` for the prime `qs i`
 -- directly gives a contradiction. This case CLOSES.
 by_cases hij : i = j
 · subst hij
 haveI : Fact (qs i).Prime := ⟨hqs i⟩
 exact persistence_enlarging (a i) (b i) (c i) (ha i) (hb i) k K ℓ (hK i) ⟨hi, hj⟩
 · -- Case 2: i ≠ j. This is the BLOCKER.
 --
 -- The two equations live in DIFFERENT fields. There is no shared
 -- ambient ring in which to form `(a i)^k * (b i)^ℓ * (1 - (a i)^K)`.
 -- The CRT pair `(hi, hj)` upgrades to a single equation in
 -- `ZMod (qs i * qs j)` BUT that ring is NOT a field when
 -- `qs i ≠ qs j` (both are prime and distinct, so the product has
 -- a nontrivial idempotent decomposition). The cancellation step
 -- `xy = 0 ⇒ x = 0 ∨ y = 0`
 -- (the heart of the V18 proof) fails.
 --
 -- Worse: there is no reason to expect `a i` and `a j` to have the
 -- same order, the same residue, or even live in compatible
 -- algebraic structures. The masks for `qs i` and `qs j` are
 -- INDEPENDENT in the strongest possible algebraic sense.
 --
 -- A proof of the multi-prime joint-coverage obstruction would
 -- have to come from OUTSIDE the per-prime algebraic kernel:
 -- a density/counting argument, a Chebotarev-type density
 -- statement on the joint distribution of orders, or a finite
 -- enumeration (which is exactly what V18 Ferrari Race-2 did and
 -- which IS the open route, not a closed proof).
 --
 -- INTEGER-VIEW DIAGNOSTIC. Lifting back to ℤ, the two
 -- divisibilities are
 -- qs i ∣ 2^k * 3^ℓ + m
 -- qs j ∣ 2^(k+K) * 3^ℓ + m
 -- Subtraction (the integer analogue of the field cancellation
 -- step) gives
 -- qs i and qs j both divide expressions that DIFFER by
 -- 2^k * 3^ℓ * (2^K - 1).
 -- But this difference fact constrains only the JOINT divisor
 -- gcd(qs i, qs j) = 1 (distinct primes), so it carries no
 -- algebraic content. The one-prime cancellation step disappears
 -- precisely because the two moduli no longer share a residue ring.
 sorry

/-! ### Part 3 — what *can* be salvaged: the trivial union bound. -/

/-- **Trivial multi-prime union bound (positive form).** Each prime
has a fiber survivor (Persistence.lean). The INTERSECTION of all the
per-prime "surviving fiber lift" sets is non-empty IFF the survivor
choices can be made compatibly. In a fixed pair `{(k,ℓ),(k+K,ℓ)}`
this is just the two-point case; in general it requires picking ONE
surviving lift simultaneously for every prime, which is again the
joint-coverage problem. So even the "positive" union restatement
does not strengthen `persistence_family_survivor` without the same
new algebraic input. -/
example
 {ι : Type*} [Fintype ι] (qs : ι → ℕ) (hqs : ∀ i, (qs i).Prime)
 (a b c : ∀ i, ZMod (qs i))
 (ha : ∀ i, a i ≠ 0) (hb : ∀ i, b i ≠ 0)
 (k K ℓ : ℕ)
 (hK : ∀ i, ¬ orderOf (a i) ∣ K) :
 -- For every prime separately, one of the two lifts survives.
 -- (This is exactly `persistence_family_survivor` re-spelled.)
 ∀ i, (a i) ^ k * (b i) ^ ℓ + c i ≠ 0
 ∨ (a i) ^ (k + K) * (b i) ^ ℓ + c i ≠ 0 :=
 persistence_family_survivor qs hqs a b c ha hb k K ℓ hK

end EG203Formal.PersistenceMulti
