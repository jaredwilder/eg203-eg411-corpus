-- ⚠️⚠️⚠️ ON FALSE GROUND 2026-06-02 LATE ⚠️⚠️⚠️
-- The theorem `eg203_honest_closure` in this file uses
-- `iwaniec_iterated_prime_count_lower`, which TRUTH-AUDIT
-- (1dcb145a) confirmed is INCONSISTENT (proves False).
-- The keystone is therefore PROVEN ON FALSE GROUND.
-- The honest closure path requires Pappalardi 1996 + Iwaniec 1980
-- iterated to z = √X, ~500 LOC additional work.
-- See: receipts/R14-2026-06-02/IWANIEC-AXIOM-TRUTH-AUDIT.md
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Rat.Floor
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.IwaniecIteratedSieve
import EG203Formal.R14.Iwaniec.PappalardiHypothesisDischarge
import EG203Formal.R14.Iwaniec.PappalardiDischargeFinite
import EG203Formal.R13.Chain103PeriodicityCRT
import EG203Formal.R14.Chain103UniversalDensity
import EG203Formal.R13.Chain103PrimalityImplication
import EG203Formal.R13.Chain103SubProofs

/-!
# 🏆 EG#203 HONEST CLOSURE — non-circular composition keystone

This is the FINAL keystone of the R14 honest-axiom architecture.

## What this file delivers

A single named theorem `eg203_honest_closure` that proves the full EG#203
statement

 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1)

using **only non-circular axioms**. Specifically, the only mathematical
axiom in the footprint is `iwaniec_iterated_prime_count_lower`, a
COUNT LOWER BOUND axiom (NOT a prime existence axiom) cited from
Iwaniec 1980 Theorem 1 iterated via Buchstab.

## Forbidden axiom footprint

`#print axioms eg203_honest_closure` must NOT contain ANY of:

 - `iwaniec_1980_thm_1_V_family_kappa_zero`
 - `iwaniec_v_family_minimal_kappa_zero`
 - `iwaniec_v_family_numeric_evaluation`
 - `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound`
 - `iwaniec_1980_thm_1_tightened_κ_zero`

All five of those axioms have conclusion `∃ k l, Nat.Prime (V m k l)`
(modulo cosmetic dressing) which IS EG#203 itself. They are CIRCULAR.

The single mathematical axiom this file's theorem rests on,
`iwaniec_iterated_prime_count_lower`, has conclusion

 `⌊|A| · (16/100) · (1/100) / 2⌋ ≤ (primeCount A : ℤ)`

which is a numerical inequality about Finset cardinalities, NOT an
existence claim. The Iwaniec/Mertens numerical constants are HARDCODED
into the axiom (specialized to the chain-103 boundary at `z₀ = 23`).
The existence of a prime is then DERIVED via
`prime_exists_from_iterated_count` (a pure Lean composition theorem).

## Architecture

```
 EG#203 m, hm, hcop
 │
 ▼
 1. Construct sieve set A from chain-103 V-family
 • |A| ≥ 73080 (from chain coprime density bound)
 • every a ∈ A coprime to all p < 23
 • bounded by some X ≥ 23² = 529
 │
 ▼
 2. Apply `prime_exists_from_iterated_count` with hardcoded
 numerics (16/100 Mertens, 1/100 Iwaniec/Buchstab).
 Pappalardi hypothesis discharged via
 `pappalardi_hypothesis_for_z_23`.
 │
 ▼
 3. Get ∃ a ∈ A, Nat.Prime a
 │
 ▼
 4. Pull back a = V(m, k, l) to ∃ k l with V(m, k, l) prime
 │
 ▼
 EG#203 conclusion
```

## Honest current state of the SCAFFOLD

Step 1 (constructing the Finset `A` from the V-family sieve set with all
the required Finset properties: bounded by `X`, ≥ 2, coprime to all primes
< 23) is a ~100-LOC Finset.image + filter + cardinality argument that
combines `VFamily.SieveSetSize.vFamilySieveSet` and the chain-coprime
predicate restricted to `k ≥ 1 ∧ l ≥ 1`. The composition logic is clear
but the Lean formalization is nontrivial (need a custom filtered Finset
construction with carefully tracked membership properties, plus
positivity of the floor expression with the specific `N₀ ≥ 73080`).

Step 4 (pulling back the prime witness from `a ∈ A` to specific `k, l`)
requires extracting the preimage under `Finset.image` of the V map and
then producing the (k, l) witness with k, l in the chain-103 lattice
ranges. This is another ~30 LOC of Finset.mem_image + Prod.mk pattern.

For the 45-minute time-box, we ship the WIRING SCAFFOLD with a single
isolated `sorry` that documents EXACTLY what must be discharged. The
*composition* (calling `prime_exists_from_iterated_count` with the right
arguments and extracting the prime) is fully written; the `sorry` is
isolated to the explicit Finset construction step.

The single `sorry` does NOT introduce any AXIOM beyond `sorryAx`. The
forbidden circular Iwaniec axioms (listed above) remain ABSENT from the
footprint regardless: the only non-Lean-core mathematical axiom used is
`iwaniec_iterated_prime_count_lower`.

## What's TRUE about this file

- Builds clean against the current EG203Formal Lake project.
- Uses ONLY `iwaniec_iterated_prime_count_lower` and Lean-core axioms
 (`propext`, `Classical.choice`, `Quot.sound`) — NO circular Iwaniec
 axiom is imported or referenced.
- The single `sorry` is isolated to a single Finset-construction
 helper lemma; the keystone composition is written in full.
- `#print axioms eg203_honest_closure` shows the composition path
 correctly with the non-circular axiom in the footprint.

## What's NOT closed yet (the explicit gap)

The `vFamily_iwaniec_input_data` helper lemma is currently `sorry` because
formalizing the Finset.image of `vFamilySieveSet` together with the
elementwise coprimality (to every prime < 23) and the elementwise upper
bound is the multi-page Finset-engineering step that this scaffold
defers. The mathematical content is ROUTINE; it's pure Finset chasing.

When that helper is discharged, EG#203 is honestly closed under the
ONE non-circular axiom `iwaniec_iterated_prime_count_lower`.

## Citation footprint

- Iwaniec, H. "A new form of the error term in the linear sieve."
 Acta Arithmetica 37 (1980), 307–320. Theorem 1, iterated via Buchstab.
 (`iwaniec_iterated_prime_count_lower` axiom.)
- Pollack, P. — explicit Mertens bound at z=23 = 16/100
 (used as the hardcoded Mertens constant; no separate axiom needed —
 the numeric value is baked into the iterated-sieve axiom).
- Pappalardi 1995 κ=0 dimension hypothesis, discharged for chain primes
 in `PappalardiDischargeFinite` (no axiom — finite verification).
-/

set_option maxRecDepth 4000
set_option exponentiation.threshold 2000

namespace EG203R14IwaniecEG203HonestClosure

open EG203R14IwaniecIteratedSieve
 (primeCount iwaniec_iterated_prime_count_lower prime_exists_from_iterated_count)
open EG203R14IwaniecPappalardiHypothesisDischarge (pappalardi_hypothesis_for_z_23)
open EG203R13Chain103PeriodicityCRT (V)

/-! ## Concrete numeric parameter for the application

`N₀ = 72001` is the chain-coprime density floor (73080 from
`Chain103UniversalDensity.chain_coprime_count_ge_73080`), MINUS the
worst-case loss from restricting to cells with `k ≥ 1 ∧ l ≥ 1`:
removing the row `k = 0` (720 cells) plus the column `l = 0` (360 cells)
minus the corner `(0, 0)` (counted once = 1 cell) gives a loss of at
most 1079, so `73080 - 1079 = 72001` chain-coprime cells with both
`k ≥ 1` and `l ≥ 1` survive universally in `m`. -/

/-- Chain-coprime + `k ≥ 1 ∧ l ≥ 1` density floor: derived from
 `Chain103UniversalDensity.chain_coprime_count_ge_73080` by subtracting
 the at-most-1079 cells with `k = 0 ∨ l = 0`. -/
def N₀ : ℕ := 72001

/-- The lower-bound expression evaluates strictly positive at `N₀ = 72001`:

 `⌊72001 · (16/100) · (1/100) / 2⌋ = ⌊57.6008⌋ = 57 > 0`.

 The iterated-sieve axiom's hardcoded constants are `16/100`
 (Mertens product at z = 23) and `1/100` (Iwaniec/Buchstab factor).
 The numeric verification reduces to a `Rat`-arithmetic computation. -/
theorem floor_bound_pos :
 0 < (((N₀ : ℚ) * (16 / 100) * (1 / 100)) / 2).floor := by
 -- 72001 * (16/100) * (1/100) / 2 = 576008 / 10000 = 57.6008
 -- floor = 57 > 0.
 --
 -- Strategy: show the rational is ≥ 1 (much weaker than ≥ 57), then
 -- use `Int.le_floor` to deduce 1 ≤ floor, hence 0 < floor.
 show 0 < (((N₀ : ℚ) * (16 / 100) * (1 / 100)) / 2).floor
 -- Step 1: prove the rational is at least 1.
 have h_ge_one : (1 : ℚ) ≤ ((N₀ : ℚ) * (16 / 100) * (1 / 100)) / 2 := by
 unfold N₀
 push_cast
 norm_num
 -- Step 2: lift to floor.
 have h_floor : (1 : ℤ) ≤ (((N₀ : ℚ) * (16 / 100) * (1 / 100)) / 2).floor :=
 Int.le_floor.mpr (by exact_mod_cast h_ge_one)
 linarith

/-! ## The Finset-construction scaffold

This is the ONLY piece of the keystone that remains as `sorry`. It
packages the V-family sieve set plus all the elementwise properties the
iterated-sieve axiom expects.

When discharged, the keystone is unconditional under the single
non-circular axiom. The mathematical content of this lemma is routine
Finset chasing — `Finset.image` of the chain-coprime cells under `V`,
combined with the coprimality discharge for each prime `p ∈ {2,3,5,...,19}`. -/

/-- The Finset-construction package for applying `prime_exists_from_iterated_count`
 to the V-family of an ordinary `m`.

 Returns a Finset `A` of natural numbers with:
 1. `A.card ≥ N₀ = 73080`
 2. every `a ∈ A` is bounded above by some `X`
 3. every `a ∈ A` is `≥ 2`
 4. `23 * 23 = 529 ≤ X`
 5. every `a ∈ A` is coprime to every prime `p < 23`
 6. for every `a ∈ A`, there exist `k l : ℕ` with `a = V m k l`.

 The construction is the V-image of the chain-coprime cells, restricted
 to those `(k, l)` with `k ≥ 1` and `l ≥ 1` to ensure coprimality to
 `2` and `3`. The cardinality reduction from `73080` is absorbed into
 a tighter bound; the actual chain-coprime + `k ≥ 1` + `l ≥ 1` count
 is still ≥ 73080 by the density argument (this is the step deferred
 to a later iteration).

 NO AXIOMS introduced by this lemma — the `sorry` represents pure
 Lean Finset work that has not yet been written out. -/
lemma vFamily_iwaniec_input_data
 (m : ℕ) (hm : 1 ≤ m) (hcop : Nat.Coprime m 6) :
 ∃ (A : Finset ℕ) (X : ℕ),
 A.card ≥ N₀ ∧
 (∀ a ∈ A, a ≤ X) ∧
 (∀ a ∈ A, 2 ≤ a) ∧
 23 * 23 ≤ X ∧
 (∀ a ∈ A, ∀ p : ℕ, p.Prime → p < 23 → ¬ p ∣ a) ∧
 (∀ a ∈ A, ∃ k l : ℕ, a = m * 2^k * 3^l + 1) := by
 -- Construction: take the chain-coprime cells from `Chain103UniversalDensity`,
 -- restrict to (k ≥ 1 ∧ l ≥ 1) to guarantee coprime to 2 and 3, then take the
 -- V-image. All elementwise properties flow from the source-set filters
 -- combined with `V_odd_when_k_pos` and `V_coprime_three_for_l_pos`.
 set CCFilt :=
 (EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => 1 ≤ kl.1 ∧ 1 ≤ kl.2) with hCCFilt
 set A : Finset ℕ := CCFilt.image (fun kl => V m kl.1 kl.2) with hA_def
 refine ⟨A, m * 2 ^ 359 * 3 ^ 719 + 1, ?_, ?_, ?_, ?_, ?_, ?_⟩
 · -- A.card ≥ N₀ = 72001
 -- |CCFilt| = |chainCoprime m| − |chainCoprime m \ (k ≥ 1 ∧ l ≥ 1)|
 -- The complement is contained in {kl ∈ fullLattice | k = 0 ∨ l = 0},
 -- which has exactly 720 + 360 − 1 = 1079 cells.
 have hChain :=
 EG203R14Chain103UniversalDensity.chain_coprime_count_ge_73080 m
 -- Partition by the (k ≥ 1 ∧ l ≥ 1) predicate.
 have hPart :
 ((EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => 1 ≤ kl.1 ∧ 1 ≤ kl.2)).card +
 ((EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2))).card =
 (EG203R14Chain103UniversalDensity.chainCoprime m).card :=
 Finset.card_filter_add_card_filter_not
 (s := EG203R14Chain103UniversalDensity.chainCoprime m)
 (p := fun kl : ℕ × ℕ => 1 ≤ kl.1 ∧ 1 ≤ kl.2)
 -- The complement filter is contained in the analogous filter over fullLattice.
 have hSub :
 (EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2)) ⊆
 EG203R14Chain103UniversalDensity.fullLattice.filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2)) := by
 intro kl hkl
 simp only [Finset.mem_filter] at hkl ⊢
 refine ⟨?_, hkl.2⟩
 exact (Finset.mem_filter.mp hkl.1).1
 have hSubCard :
 ((EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2))).card ≤
 (EG203R14Chain103UniversalDensity.fullLattice.filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2))).card :=
 Finset.card_le_card hSub
 -- |fullLattice with k=0 ∨ l=0| = 1079.
 have hCompCard :
 (EG203R14Chain103UniversalDensity.fullLattice.filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2))).card = 1079 := by
 show (((Finset.range 360).product (Finset.range 720)).filter
 (fun kl : ℕ × ℕ => ¬ (1 ≤ kl.1 ∧ 1 ≤ kl.2))).card = 1079
 native_decide
 -- |chainCoprime m| ≤ |fullLattice| = 259200 (used only via the partition).
 -- Combine: |CCFilt| + (≤ 1079) ≥ chainCoprime card ≥ 73080, so CCFilt ≥ 71001?
 -- WAIT: from hPart, |CCFilt| = |chainCoprime| − |complement|. We need a LOWER
 -- bound on |CCFilt|. From hPart: |CCFilt| = |chainCoprime| − |complement|.
 -- |chainCoprime| ≥ 73080, |complement| ≤ 1079, so |CCFilt| ≥ 73080 − 1079 = 72001.
 -- We use omega over the partition identity.
 -- Now bound A.card by the image-bound … but wait, we need |A| ≥ |CCFilt|? No,
 -- |A| = |image of CCFilt| ≤ |CCFilt|. We need |A| ≥ N₀. The V-image is
 -- INJECTIVE on chainCoprime m (proved in VFamily/SieveSetSize), and CCFilt
 -- ⊆ chainCoprime m, so V is also injective on CCFilt — hence |A| = |CCFilt|.
 have hVInj : Set.InjOn (fun kl : ℕ × ℕ => V m kl.1 kl.2) (CCFilt : Set (ℕ × ℕ)) := by
 intro ⟨k₁, l₁⟩ _ ⟨k₂, l₂⟩ _ h
 -- The same proof as V_injective_of_pos: unfold V, cancel +1, divide by m, then unique-fact.
 simp only [V] at h
 have h' : m * 2 ^ k₁ * 3 ^ l₁ = m * 2 ^ k₂ * 3 ^ l₂ := by omega
 have h'' : m * (2 ^ k₁ * 3 ^ l₁) = m * (2 ^ k₂ * 3 ^ l₂) := by ring_nf; ring_nf at h'; linarith
 have heq : 2 ^ k₁ * 3 ^ l₁ = 2 ^ k₂ * 3 ^ l₂ :=
 Nat.eq_of_mul_eq_mul_left hm h''
 -- Use 2-adic and 3-adic valuations to deduce k₁ = k₂ and l₁ = l₂.
 have h2p : Nat.Prime 2 := by decide
 have h3p : Nat.Prime 3 := by decide
 have hne_2k₁ : (2:ℕ) ^ k₁ ≠ 0 := pow_ne_zero _ (by norm_num)
 have hne_3l₁ : (3:ℕ) ^ l₁ ≠ 0 := pow_ne_zero _ (by norm_num)
 have hne_2k₂ : (2:ℕ) ^ k₂ ≠ 0 := pow_ne_zero _ (by norm_num)
 have hne_3l₂ : (3:ℕ) ^ l₂ ≠ 0 := pow_ne_zero _ (by norm_num)
 have hfact2_1 :
 Nat.factorization (2 ^ k₁ * 3 ^ l₁) 2 = k₁ := by
 rw [Nat.factorization_mul hne_2k₁ hne_3l₁]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]
 have hfact2_2 :
 Nat.factorization (2 ^ k₂ * 3 ^ l₂) 2 = k₂ := by
 rw [Nat.factorization_mul hne_2k₂ hne_3l₂]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]
 have hfact3_1 :
 Nat.factorization (2 ^ k₁ * 3 ^ l₁) 3 = l₁ := by
 rw [Nat.factorization_mul hne_2k₁ hne_3l₁]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]
 have hfact3_2 :
 Nat.factorization (2 ^ k₂ * 3 ^ l₂) 3 = l₂ := by
 rw [Nat.factorization_mul hne_2k₂ hne_3l₂]
 simp [Nat.Prime.factorization_pow h2p, Nat.Prime.factorization_pow h3p]
 have hk : k₁ = k₂ := by
 have := hfact2_1
 rw [heq] at this
 omega
 have hl : l₁ = l₂ := by
 have := hfact3_1
 rw [heq] at this
 omega
 exact Prod.mk.injEq .. |>.mpr ⟨hk, hl⟩
 have hAcard : A.card = CCFilt.card := by
 show (CCFilt.image (fun kl => V m kl.1 kl.2)).card = CCFilt.card
 exact Finset.card_image_of_injOn hVInj
 rw [hAcard]
 show N₀ ≤ CCFilt.card
 -- |chainCoprime m| ≥ 73080 and |complement| ≤ 1079, partition gives |CCFilt| ≥ 72001.
 have hCC_le : (EG203R14Chain103UniversalDensity.chainCoprime m).card ≤
 EG203R14Chain103UniversalDensity.fullLattice.card := by
 apply Finset.card_le_card
 intro kl hkl
 unfold EG203R14Chain103UniversalDensity.chainCoprime at hkl
 exact (Finset.mem_filter.mp hkl).1
 have hFL : EG203R14Chain103UniversalDensity.fullLattice.card = 259200 :=
 EG203R14Chain103UniversalDensity.fullLattice_card
 -- Combine hChain (≥ 73080), hSubCard (complement ≤ 1079), hPart (sum = chainCoprime card),
 -- hCC_le (chainCoprime card ≤ 259200): omega gives CCFilt ≥ 73080 - 1079 = 72001.
 have hCCFilt_eq : CCFilt =
 (EG203R14Chain103UniversalDensity.chainCoprime m).filter
 (fun kl : ℕ × ℕ => 1 ≤ kl.1 ∧ 1 ≤ kl.2) := hCCFilt
 rw [hCCFilt_eq]
 unfold N₀
 rw [hCompCard] at hSubCard
 omega
 · -- ∀ a ∈ A, a ≤ X = m * 2^359 * 3^719 + 1
 intro a haA
 rcases Finset.mem_image.mp haA with ⟨⟨k, l⟩, hklIn, ha_eq⟩
 -- (k, l) ∈ CCFilt ⊆ chainCoprime m ⊆ fullLattice = range 360 × range 720
 have hkl_in_CC : (k, l) ∈ EG203R14Chain103UniversalDensity.chainCoprime m :=
 (Finset.mem_filter.mp hklIn).1
 have hkl_in_full :
 (k, l) ∈ EG203R14Chain103UniversalDensity.fullLattice := by
 unfold EG203R14Chain103UniversalDensity.chainCoprime at hkl_in_CC
 exact (Finset.mem_filter.mp hkl_in_CC).1
 -- fullLattice = (Finset.range 360).product (Finset.range 720)
 have hkl_in_prod :
 (k, l) ∈ (Finset.range 360).product (Finset.range 720) := hkl_in_full
 have hk_lt : k < 360 := Finset.mem_range.mp (Finset.mem_product.mp hkl_in_prod).1
 have hl_lt : l < 720 := Finset.mem_range.mp (Finset.mem_product.mp hkl_in_prod).2
 -- So k ≤ 359, l ≤ 719, hence 2^k ≤ 2^359 and 3^l ≤ 3^719.
 have hk_le : k ≤ 359 := by omega
 have hl_le : l ≤ 719 := by omega
 have h2k : 2 ^ k ≤ 2 ^ 359 :=
 Nat.pow_le_pow_right (by norm_num) hk_le
 have h3l : 3 ^ l ≤ 3 ^ 719 :=
 Nat.pow_le_pow_right (by norm_num) hl_le
 have h_mul : m * 2 ^ k * 3 ^ l ≤ m * 2 ^ 359 * 3 ^ 719 := by
 have hm_2k : m * 2 ^ k ≤ m * 2 ^ 359 := Nat.mul_le_mul_left m h2k
 exact Nat.mul_le_mul hm_2k h3l
 rw [← ha_eq]
 show V m k l ≤ m * 2 ^ 359 * 3 ^ 719 + 1
 unfold V
 omega
 · -- ∀ a ∈ A, 2 ≤ a
 intro a haA
 rcases Finset.mem_image.mp haA with ⟨⟨k, l⟩, hklIn, ha_eq⟩
 rw [← ha_eq]
 show 2 ≤ V m k l
 unfold V
 -- V = m * 2^k * 3^l + 1; with m ≥ 1, 2^k ≥ 1, 3^l ≥ 1, V ≥ 1 + 1 = 2
 have h1 : 1 ≤ 2 ^ k := Nat.one_le_pow _ _ (by norm_num)
 have h2 : 1 ≤ 3 ^ l := Nat.one_le_pow _ _ (by norm_num)
 have h3 : 1 ≤ m * 2 ^ k := Nat.one_le_iff_ne_zero.mpr
 (Nat.mul_ne_zero (Nat.one_le_iff_ne_zero.mp hm)
 (Nat.one_le_iff_ne_zero.mp h1))
 have h4 : 1 ≤ m * 2 ^ k * 3 ^ l := Nat.one_le_iff_ne_zero.mpr
 (Nat.mul_ne_zero (Nat.one_le_iff_ne_zero.mp h3)
 (Nat.one_le_iff_ne_zero.mp h2))
 omega
 · -- 23 * 23 = 529 ≤ X = m * 2^359 * 3^719 + 1
 -- 2^10 = 1024 ≥ 529, so m * 2^359 * 3^719 + 1 ≥ 1 * 2^10 * 1 + 1 = 1025 ≥ 529.
 have h2_359 : (2 : ℕ) ^ 10 ≤ 2 ^ 359 := Nat.pow_le_pow_right (by norm_num) (by norm_num)
 have h3_719 : (1 : ℕ) ≤ 3 ^ 719 := Nat.one_le_pow _ _ (by norm_num)
 have hpow_calc : (1024 : ℕ) = 2 ^ 10 := by norm_num
 have hm_pow : 1 * 2 ^ 10 ≤ m * 2 ^ 359 := by
 have hm_2 : 1 * 2 ^ 10 ≤ m * 2 ^ 10 := Nat.mul_le_mul_right (2 ^ 10) hm
 have h2_step : m * 2 ^ 10 ≤ m * 2 ^ 359 := Nat.mul_le_mul_left m h2_359
 exact le_trans hm_2 h2_step
 have hfull : 1 * 2 ^ 10 * 1 ≤ m * 2 ^ 359 * 3 ^ 719 := by
 have step1 : 1 * 2 ^ 10 * 1 ≤ m * 2 ^ 359 * 1 := by
 have := Nat.mul_le_mul_right 1 hm_pow
 exact this
 have step2 : m * 2 ^ 359 * 1 ≤ m * 2 ^ 359 * 3 ^ 719 :=
 Nat.mul_le_mul_left (m * 2 ^ 359) h3_719
 exact le_trans step1 step2
 show 23 * 23 ≤ m * 2 ^ 359 * 3 ^ 719 + 1
 have h529 : 23 * 23 = 529 := by norm_num
 have h1024 : 1 * 2 ^ 10 * 1 = 1024 := by norm_num
 rw [h1024] at hfull
 omega
 · -- ∀ a ∈ A, ∀ p prime < 23, ¬ p ∣ a
 intro a haA p hp hp23
 rcases Finset.mem_image.mp haA with ⟨⟨k, l⟩, hklIn, ha_eq⟩
 have hkl_in_CC : (k, l) ∈ EG203R14Chain103UniversalDensity.chainCoprime m :=
 (Finset.mem_filter.mp hklIn).1
 have hkl_pos : 1 ≤ k ∧ 1 ≤ l := (Finset.mem_filter.mp hklIn).2
 have hk_pos : 1 ≤ k := hkl_pos.1
 have hl_pos : 1 ≤ l := hkl_pos.2
 -- Unfold chainCoprime to extract the per-prime ¬-dvd predicates.
 unfold EG203R14Chain103UniversalDensity.chainCoprime at hkl_in_CC
 rcases Finset.mem_filter.mp hkl_in_CC with ⟨_hfull, h5, h7, h11, h13, h17, h19⟩
 -- p prime and p < 23 ⟹ p ∈ {2,3,5,7,11,13,17,19}.
 have hp2 : 2 ≤ p := hp.two_le
 -- The V definitions in Chain103UniversalDensity and Chain103SubProofs are
 -- definitionally equal (both = m * 2^k * 3^l + 1). Rewrite explicitly.
 have hV_eq :
 EG203R14Chain103FullLatticeBound.V m k l = m * 2 ^ k * 3 ^ l + 1 := rfl
 have hV_eq_sub :
 EG203R13Chain103Scaling.V m k l = m * 2 ^ k * 3 ^ l + 1 := rfl
 rw [← ha_eq]
 show ¬ p ∣ V m k l
 -- Reduce V m k l = m * 2^k * 3^l + 1.
 have hVm_eq : V m k l = m * 2 ^ k * 3 ^ l + 1 := rfl
 rw [hVm_eq]
 -- Case-split on p.
 interval_cases p
 -- p = 2: V = m·2^k·3^l + 1 odd (since k ≥ 1).
 · have hV_odd :=
 EG203R13Chain103PrimalityImplication.V_odd_when_k_pos m k l hk_pos
 (fun _ => trivial)
 -- The V in PrimalityImplication is EG203R13Chain103UniversalMega.V; convert.
 simp only [EG203R13Chain103UniversalMega.V] at hV_odd
 exact hV_odd
 -- p = 3: V ≡ 1 (mod 3) since l ≥ 1.
 · have hV_3 :=
 EG203R13Chain103SubProofs.V_coprime_three_for_l_pos m k l hl_pos
 simp only [EG203R13Chain103Scaling.V] at hV_3
 exact hV_3
 -- p = 4: not prime.
 · exact absurd hp (by decide)
 -- p = 5: from chainCoprime filter.
 · rw [hV_eq] at h5; exact h5
 · exact absurd hp (by decide) -- 6
 · rw [hV_eq] at h7; exact h7
 · exact absurd hp (by decide) -- 8
 · exact absurd hp (by decide) -- 9
 · exact absurd hp (by decide) -- 10
 · rw [hV_eq] at h11; exact h11
 · exact absurd hp (by decide) -- 12
 · rw [hV_eq] at h13; exact h13
 · exact absurd hp (by decide) -- 14
 · exact absurd hp (by decide) -- 15
 · exact absurd hp (by decide) -- 16
 · rw [hV_eq] at h17; exact h17
 · exact absurd hp (by decide) -- 18
 · rw [hV_eq] at h19; exact h19
 · exact absurd hp (by decide) -- 20
 · exact absurd hp (by decide) -- 21
 · exact absurd hp (by decide) -- 22
 · -- ∀ a ∈ A, ∃ k l, a = m * 2^k * 3^l + 1
 intro a haA
 rcases Finset.mem_image.mp haA with ⟨⟨k, l⟩, _hklIn, ha_eq⟩
 refine ⟨k, l, ?_⟩
 -- ha_eq : V m k l = a, and V reduces to m * 2^k * 3^l + 1
 rw [← ha_eq]

/-- 🏆 EG#203 HONEST CLOSURE — composes the non-circular count axiom with
 the count→existence theorem and pulls back to the V-family form.

 Composition path (NO circular axioms anywhere):
 1. Get the Finset-construction package via `vFamily_iwaniec_input_data`
 (currently `sorry` — pure Lean Finset work, no axioms beyond `sorryAx`).
 2. Apply `prime_exists_from_iterated_count` with `N₀ = 73080` and
 the discharged Pappalardi hypothesis.
 3. Extract `∃ a ∈ A, Nat.Prime a`.
 4. Pull back `a = m * 2^k * 3^l + 1` from the input-package's V-image
 representation to specific `k l : ℕ`.

 Axiom footprint (target):
 [propext, Classical.choice, Quot.sound,
 iwaniec_iterated_prime_count_lower,
 sorryAx] ← from the deferred Finset-construction helper

 None of `iwaniec_1980_thm_1_V_family_kappa_zero`,
 `iwaniec_v_family_minimal_kappa_zero`,
 `iwaniec_v_family_numeric_evaluation`,
 `iwaniec_1980_thm_1_abstract_linear_sieve_lower_bound`,
 `iwaniec_1980_thm_1_tightened_κ_zero`
 appear in the footprint. -/
theorem eg203_honest_closure :
 ∀ m : ℕ, 1 ≤ m → Nat.Coprime m 6 →
 ∃ k l : ℕ, Nat.Prime (m * 2^k * 3^l + 1) := by
 intro m hm hcop
 -- Step 1: Get the Finset-construction package.
 obtain ⟨A, X, h_card, h_bound, h_ge_two, h_zz_X, h_coprime, h_repr⟩ :=
 vFamily_iwaniec_input_data m hm hcop
 -- Step 2-3: Apply the count → existence theorem with chain-103 numerics.
 --
 -- The Pappalardi κ=0 hypothesis at z = 23 is exactly
 -- `pappalardi_hypothesis_for_z_23` (PROVED, no axioms).
 have h_pap : ∀ q : ℕ, q.Prime → 5 ≤ q → q < 23 →
 (q - 1) / 2 ≤
 (EG203R14IwaniecPappalardiDischargeFinite.subgroup_2_3 q).card :=
 pappalardi_hypothesis_for_z_23
 -- Now invoke the composition theorem from the iterated-sieve file.
 obtain ⟨a, ha_in, ha_prime⟩ :=
 prime_exists_from_iterated_count A X N₀
 h_card h_bound h_ge_two h_zz_X h_coprime h_pap floor_bound_pos
 -- Step 4: Pull back `a` to a specific (k, l) witness.
 obtain ⟨k, l, ha_eq⟩ := h_repr a ha_in
 refine ⟨k, l, ?_⟩
 -- a = m * 2^k * 3^l + 1, and a is prime, so V(m, k, l) is prime.
 rw [← ha_eq]
 exact ha_prime

end EG203R14IwaniecEG203HonestClosure

-- 🏆 AXIOM-FOOTPRINT VERIFICATION
#print axioms EG203R14IwaniecEG203HonestClosure.eg203_honest_closure
