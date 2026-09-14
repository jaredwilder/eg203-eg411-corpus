/-
 EG203Formal/OrderFacts.lean -- Erdős–Graham #203, multiplicative-order facts.

 STATUS: DRAFT. Verified only once `lake build` is clean and the
 `#print axioms` line shows no `sorryAx`.

 `ord_three_ge_three` discharges the `hpos` hypothesis of `size5_abstract`
 (EG203Formal/Size5.lean) for the EG203 instance `o p = orderOf (3 : ZMod p)`:
 every prime `p ≠ 2, 3` has multiplicative order of `3` at least `3`.

 Numerically pre-checked (fact F1) in
 UNIVERSAL_LAW/oracle/math/size5_numeric_check.py
-/
import Mathlib

namespace EG203Formal.OrderFacts

/-- For a prime `p ≠ 2, 3`, the multiplicative order of `3` modulo `p`
is at least `3`. (Order `1` would force `p ∣ 2`, order `2` would force
`p ∣ 8`; both contradict `p ≠ 2`.) -/
theorem ord_three_ge_three {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
 3 ≤ orderOf (3 : ZMod p) := by
 haveI : Fact p.Prime := ⟨hp⟩
 -- `3` is nonzero mod `p` (else `p ∣ 3`, forcing `p = 3`).
 have h3ne0 : (3 : ZMod p) ≠ 0 := by
 intro h
 have hcast : ((3 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
 have hdvd : p ∣ 3 := (CharP.cast_eq_zero_iff (ZMod p) p 3).mp hcast
 exact hp3 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp hdvd)
 -- `3 ≠ 1` mod `p` (else `p ∣ 2`, forcing `p = 2`).
 have h3ne1 : (3 : ZMod p) ≠ 1 := by
 intro h
 have h2 : (2 : ZMod p) = 0 := by
 have e : (2 : ZMod p) = (3 : ZMod p) - 1 := by norm_num
 rw [e, h, sub_self]
 have hcast : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h2
 have hdvd : p ∣ 2 := (CharP.cast_eq_zero_iff (ZMod p) p 2).mp hcast
 exact hp2 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp hdvd)
 -- `3 ^ 2 ≠ 1` mod `p` (else `p ∣ 8`, forcing `p = 2`).
 have h3sq : (3 : ZMod p) ^ 2 ≠ 1 := by
 intro h
 have h8 : (8 : ZMod p) = 0 := by
 have e : (8 : ZMod p) = (3 : ZMod p) ^ 2 - 1 := by norm_num
 rw [e, h, sub_self]
 have hcast : ((8 : ℕ) : ZMod p) = 0 := by exact_mod_cast h8
 have hd8 : p ∣ 8 := (CharP.cast_eq_zero_iff (ZMod p) p 8).mp hcast
 have hd2 : p ∣ 2 := by
 have h23 : p ∣ 2 ^ 3 := by rwa [show (8 : ℕ) = 2 ^ 3 by norm_num] at hd8
 exact hp.dvd_of_dvd_pow h23
 exact hp2 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp hd2)
 -- `orderOf 3 ≠ 0`: it divides `p - 1`, which is positive, by Fermat.
 have hdvd : orderOf (3 : ZMod p) ∣ (p - 1) :=
 orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one h3ne0)
 have hp2le : 2 ≤ p := hp.two_le
 have hne0 : orderOf (3 : ZMod p) ≠ 0 := by
 intro h
 rw [h] at hdvd
 have := Nat.eq_zero_of_zero_dvd hdvd
 omega
 -- `orderOf 3 ≠ 1` and `≠ 2`.
 have hne1 : orderOf (3 : ZMod p) ≠ 1 := fun h => h3ne1 (orderOf_eq_one_iff.mp h)
 have hne2 : orderOf (3 : ZMod p) ≠ 2 := by
 intro h
 apply h3sq
 have hpow := pow_orderOf_eq_one (3 : ZMod p)
 rw [h] at hpow
 exact hpow
 omega

#print axioms ord_three_ge_three

end EG203Formal.OrderFacts
