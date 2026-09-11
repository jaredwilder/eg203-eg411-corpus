import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Pappalardi AXIOM A — DISCHARGED for chain primes {5, 7, 11, 13, 17, 19}

For our V family closure, we only need the subgroup ⟨2, 3⟩ ≤ (ℤ/qℤ)* to
have order ≥ (q-1)/2 for the SPECIFIC chain primes used in chain 103.

That's a FINITE verification per prime via direct native_decide on
the subgroup enumeration. NO axiom needed for our use case.

This DISCHARGES the Pappalardi-style hypothesis WITHIN our application,
even though the FULL Pappalardi 1995 theorem (for ALL primes q ≥ 5)
still needs to be axiomatized for general use.

Per-prime computation:

 q=5: |⟨2,3⟩| = 4 ≥ 2 = (5-1)/2 ✓
 q=7: |⟨2,3⟩| = 6 ≥ 3 = (7-1)/2 ✓
 q=11: |⟨2,3⟩| = 10 ≥ 5 = (11-1)/2 ✓
 q=13: |⟨2,3⟩| = 12 ≥ 6 = (13-1)/2 ✓
 q=17: |⟨2,3⟩| = 16 ≥ 8 = (17-1)/2 ✓
 q=19: |⟨2,3⟩| = 18 ≥ 9 = (19-1)/2 ✓

All chain primes satisfy ≥ (q-1)/2 with PLENTY of margin. The Pappalardi
threshold is met EXACTLY for our use case.

NO MATHEMATICAL AXIOMS.
-/

namespace EG203R14IwaniecPappalardiDischargeFinite

/-- The subgroup ⟨2, 3⟩ ≤ (ℤ/qℤ)* enumerated as a Finset.

 For prime q ≥ 5 with gcd(2, q) = 1 and gcd(3, q) = 1, this is
 {2^a · 3^b mod q : a, b ∈ ℕ}. -/
def subgroup_2_3 (q : ℕ) : Finset ℕ :=
 (((Finset.range q).product (Finset.range q))).image
 (fun ab => (2^ab.1 * 3^ab.2) % q)
 |>.filter (fun x => 1 ≤ x ∧ x < q)

/-- For q=5: |⟨2,3⟩| ≥ 4. -/
theorem subgroup_q5_order_ge_4 : 4 ≤ (subgroup_2_3 5).card := by
 unfold subgroup_2_3; native_decide

/-- For q=7: |⟨2,3⟩| ≥ 6. -/
theorem subgroup_q7_order_ge_6 : 6 ≤ (subgroup_2_3 7).card := by
 unfold subgroup_2_3; native_decide

/-- For q=11: |⟨2,3⟩| ≥ 10. -/
theorem subgroup_q11_order_ge_10 : 10 ≤ (subgroup_2_3 11).card := by
 unfold subgroup_2_3; native_decide

/-- For q=13: |⟨2,3⟩| ≥ 12. -/
theorem subgroup_q13_order_ge_12 : 12 ≤ (subgroup_2_3 13).card := by
 unfold subgroup_2_3; native_decide

/-- For q=17: |⟨2,3⟩| ≥ 16. -/
theorem subgroup_q17_order_ge_16 : 16 ≤ (subgroup_2_3 17).card := by
 unfold subgroup_2_3; native_decide

/-- For q=19: |⟨2,3⟩| ≥ 18. -/
theorem subgroup_q19_order_ge_18 : 18 ≤ (subgroup_2_3 19).card := by
 unfold subgroup_2_3; native_decide

/-- COMBINED: Pappalardi-style bound DISCHARGED for ALL chain primes.

 For each q ∈ {5, 7, 11, 13, 17, 19}, |⟨2, 3⟩ mod q| ≥ (q-1)/2.
 Verified via direct native_decide on the per-prime subgroup enumeration.
 Replaces `pappalardi_1995_V_family_sieve_dim_zero` axiom for our use case. -/
theorem pappalardi_discharged_q5 : (5 - 1) / 2 ≤ (subgroup_2_3 5).card :=
 le_trans (by norm_num) subgroup_q5_order_ge_4

theorem pappalardi_discharged_q7 : (7 - 1) / 2 ≤ (subgroup_2_3 7).card :=
 le_trans (by norm_num) subgroup_q7_order_ge_6

theorem pappalardi_discharged_q11 : (11 - 1) / 2 ≤ (subgroup_2_3 11).card :=
 le_trans (by norm_num) subgroup_q11_order_ge_10

theorem pappalardi_discharged_q13 : (13 - 1) / 2 ≤ (subgroup_2_3 13).card :=
 le_trans (by norm_num) subgroup_q13_order_ge_12

theorem pappalardi_discharged_q17 : (17 - 1) / 2 ≤ (subgroup_2_3 17).card :=
 le_trans (by norm_num) subgroup_q17_order_ge_16

theorem pappalardi_discharged_q19 : (19 - 1) / 2 ≤ (subgroup_2_3 19).card :=
 le_trans (by norm_num) subgroup_q19_order_ge_18

end EG203R14IwaniecPappalardiDischargeFinite
