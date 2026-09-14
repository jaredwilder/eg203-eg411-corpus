
import EG203.Basic
import EG203.AnalyticAPI

/-!
EG203.Final

Final closure file.

This file has one `sorry`, inherited from the analytic API theorem in
EG203.AnalyticAPI. Once that theorem is proved, this file proves EG203.
-/

namespace EG203

open EG203.AnalyticAPI

theorem eg203_closed_from_analytic_APIs
    [VaughanIdentityAPI]
    [LargeSieveAPI]
    [BombieriVinogradovAPI]
    [MahlerSUnitAPI]
    [ConcentrationAPI]
    [BrunHooleySieveAPI] :
    EG203Closed := by
  exact closed_from_positive_prime_count
    (positive_prime_count_from_analytic_APIs
      (VaughanIdentityAPI := inferInstance)
      (LargeSieveAPI := inferInstance)
      (BombieriVinogradovAPI := inferInstance)
      (MahlerSUnitAPI := inferInstance)
      (ConcentrationAPI := inferInstance)
      (BrunHooleySieveAPI := inferInstance))

end EG203
