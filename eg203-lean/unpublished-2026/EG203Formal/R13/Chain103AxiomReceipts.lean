import EG203Formal.R13.Chain103PerPrimeBounds
import EG203Formal.R13.Chain103JointBoundNativeDecide
import EG203Formal.R13.Chain103UniversalBounded
import EG203Formal.R13.Chain103UniversalLarge
import EG203Formal.R13.Chain103UniversalMega
import EG203Formal.R13.Chain103PrimalityImplication
import EG203Formal.R13.Chain103PeriodicityCRT
import EG203Formal.R13.Chain103UniversalReduction
import EG203Formal.R13.Chain103UnconditionalScaffold

/-!
# Chain 103 R13 — AXIOM RECEIPTS file

Produces #print axioms output for every key theorem from the 2026-06-02
real number theorist session. Run this file to capture axiom footprints.
-/

-- 1. PerPrimeBounds (Sylow-2 obstruction enumeration)
#print axioms EG203R13Chain103PerPrimeBounds.q5_obstr_m1
#print axioms EG203R13Chain103PerPrimeBounds.q5_obstr_m19

-- 2. JointBoundNativeDecide
#print axioms EG203R13Chain103JointBoundNativeDecide.joint_m19
#print axioms EG203R13Chain103JointBoundNativeDecide.exists_chain_coprime_m19

-- 3. UniversalBounded (m ≤ 500)
#print axioms EG203R13Chain103UniversalBounded.chain_103_bounded_500_32
#print axioms EG203R13Chain103UniversalBounded.exists_chain_coprime_nat_bounded_200

-- 4. UniversalLarge (m ≤ 5000)
#print axioms EG203R13Chain103UniversalLarge.chain_103_bounded_5000
#print axioms EG203R13Chain103UniversalLarge.exists_chain_coprime_nat_bounded_5000

-- 5. UniversalMega (m ≤ 25000)
#print axioms EG203R13Chain103UniversalMega.chain_103_bounded_25000
#print axioms EG203R13Chain103UniversalMega.exists_chain_coprime_nat_bounded_25000

-- 6. PrimalityImplication
#print axioms EG203R13Chain103PrimalityImplication.V_odd_when_k_pos
#print axioms EG203R13Chain103PrimalityImplication.chain_coprime_odd_smallest_prime_factor_at_least_23
#print axioms EG203R13Chain103PrimalityImplication.chain_coprime_with_k_pos_smallest_prime_at_least_23

-- 7. PeriodicityCRT
#print axioms EG203R13Chain103PeriodicityCRT.V_mod_q_depends_on_m_mod_q
#print axioms EG203R13Chain103PeriodicityCRT.not_dvd_V_transport
#print axioms EG203R13Chain103PeriodicityCRT.chain_coprime_periodic

-- 8. UniversalReduction
#print axioms EG203R13Chain103UniversalReduction.bounded_implies_universal
#print axioms EG203R13Chain103UniversalReduction.bounded_ordinary_implies_universal_ordinary

-- 9. UnconditionalScaffold (THE keystone)
#print axioms EG203R13Chain103UnconditionalScaffold.chain_103_unconditional_from_bounded
