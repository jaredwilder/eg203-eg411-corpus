
import EG203_close_gate.Analytic.Sieve

/-!
EG203.Analytic.AxiomatizedClose

This file gives the exact axiomatized close.  This is not an unconditional proof.
It is useful for checking that the final analytic package has the right shape.
-/

namespace EG203

open EG203.Analytic

axiom full_analytic_package_axiom : FullAnalyticPackage

theorem eg203_closed_axiomatized : EG203Closed := by
  exact closed_from_positive_prime_count
    (positive_prime_count_from_full_analytic_package full_analytic_package_axiom)

end EG203
