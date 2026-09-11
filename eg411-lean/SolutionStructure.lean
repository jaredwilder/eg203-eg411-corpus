import Mathlib.Algebra.Group.Basic
import Mathlib.Algebra.Order.Group.Nat
import Mathlib.Algebra.Squarefree.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Nat.Totient
import Mathlib.Data.Nat.Squarefree
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# EG#411 (r=2): structure of solutions of the totient equation (2026-06-10)

For `n : ℕ` satisfying `3·φ(n) = 2n + 2` (the Steinerberger/Hercher totient equation that
EG#411 r=2 reduces to — see `RealResult.lean`), we prove the structural facts:

  • `solution_odd`               — `n` is odd
  • `solution_not_three_dvd`     — `3 ∤ n`
  • `solution_squarefree`        — `n` is squarefree
  • `solution_no_prime_chain`    — no prime divisor `r` of `n` divides `s − 1` for a
                                   prime divisor `s` of `n`
  • `solution_prime_eq_five`     — if `n` is prime then `n = 5`
  • `solution_two_primes`        — if `n = p·q` (`p < q` primes) then `n = 35`
  • `solution_min_prime_ge_five` — every prime divisor of `n` is `≥ 5`

These match the brute-force-verified ground truth: the only solutions with `ω(n) ≤ 4` are
`5`, `35`, `1295 = 5·7·37`, `1679615 = 5·7·37·1297`.

Fully axiom-free: every theorem here reports only `{propext, Classical.choice, Quot.sound}`
(no `native_decide`, no project-local axiom).

The common engine: if a prime `r` divides `φ(n)`, then `r ∣ 3·φ(n) = 2n + 2`; if also
`r ∣ n` then `r ∣ 2`, so `r = 2` — impossible since `n` is odd.
-/

namespace EG411Structure

/-! ## 1. Solutions are odd -/

/-- A solution of `3·φ(n) = 2n + 2` is odd. (For even `n`, `φ(n) ≤ n/2`,
so `3·φ(n) ≤ 3n/2 < 2n + 2`.) -/
theorem solution_odd {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) : ¬ 2 ∣ n := by
  intro h2
  have hn0 : n ≠ 0 := by rintro rfl; simp at hn
  -- Write `n = 2^(f+1) * m` with `m` odd, via the factorization of `2` in `n`.
  obtain ⟨f, hf⟩ : ∃ f, n.factorization 2 = f + 1 :=
    ⟨n.factorization 2 - 1, by
      have := Nat.Prime.factorization_pos_of_dvd Nat.prime_two hn0 h2
      omega⟩
  have hsplit : 2 ^ (f + 1) * (n / 2 ^ (f + 1)) = n := by
    rw [← hf]; exact Nat.ordProj_mul_ordCompl_eq_self n 2
  have hcop : Nat.Coprime (2 ^ (f + 1)) (n / 2 ^ (f + 1)) := by
    rw [← hf]
    exact Nat.Coprime.pow_left _ (Nat.coprime_ordCompl Nat.prime_two hn0)
  have hphi : Nat.totient n
      = Nat.totient (2 ^ (f + 1)) * Nat.totient (n / 2 ^ (f + 1)) := by
    conv_lhs => rw [← hsplit]
    exact Nat.totient_mul hcop
  have hphi2 : Nat.totient (2 ^ (f + 1)) = 2 ^ f := by
    rw [Nat.totient_prime_pow_succ Nat.prime_two]
    norm_num
  have hle : Nat.totient (n / 2 ^ (f + 1)) ≤ n / 2 ^ (f + 1) := Nat.totient_le _
  -- `2·φ(n) ≤ n`, the even-case totient bound.
  have hkey : 2 * Nat.totient n ≤ n := by
    calc 2 * Nat.totient n
        = 2 * (2 ^ f * Nat.totient (n / 2 ^ (f + 1))) := by rw [hphi, hphi2]
      _ = 2 ^ (f + 1) * Nat.totient (n / 2 ^ (f + 1)) := by ring
      _ ≤ 2 ^ (f + 1) * (n / 2 ^ (f + 1)) := by gcongr
      _ = n := hsplit
  -- `3·φ(n) = 2n + 2` and `2·φ(n) ≤ n` force `4n + 4 ≤ 3n`: absurd.
  omega

/-! ## 2. Solutions are not divisible by 3 -/

/-- A solution of `3·φ(n) = 2n + 2` is not divisible by `3`
(`3 ∣ LHS` but `RHS ≡ 2 (mod 3)` when `3 ∣ n`). -/
theorem solution_not_three_dvd {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) : ¬ 3 ∣ n := by
  rintro ⟨k, rfl⟩
  omega

/-! ## 3. Every prime divisor is ≥ 5 -/

/-- Every prime divisor of a solution is at least `5` (it is odd and prime to `3`). -/
theorem solution_min_prime_ge_five {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) :
    ∀ q, q.Prime → q ∣ n → 5 ≤ q := by
  intro q hq hqn
  have hq2 : q ≠ 2 := by rintro rfl; exact solution_odd hn hqn
  have hq3 : q ≠ 3 := by rintro rfl; exact solution_not_three_dvd hn hqn
  have hq4 : q ≠ 4 := by rintro rfl; exact absurd hq (by decide)
  have := hq.two_le
  omega

/-! ## 4. Solutions are squarefree -/

/-- A solution of `3·φ(n) = 2n + 2` is squarefree. (If `q² ∣ n` then `q ∣ φ(n)`,
so `q ∣ 3·φ(n) = 2n + 2`; with `q ∣ n` this gives `q ∣ 2`, i.e. `q = 2` — but `n` is odd.) -/
theorem solution_squarefree {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) : Squarefree n := by
  have hn0 : n ≠ 0 := by rintro rfl; simp at hn
  rw [Nat.squarefree_iff_prime_squarefree]
  intro q hqp hsq
  have hq2 : q ^ 2 ∣ n := by rwa [pow_two]
  have hqn : q ∣ n := (dvd_pow_self q (by norm_num)).trans hq2
  -- The exponent of `q` in `n` is at least `2`: write it as `f + 2`.
  obtain ⟨f, hf⟩ : ∃ f, n.factorization q = f + 2 :=
    ⟨n.factorization q - 2, by
      have h2le : 2 ≤ n.factorization q :=
        (Nat.Prime.pow_dvd_iff_le_factorization hqp hn0).mp hq2
      omega⟩
  have hsplit : q ^ (f + 2) * (n / q ^ (f + 2)) = n := by
    rw [← hf]; exact Nat.ordProj_mul_ordCompl_eq_self n q
  have hcop : Nat.Coprime (q ^ (f + 2)) (n / q ^ (f + 2)) := by
    rw [← hf]
    exact Nat.Coprime.pow_left _ (Nat.coprime_ordCompl hqp hn0)
  have hphi : Nat.totient n
      = Nat.totient (q ^ (f + 2)) * Nat.totient (n / q ^ (f + 2)) := by
    conv_lhs => rw [← hsplit]
    exact Nat.totient_mul hcop
  have hphiq : Nat.totient (q ^ (f + 2)) = q ^ (f + 1) * (q - 1) :=
    Nat.totient_prime_pow_succ hqp (f + 1)
  -- `q ∣ φ(n)` since `q ∣ q^(f+1)`.
  have hqdvdphi : q ∣ Nat.totient n := by
    rw [hphi, hphiq]
    exact dvd_mul_of_dvd_left (dvd_mul_of_dvd_left (dvd_pow_self q (Nat.succ_ne_zero f)) _) _
  have h4 : q ∣ 2 * n + 2 := hn ▸ hqdvdphi.mul_left 3
  have h5 : q ∣ 2 * n := hqn.mul_left 2
  have h6 : q ∣ 2 := by
    have hsub := Nat.dvd_sub h4 h5
    have h22 : 2 * n + 2 - 2 * n = 2 := by omega
    rwa [h22] at hsub
  have h7 : q = 2 := (Nat.prime_dvd_prime_iff_eq hqp Nat.prime_two).mp h6
  exact solution_odd hn (h7 ▸ hqn)

/-! ## 5. No prime chains among the divisors -/

/-- No prime divisor `r` of a solution divides `s − 1` for a prime divisor `s`.
(`s ∣ n ⟹ φ(s) = s − 1 ∣ φ(n)`, so `r ∣ φ(n) ⟹ r ∣ 2n + 2`; with `r ∣ n`, `r ∣ 2` —
but `n` is odd.) -/
theorem solution_no_prime_chain {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) :
    ∀ r s : ℕ, r.Prime → s.Prime → r ∣ n → s ∣ n → ¬ r ∣ (s - 1) := by
  intro r s hr hs hrn hsn hdvd
  have h1 : Nat.totient s ∣ Nat.totient n := Nat.totient_dvd_of_dvd hsn
  have h2 : r ∣ Nat.totient n := by
    refine dvd_trans ?_ h1
    rwa [Nat.totient_prime hs]
  have h4 : r ∣ 2 * n + 2 := hn ▸ h2.mul_left 3
  have h5 : r ∣ 2 * n := hrn.mul_left 2
  have h6 : r ∣ 2 := by
    have hsub := Nat.dvd_sub h4 h5
    have h22 : 2 * n + 2 - 2 * n = 2 := by omega
    rwa [h22] at hsub
  have h7 : r = 2 := (Nat.prime_dvd_prime_iff_eq hr Nat.prime_two).mp h6
  subst h7
  exact solution_odd hn hrn

/-! ## 6. The prime solution is 5 -/

/-- The only prime solution of `3·φ(n) = 2n + 2` is `n = 5`
(`φ(n) = n − 1` gives `3(n−1) = 2n + 2`, i.e. `n = 5`). -/
theorem solution_prime_eq_five {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2)
    (hp : n.Prime) : n = 5 := by
  have h1 : Nat.totient n = n - 1 := Nat.totient_prime hp
  have h2 := hp.two_le
  omega

/-! ## 7. The two-prime solution is 35 -/

/-- The only solution of `3·φ(n) = 2n + 2` that is a product of two distinct primes is
`n = 35 = 5·7`. (Both primes are `≥ 5`; writing `p = a + 5`, `q = b + 7`, the equation
`3(p−1)(q−1) = 2pq + 2` collapses to `ab + 4a + 2b = 0`, forcing `a = b = 0`.) -/
theorem solution_two_primes {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) :
    ∀ p q : ℕ, p.Prime → q.Prime → p < q → n = p * q → n = 35 := by
  intro p q hp hq hlt hnpq
  subst hnpq
  have hp5 : 5 ≤ p := solution_min_prime_ge_five hn p hp (dvd_mul_right p q)
  have hq7 : 7 ≤ q := by
    have hq5 : 5 ≤ q := solution_min_prime_ge_five hn q hq (dvd_mul_left q p)
    have hq6 : q ≠ 6 := by rintro rfl; exact absurd hq (by decide)
    omega
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hlt.ne
  have hphi : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq]
  have heq : 3 * ((p - 1) * (q - 1)) = 2 * (p * q) + 2 := by rw [← hphi]; exact hn
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 5 := ⟨p - 5, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 7 := ⟨q - 7, by omega⟩
  have e1 : a + 5 - 1 = a + 4 := by omega
  have e2 : b + 7 - 1 = b + 6 := by omega
  rw [e1, e2] at heq
  have hL : 3 * ((a + 4) * (b + 6)) = 3 * (a * b) + (18 * a + 12 * b + 72) := by ring
  have hR : 2 * ((a + 5) * (b + 7)) + 2 = 2 * (a * b) + (14 * a + 10 * b + 72) := by ring
  rw [hL, hR] at heq
  -- `heq` is linear in the atom `a*b`: `(a*b) + 4a + 2b = 0`, so `a = b = 0`.
  have ha : a = 0 := by omega
  have hb : b = 0 := by omega
  subst ha; subst hb
  norm_num

end EG411Structure
