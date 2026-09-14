
import EG203.Analytic.Sieve

/-!
EG203.Analytic.ProveIt

This is the real proving file. Remove the `sorry` by proving the six-component
analytic package.
-/

namespace EG203

open EG203.Analytic

theorem full_analytic_package : FullAnalyticPackage := by
  -- Third-pass active proving target.
  --
  -- Supply:
  -- 1. VaughanHeathBrownDecomposition
  -- 2. TypeIDistributionEstimate
  -- 3. TypeIISUnitDifferenceEstimate
  -- 4. ShortRelationLatticeControl
  -- 5. SubgroupConcentrationEstimate
  -- 6. BrunHooleyParityBreakingSieve
  sorry

theorem eg203_closed : EG203Closed := by
  exact closed_from_positive_prime_count
    (positive_prime_count_from_full_analytic_package full_analytic_package)

end EG203
