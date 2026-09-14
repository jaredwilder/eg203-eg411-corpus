
import EG203.Analytic.Parameters
import EG203.Analytic.Vaughan
import EG203.Analytic.TypeI
import EG203.Analytic.TypeII
import EG203.Analytic.ShortRelations
import EG203.Analytic.Concentration

/-!
EG203.Analytic.Sieve

Brun-Hooley parity-breaking lower-bound endpoint.
-/

namespace EG203.Analytic

open EG203

def BrunHooleyParityBreakingSieve : Prop :=
  VaughanHeathBrownDecomposition →
  TypeIDistributionEstimate →
  TypeIISUnitDifferenceEstimate →
  ShortRelationLatticeControl →
  SubgroupConcentrationEstimate →
  PositivePrimeCountInBox

def FullAnalyticPackage : Prop :=
  VaughanHeathBrownDecomposition ∧
  TypeIDistributionEstimate ∧
  TypeIISUnitDifferenceEstimate ∧
  ShortRelationLatticeControl ∧
  SubgroupConcentrationEstimate ∧
  BrunHooleyParityBreakingSieve

theorem positive_prime_count_from_full_analytic_package
    (h : FullAnalyticPackage) :
    PositivePrimeCountInBox := by
  rcases h with ⟨hV,hI,hII,hShort,hConc,hSieve⟩
  exact hSieve hV hI hII hShort hConc

end EG203.Analytic
