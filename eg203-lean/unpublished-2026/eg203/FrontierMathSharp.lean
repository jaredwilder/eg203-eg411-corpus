import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Nlinarith

namespace FrontierMath

theorem sharpFourthPower (a b λ : ℝ) (hλ : λ ≤ (1 : ℝ) / 16) :
    ((a + b) / 2)^4 + λ * (a - b)^4 ≤ (a^4 + b^4) / 2 := by
  let m : ℝ := (a + b) / 2
  let d : ℝ := (a - b) / 2
  have hidentity :
      (a^4 + b^4) / 2 - ((a + b) / 2)^4 - λ * (a - b)^4 =
        6 * m^2 * d^2 + (1 - 16 * λ) * d^4 := by
    dsimp [m, d]
    ring
  have hcoef : 0 ≤ 1 - 16 * λ := by
    nlinarith
  have hm : 0 ≤ m^2 := sq_nonneg m
  have hd : 0 ≤ d^2 := sq_nonneg d
  have hfirst : 0 ≤ 6 * m^2 * d^2 := by positivity
  have hsecond : 0 ≤ (1 - 16 * λ) * d^4 := by
    exact mul_nonneg hcoef (by positivity)
  have hnonneg : 0 ≤ 6 * m^2 * d^2 + (1 - 16 * λ) * d^4 := add_nonneg hfirst hsecond
  nlinarith [hidentity]

end FrontierMath
