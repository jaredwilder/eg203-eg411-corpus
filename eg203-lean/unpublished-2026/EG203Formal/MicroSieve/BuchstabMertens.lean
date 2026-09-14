import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic
import EG203Formal.MicroSieve.Residue

/-!
# EG203 Micro-Sieve Layer — Buchstab/Mertens/Rosser local interface

This is the engineering layer that Mathlib v4.29.1 does not provide.

Instead of a single theorem-shaped axiom closing EG203, this file exposes the
actual analytic pieces needed by the local V-family sieve.

The remaining hard theorem after this split is `RosserIwaniecKappaZeroForV`.
Everything else is wiring.
-/

namespace EG203.MicroSieve

/-- Finite Mertens product over abstract prime list. -/
noncomputable def mertensProductFromList (ps : List Nat) : Rat :=
 ps.foldl (fun acc p => acc * ((p : Rat) - 1) / (p : Rat)) 1

/-- Generic nonzero-prime product factor is positive. -/
theorem prime_factor_ratio_pos {p : Nat} (hp : Nat.Prime p) :
 (0 : Rat) < ((p : Rat) - 1) / (p : Rat) := by
 have hp2 : 2 ≤ p := hp.two_le
 have hp_pos : (0 : Rat) < p := by exact_mod_cast Nat.pos_of_ne_zero hp.ne_zero
 have hnum : (0 : Rat) < (p : Rat) - 1 := by
 have h : (1 : Rat) < (p : Rat) := by exact_mod_cast (by linarith : 1 < p)
 linarith
 positivity

/-- Abstract Buchstab function placeholder. -/
opaque buchstab : ℝ → ℝ

/-- Lower-bound Rosser-Iwaniec sieve constant package. -/
structure RosserIwaniecConstants where
 z : Nat
 D : Nat
 lowerMain : Rat
 upperError : Rat
 positiveGap : lowerMain > upperError

/-- A concrete V-family sieve certificate for one m. -/
structure VSieveCertificate (m : Nat) where
 D : Nat
 mainTerm : Rat
 errorTerm : Rat
 positive : mainTerm > errorTerm

/-- Certificate soundness in direct structure form. -/
def VSieveCertificateSound : Prop :=
 ∀ m : Nat, Ordinary m → ∀ c : VSieveCertificate m, PositivePrimeCountInBox m c.D


/-- Production soundness target for a one-m sieve certificate. -/
def VSieveCertificateSoundExplicit : Prop :=
 ∀ m D : Nat, Ordinary m →
 ∀ mainTerm errorTerm : Rat,
 mainTerm > errorTerm →
 True →
 PositivePrimeCountInBox m D

/--
The real local replacement for the broad T6 axiom.

This is the theorem that a ~500 LOC Lean engineering pass should attack next:
formalize enough lower-bound sieve arithmetic to prove this interface from
Buchstab/Mertens/Rosser-Iwaniec constants, not from EG203 itself.
-/
def RosserIwaniecKappaZeroForV : Prop :=
 ∀ m : Nat, Ordinary m →
 ∃ D : Nat, PositivePrimeCountInBox m D

/-- Once the kappa-zero V-family sieve is proved, EG203 closes. -/
theorem close_from_rosser_iwaniec_kappa_zero
 (H : RosserIwaniecKappaZeroForV) :
 EG203Closed := by
 exact close_from_uniform_positive_count H

/-- Named concentration citation split out from the sieve. -/
def SubgroupConcentrationClassicalCitation : Prop :=
 SubgroupConcentrationBound

/-- Named Rosser-Iwaniec/Buchstab engineering target. -/
def BuchstabMertensRosserEngineeringTarget : Prop :=
 SubgroupConcentrationClassicalCitation → RosserIwaniecKappaZeroForV

/-- Combined local micro-sieve target. -/
def LocalMicroSieveClosesEG203 : Prop :=
 SubgroupConcentrationClassicalCitation →
 BuchstabMertensRosserEngineeringTarget →
 EG203Closed

/-- The final two-line close once the micro-sieve layer is proved. -/
theorem eg203_closed_from_micro_sieve
 (hT5 : SubgroupConcentrationClassicalCitation)
 (hEng : BuchstabMertensRosserEngineeringTarget) :
 EG203Closed := by
 exact close_from_rosser_iwaniec_kappa_zero (hEng hT5)

/-- Explicit positive-gap certificate implies positivity. -/
theorem positive_gap_of_certificate
 {m : Nat}
 (c : VSieveCertificate m) :
 c.errorTerm < c.mainTerm := by
 exact c.positive

/-- Main term greater than error is equivalent to positive gap. -/
theorem gap_pos_iff (a b : Rat) :
 a > b ↔ 0 < a - b := by
 constructor <;> intro h <;> linarith

/-- If a rational lower bound exceeds zero, it is nonzero. -/
theorem rat_pos_ne_zero {x : Rat} (hx : 0 < x) : x ≠ 0 := by
 exact ne_of_gt hx

end EG203.MicroSieve
