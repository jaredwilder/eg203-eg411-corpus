/-
 EG203ConditionalClosure.lean — 2026-06-01

 Translates the EG#411 r=2 closure template to EG#203, exposing
 EXACTLY where the missing analytic input enters.

 EG#411 r=2 closure (EG411Formal/EG411R2Closure.lean) has shape:

 Cambie-reduction-hypothesis → finite-checkable-list → Lean closure

 where the Cambie reduction is supplied by literature (Cambie 2024) and
 the above-threshold case uses Rosser-Schoenfeld 1962.

 EG#203 admits the SAME LEAN STRUCTURE under the analogous hypothesis
 `RankTwoAffineSUnitPrimeProduction`, which IS the conjecture itself
 under a different name. The conditional closure is kernel-verified and
 axiom-pure; it does NOT prove EG#203 unconditionally because the
 hypothesis is the open problem.

 ALL THREE PROVIDER CLASSES converge on this conclusion:
 - GPT Round 055 KILLSHOT-VERDICT (Jun 1 03:35): no unconditional close
 - Codex FINDINGS.md (2026-06-01 updates): UNIVERSAL_NOT_PROMOTED
 - this session (chains 85-104): bounded scope max'd, universal open

 What this file DOES prove kernel-verified:
 1. EG203Closed ↔ RankTwoAffineSUnitPrimeProduction (definitional)
 2. Cross-reference to N=300000 bounded closure (chain 86)
 3. The conditional-close from prime production hypothesis

 What this file does NOT prove (and clearly states it doesn't):
 - RankTwoAffineSUnitPrimeProduction itself
-/
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Formal
namespace ConditionalClosure

/-- The basic V form used throughout EG203 work. -/
@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/-- m is "ordinary" if coprime to 6 (i.e., not divisible by 2 or 3). -/
def Ordinary (m : Nat) : Prop := Nat.Coprime m 6

/-- The full EG#203 universal closure proposition. -/
def EG203Closed : Prop :=
 ∀ m : Nat, 1 ≤ m → Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/-- The same conjecture under the "rank-two affine S-unit prime production"
 framing identified by every external review (GPT Round 055, Codex Round 049,
 Round 048 LEAN-FIRST, the swarm 20260601T112939Z). -/
def RankTwoAffineSUnitPrimeProduction : Prop :=
 ∀ m : Nat, 1 ≤ m → Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/-- DEFINITIONAL EQUIVALENCE. The two formulations are the same proposition
 expressed under different names. This is the kernel-checked version of
 the "exact_equivalence" theorem from GPT Round 055 KillshotVerdict.lean. -/
theorem EG203_iff_rank_two_prime_production :
 EG203Closed ↔ RankTwoAffineSUnitPrimeProduction := by
 constructor <;> intro h <;> exact h

#print axioms EG203_iff_rank_two_prime_production

/-- EG#411-template conditional closure: under the analytic hypothesis
 `RankTwoAffineSUnitPrimeProduction`, EG#203 closes.

 This is the EXACT analogue of the EG#411 r=2 closure:
 EG#411 closes ← Cambie tail dichotomy (literature)
 EG#203 closes ← rank-two prime production (OPEN)

 The Lean STRUCTURE is identical; the difference is the supply
 of the input hypothesis from external mathematics. -/
theorem eg203_closure_from_prime_production :
 RankTwoAffineSUnitPrimeProduction → EG203Closed :=
 (EG203_iff_rank_two_prime_production).mpr

#print axioms eg203_closure_from_prime_production

/-- The contrapositive: a counterexample to EG#203 IS a counterexample to
 rank-two affine S-unit prime production. The two failure modes coincide. -/
theorem eg203_counterexample_iff_prime_production_failure :
 (¬ EG203Closed) ↔ (¬ RankTwoAffineSUnitPrimeProduction) := by
 constructor
 · intro h
 exact fun hp => h (EG203_iff_rank_two_prime_production.mpr hp)
 · intro h
 exact fun hp => h (EG203_iff_rank_two_prime_production.mp hp)

#print axioms eg203_counterexample_iff_prime_production_failure

-- BOUNDED BASE CASE: m ≤ 300000 is kernel-verified UNCONDITIONALLY in
-- EG203BoundedClosure.EG203_nat_form_for_ordinary_m_up_to_300000.
-- It is NOT replicated here (would be redundant + would need an import).
-- See chain 86 in the internal research notes for the actual kernel receipt.

/-- The honest universal-closure status: EG#203 closure is provable iff
 a research-level analytic theorem holds. This file does NOT supply
 that theorem; no current method does. -/
theorem eg203_universal_closure_status :
 EG203Closed ↔ RankTwoAffineSUnitPrimeProduction := EG203_iff_rank_two_prime_production

#print axioms eg203_universal_closure_status

end ConditionalClosure
end EG203Formal
