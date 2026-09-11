import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Chain103UniversalObstruction

/-!
# Chain 103 universal chain-coprime density bound

P0.4 — Combine per-prime universal obstruction bounds via union bound:
 |obstr ∃-set| ≤ Σ |obstr q-set| ≤ 186120
 |chain-coprime ∀-set| = total - |obstr ∃-set| ≥ 259200 - 186120 = 73080

UNIVERSAL in m. NO MATHEMATICAL AXIOMS.
-/

set_option maxRecDepth 4000

namespace EG203R14Chain103UniversalDensity

open EG203R14Chain103FullLatticeBound EG203R14Chain103UniversalObstruction

@[reducible] def fullLattice : Finset (ℕ × ℕ) :=
 (Finset.range 360).product (Finset.range 720)

theorem fullLattice_card : fullLattice.card = 259200 := by
 show ((Finset.range 360).product (Finset.range 720)).card = 259200
 simp [Finset.card_product]

/-- The "some chain prime divides V" obstruction set. -/
def obstrAny (m : ℕ) : Finset (ℕ × ℕ) :=
 fullLattice.filter (fun kl => 5 ∣ V m kl.1 kl.2 ∨ 7 ∣ V m kl.1 kl.2 ∨
 11 ∣ V m kl.1 kl.2 ∨ 13 ∣ V m kl.1 kl.2 ∨
 17 ∣ V m kl.1 kl.2 ∨ 19 ∣ V m kl.1 kl.2)

/-- The "all chain primes coprime to V" set. -/
def chainCoprime (m : ℕ) : Finset (ℕ × ℕ) :=
 fullLattice.filter (fun kl => ¬ (5 ∣ V m kl.1 kl.2) ∧ ¬ (7 ∣ V m kl.1 kl.2) ∧
 ¬ (11 ∣ V m kl.1 kl.2) ∧ ¬ (13 ∣ V m kl.1 kl.2) ∧
 ¬ (17 ∣ V m kl.1 kl.2) ∧ ¬ (19 ∣ V m kl.1 kl.2))

/-- The two sets partition fullLattice. -/
theorem obstrAny_chainCoprime_partition (m : ℕ) :
 (obstrAny m).card + (chainCoprime m).card = fullLattice.card := by
 unfold obstrAny chainCoprime
 have h := Finset.card_filter_add_card_filter_not
 (s := fullLattice) (p := fun kl : ℕ × ℕ =>
 5 ∣ V m kl.1 kl.2 ∨ 7 ∣ V m kl.1 kl.2 ∨
 11 ∣ V m kl.1 kl.2 ∨ 13 ∣ V m kl.1 kl.2 ∨
 17 ∣ V m kl.1 kl.2 ∨ 19 ∣ V m kl.1 kl.2)
 -- Show chainCoprime filter matches the ¬-version
 have h_eq : fullLattice.filter (fun kl => ¬ (5 ∣ V m kl.1 kl.2 ∨ 7 ∣ V m kl.1 kl.2 ∨
 11 ∣ V m kl.1 kl.2 ∨ 13 ∣ V m kl.1 kl.2 ∨
 17 ∣ V m kl.1 kl.2 ∨ 19 ∣ V m kl.1 kl.2)) =
 fullLattice.filter (fun kl => ¬ (5 ∣ V m kl.1 kl.2) ∧ ¬ (7 ∣ V m kl.1 kl.2) ∧
 ¬ (11 ∣ V m kl.1 kl.2) ∧ ¬ (13 ∣ V m kl.1 kl.2) ∧
 ¬ (17 ∣ V m kl.1 kl.2) ∧ ¬ (19 ∣ V m kl.1 kl.2)) := by
 apply Finset.filter_congr
 intro kl _
 push_neg
 tauto
 rw [← h_eq]
 exact h

/-- Obstruction set decomposes into union of per-prime obstructions. -/
theorem obstrAny_eq_union (m : ℕ) :
 obstrAny m = (fullLattice.filter (fun kl => 5 ∣ V m kl.1 kl.2)) ∪
 (fullLattice.filter (fun kl => 7 ∣ V m kl.1 kl.2)) ∪
 (fullLattice.filter (fun kl => 11 ∣ V m kl.1 kl.2)) ∪
 (fullLattice.filter (fun kl => 13 ∣ V m kl.1 kl.2)) ∪
 (fullLattice.filter (fun kl => 17 ∣ V m kl.1 kl.2)) ∪
 (fullLattice.filter (fun kl => 19 ∣ V m kl.1 kl.2)) := by
 unfold obstrAny
 ext kl
 simp [Finset.mem_filter, Finset.mem_union]
 tauto

/-- Helper: union of 6 Finsets has card ≤ sum of individual cards. -/
lemma card_union6_le {α : Type*} [DecidableEq α] (A B C D E F : Finset α) :
 (A ∪ B ∪ C ∪ D ∪ E ∪ F).card ≤ A.card + B.card + C.card + D.card + E.card + F.card := by
 have h1 : (A ∪ B).card ≤ A.card + B.card := Finset.card_union_le A B
 have h2 : (A ∪ B ∪ C).card ≤ (A ∪ B).card + C.card := Finset.card_union_le (A ∪ B) C
 have h3 : (A ∪ B ∪ C ∪ D).card ≤ (A ∪ B ∪ C).card + D.card := Finset.card_union_le (A ∪ B ∪ C) D
 have h4 : (A ∪ B ∪ C ∪ D ∪ E).card ≤ (A ∪ B ∪ C ∪ D).card + E.card :=
 Finset.card_union_le (A ∪ B ∪ C ∪ D) E
 have h5 : (A ∪ B ∪ C ∪ D ∪ E ∪ F).card ≤ (A ∪ B ∪ C ∪ D ∪ E).card + F.card :=
 Finset.card_union_le (A ∪ B ∪ C ∪ D ∪ E) F
 omega

/-- obstr_full_q for fullLattice unfolds correctly via rfl. -/
private lemma obstr_eq_fullLattice (q m : ℕ) :
 obstr_full_q q m = (fullLattice.filter (fun kl => q ∣ V m kl.1 kl.2)).card := rfl

/-- Union bound: |obstrAny m| ≤ Σ per-prime obstruction counts ≤ 186120. -/
theorem obstrAny_card_le_186120 (m : ℕ) : (obstrAny m).card ≤ 186120 := by
 rw [obstrAny_eq_union]
 have h5 := obstr_full_q5_universal m
 have h7 := obstr_full_q7_universal m
 have h11 := obstr_full_q11_universal m
 have h13 := obstr_full_q13_universal m
 have h17 := obstr_full_q17_universal m
 have h19 := obstr_full_q19_universal m
 rw [obstr_eq_fullLattice] at h5 h7 h11 h13 h17 h19
 have h_union := card_union6_le
 (fullLattice.filter (fun kl => 5 ∣ V m kl.1 kl.2))
 (fullLattice.filter (fun kl => 7 ∣ V m kl.1 kl.2))
 (fullLattice.filter (fun kl => 11 ∣ V m kl.1 kl.2))
 (fullLattice.filter (fun kl => 13 ∣ V m kl.1 kl.2))
 (fullLattice.filter (fun kl => 17 ∣ V m kl.1 kl.2))
 (fullLattice.filter (fun kl => 19 ∣ V m kl.1 kl.2))
 omega

/-- THE UNIVERSAL CHAIN-COPRIME DENSITY THEOREM:
 For ALL m, the (360, 720) lattice has ≥ 73080 chain-coprime cells. -/
theorem chain_coprime_count_ge_73080 (m : ℕ) :
 73080 ≤ (chainCoprime m).card := by
 have h_partition : (obstrAny m).card + (chainCoprime m).card = fullLattice.card :=
 obstrAny_chainCoprime_partition m
 have h_obstr : (obstrAny m).card ≤ 186120 := obstrAny_card_le_186120 m
 have h_total : fullLattice.card = 259200 := fullLattice_card
 omega

end EG203R14Chain103UniversalDensity
