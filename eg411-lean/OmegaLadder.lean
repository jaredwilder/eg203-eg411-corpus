import SolutionStructure

/-!
# EG#411 (r=2): the ω-ladder — three- and four-prime solutions (2026-06-10)

For `n : ℕ` satisfying `3·φ(n) = 2n + 2` (the Steinerberger/Hercher totient equation that
EG#411 r=2 reduces to — see `RealResult.lean`), we classify the solutions with exactly
three and exactly four prime factors:

  • `solution_three_primes` — if `n = p·q·r` (`p < q < r` primes) then `n = 1295 = 5·7·37`
  • `solution_four_primes`  — if `n = p·q·r·s` (`p < q < r < s` primes) then
                              `n = 1679615 = 5·7·37·1297`

Together with `solution_prime_eq_five` and `solution_two_primes` from
`SolutionStructure.lean`, this matches the brute-force-verified ground truth: the only
solutions with `ω(n) ≤ 4` are `5`, `35`, `1295`, `1679615`.

Proof skeleton (three primes; four primes is the same ladder one rung higher):

  1. Every prime factor is `≥ 5` (`solution_min_prime_ge_five`), and writing
     `p = a+1, q = b+1, r = c+1` turns the equation into the subtraction-free form
     `3·a·b·c = 2·(a+1)(b+1)(c+1) + 2`.
  2. **Cap the smallest prime.** If `p ≥ 11`, then from `10(x+1) ≤ 11x` for each of
     `a, b, c ≥ 10` we get `1000·P ≤ 1331·Q` for `P = (a+1)(b+1)(c+1)`, `Q = abc`;
     with `3Q = 2P + 2` this forces `338·P ≤ 2662`, impossible since `P ≥ 11³`.
     Hence `p ∈ {5, 7}`.
  3. **p = 5:** the equation collapses to `bc = 5b + 5c + 6`, i.e. `(q−6)(r−6) = 31`;
     a linear bound gives `q ≤ 11` and case checking pins `q = 7, r = 37`.
  4. **p = 7:** the equation collapses to `2bc = 7b + 7c + 8`, i.e. `(2q−9)(2r−9) = 65`,
     which has no room above `q > 7`: contradiction.

For four primes the second prime is capped the same way (`6·(16/17)³ > 5` for `p = 5`,
`9·(12/13)³ > 7` for `p = 7` — the `p = 5` margin is razor-thin: `6·(16/17)³ = 5.0048…`),
and the surviving `(p, q)` pairs reduce to two-variable Pell-style factor hunts:
`(r−36)(s−36) = 1261 = 13·97` for `(5,7)` — solved by `r = 37, s = 1297` — and
`(7r−72)(7s−72) = 4687 = 43·109`, `(13r−90)(13s−90) = 6943 = 53·131`, `5 ∤ RHS` walls
for `(5,13)`, `(7,11)`, `(5,11)` respectively.

Fully axiom-free: both theorems report only `{propext, Classical.choice, Quot.sound}`
(no `native_decide`, no project-local axiom).
-/

namespace EG411Structure

/-! ## 1. Three prime factors: `n = 1295` -/

set_option maxHeartbeats 800000 in
-- The interval_cases ladders over the candidate primes exceed the default budget.
/-- The only solution of `3·φ(n) = 2n + 2` that is a product of three distinct primes is
`n = 1295 = 5·7·37`. -/
theorem solution_three_primes {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) :
    ∀ p q r : ℕ, p.Prime → q.Prime → r.Prime → p < q → q < r →
      n = p * q * r → n = 1295 := by
  intro p q r hp hq hr hpq hqr hnpqr
  subst hnpqr
  -- All prime factors are ≥ 5.
  have hp5 : 5 ≤ p := solution_min_prime_ge_five hn p hp ⟨q * r, by ring⟩
  have hq5 : 5 ≤ q := solution_min_prime_ge_five hn q hq ⟨p * r, by ring⟩
  have hr5 : 5 ≤ r := solution_min_prime_ge_five hn r hr ⟨p * q, by ring⟩
  -- Totient of the squarefree product of three distinct primes.
  have hcpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq.ne
  have hcpr : Nat.Coprime p r := (Nat.coprime_primes hp hr).mpr (hpq.trans hqr).ne
  have hcqr : Nat.Coprime q r := (Nat.coprime_primes hq hr).mpr hqr.ne
  have hphi : Nat.totient (p * q * r) = (p - 1) * ((q - 1) * (r - 1)) := by
    rw [Nat.totient_mul (hcpr.mul_left hcqr), Nat.totient_mul hcpq,
        Nat.totient_prime hp, Nat.totient_prime hq, Nat.totient_prime hr]
    ring
  have heq := hn
  rw [hphi] at heq
  -- Subtraction-free coordinates: p = a+1, q = b+1, r = c+1.
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  obtain ⟨c, rfl⟩ : ∃ c, r = c + 1 := ⟨r - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at heq
  -- heq : 3 * (a * (b * c)) = 2 * ((a+1) * (b+1) * (c+1)) + 2
  have ha4 : 4 ≤ a := by omega
  -- Cap the smallest prime: p ≤ 10, i.e. a ≤ 9.
  have hacap : a ≤ 9 := by
    by_contra hcon
    -- a, b, c ≥ 10, so 10·(x+1) ≤ 11·x for each coordinate.
    have k1 : 10 * (a + 1) ≤ 11 * a := by omega
    have k2 : 10 * (b + 1) ≤ 11 * b := by omega
    have k3 : 10 * (c + 1) ≤ 11 * c := by omega
    have prod : (10 * (a + 1)) * ((10 * (b + 1)) * (10 * (c + 1)))
        ≤ (11 * a) * ((11 * b) * (11 * c)) :=
      Nat.mul_le_mul k1 (Nat.mul_le_mul k2 k3)
    have hP : 1331 ≤ (a + 1) * ((b + 1) * (c + 1)) :=
      calc (1331 : ℕ) = 11 * (11 * 11) := by norm_num
        _ ≤ (a + 1) * ((b + 1) * (c + 1)) :=
          Nat.mul_le_mul (by omega) (Nat.mul_le_mul (by omega) (by omega))
    -- 1000·P ≤ 1331·Q and 3Q = 2P + 2 force 338·P ≤ 2662 — but P ≥ 1331.
    linarith only [prod, hP, heq]
  -- p prime in [5, 10] means p ∈ {5, 7}.
  have ha : a = 4 ∨ a = 6 := by
    interval_cases a <;> first | omega | norm_num at hp
  rcases ha with rfl | rfl
  · -- p = 5: equation collapses to b·c = 5b + 5c + 6, i.e. (q−6)(r−6) = 31.
    have heq' : b * c = 5 * b + 5 * c + 6 := by linarith only [heq]
    have hb5 : 5 ≤ b := by omega
    have hcb : b + 1 ≤ c := by omega
    -- Linear cap: b ≤ 10 (else 11c ≤ bc = 5b + 5c + 6 with c ≥ b+1 is absurd).
    have hble : b ≤ 10 := by
      by_contra h
      have h11 : 11 ≤ b := by omega
      have h1 : 11 * c ≤ b * c := Nat.mul_le_mul h11 (le_refl c)
      linarith only [heq', h1, hcb, h11]
    -- The six remaining values of b: only b = 6 (q = 7) survives, with c = 36 (r = 37).
    interval_cases b <;> omega
  · -- p = 7: equation collapses to 2bc = 7b + 7c + 8, which has no room above q > 7.
    exfalso
    have heq' : 2 * (b * c) = 7 * b + 7 * c + 8 := by linarith only [heq]
    have hb7 : 7 ≤ b := by omega
    have hcb : b + 1 ≤ c := by omega
    rcases Nat.lt_or_ge b 10 with h | h
    · -- b ∈ {7, 8, 9}: 7c = 57 / 9c = 64 / 11c = 71 — none solvable.
      interval_cases b <;> omega
    · -- b ≥ 10: 20c ≤ 2bc = 7b + 7c + 8 with c ≥ b+1 is absurd.
      have h1 : 10 * c ≤ b * c := Nat.mul_le_mul h (le_refl c)
      linarith only [heq', h1, hcb, h]

/-! ## 2. Four prime factors: `n = 1679615` -/

set_option maxHeartbeats 1000000 in
-- Four nested case ladders (p, then q, then the (r,s) factor hunts) exceed the default budget.
/-- The only solution of `3·φ(n) = 2n + 2` that is a product of four distinct primes is
`n = 1679615 = 5·7·37·1297`. -/
theorem solution_four_primes {n : ℕ} (hn : 3 * Nat.totient n = 2 * n + 2) :
    ∀ p q r s : ℕ, p.Prime → q.Prime → r.Prime → s.Prime →
      p < q → q < r → r < s → n = p * q * r * s → n = 1679615 := by
  intro p q r s hp hq hr hs hpq hqr hrs hnp
  subst hnp
  -- All prime factors are ≥ 5.
  have hp5 : 5 ≤ p := solution_min_prime_ge_five hn p hp ⟨q * (r * s), by ring⟩
  have hq5 : 5 ≤ q := solution_min_prime_ge_five hn q hq ⟨p * (r * s), by ring⟩
  have hr5 : 5 ≤ r := solution_min_prime_ge_five hn r hr ⟨p * (q * s), by ring⟩
  have hs5 : 5 ≤ s := solution_min_prime_ge_five hn s hs ⟨p * (q * r), by ring⟩
  -- Totient of the squarefree product of four distinct primes.
  have hcpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq.ne
  have hcpr : Nat.Coprime p r := (Nat.coprime_primes hp hr).mpr (hpq.trans hqr).ne
  have hcps : Nat.Coprime p s :=
    (Nat.coprime_primes hp hs).mpr ((hpq.trans hqr).trans hrs).ne
  have hcqr : Nat.Coprime q r := (Nat.coprime_primes hq hr).mpr hqr.ne
  have hcqs : Nat.Coprime q s := (Nat.coprime_primes hq hs).mpr (hqr.trans hrs).ne
  have hcrs : Nat.Coprime r s := (Nat.coprime_primes hr hs).mpr hrs.ne
  have hphi : Nat.totient (p * q * r * s)
      = (p - 1) * ((q - 1) * ((r - 1) * (s - 1))) := by
    rw [Nat.totient_mul ((hcps.mul_left hcqs).mul_left hcrs),
        Nat.totient_mul (hcpr.mul_left hcqr), Nat.totient_mul hcpq,
        Nat.totient_prime hp, Nat.totient_prime hq,
        Nat.totient_prime hr, Nat.totient_prime hs]
    ring
  have heq := hn
  rw [hphi] at heq
  -- Subtraction-free coordinates: p = a+1, q = b+1, r = c+1, s = d+1.
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  obtain ⟨c, rfl⟩ : ∃ c, r = c + 1 := ⟨r - 1, by omega⟩
  obtain ⟨d, rfl⟩ : ∃ d, s = d + 1 := ⟨s - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at heq
  -- heq : 3 * (a * (b * (c * d))) = 2 * ((a+1) * (b+1) * (c+1) * (d+1)) + 2
  have ha4 : 4 ≤ a := by omega
  -- Cap the smallest prime: p ≤ 10, i.e. a ≤ 9.
  have hacap : a ≤ 9 := by
    by_contra hcon
    -- a, b, c, d ≥ 10, so 10·(x+1) ≤ 11·x for each coordinate.
    have k1 : 10 * (a + 1) ≤ 11 * a := by omega
    have k2 : 10 * (b + 1) ≤ 11 * b := by omega
    have k3 : 10 * (c + 1) ≤ 11 * c := by omega
    have k4 : 10 * (d + 1) ≤ 11 * d := by omega
    have prod : (10 * (a + 1)) * ((10 * (b + 1)) * ((10 * (c + 1)) * (10 * (d + 1))))
        ≤ (11 * a) * ((11 * b) * ((11 * c) * (11 * d))) :=
      Nat.mul_le_mul k1 (Nat.mul_le_mul k2 (Nat.mul_le_mul k3 k4))
    have hP : 14641 ≤ (a + 1) * ((b + 1) * ((c + 1) * (d + 1))) :=
      calc (14641 : ℕ) = 11 * (11 * (11 * 11)) := by norm_num
        _ ≤ (a + 1) * ((b + 1) * ((c + 1) * (d + 1))) :=
          Nat.mul_le_mul (by omega)
            (Nat.mul_le_mul (by omega) (Nat.mul_le_mul (by omega) (by omega)))
    -- 10000·P ≤ 14641·Q and 3Q = 2P + 2 force 718·P ≤ 29282 — but P ≥ 14641.
    linarith only [prod, hP, heq]
  -- p prime in [5, 10] means p ∈ {5, 7}.
  have ha : a = 4 ∨ a = 6 := by
    interval_cases a <;> first | omega | norm_num at hp
  rcases ha with rfl | rfl
  · -- p = 5: 6·bcd = 5·(b+1)(c+1)(d+1) + 1.
    have hb5 : 5 ≤ b := by omega
    -- Cap the second prime: q ≤ 16, i.e. b ≤ 15 (razor-thin: 6·(16/17)³ = 5.0048…).
    have hbcap : b ≤ 15 := by
      by_contra hcon
      -- b, c, d ≥ 16, so 16·(x+1) ≤ 17·x for each coordinate.
      have k1 : 16 * (b + 1) ≤ 17 * b := by omega
      have k2 : 16 * (c + 1) ≤ 17 * c := by omega
      have k3 : 16 * (d + 1) ≤ 17 * d := by omega
      have prod : (16 * (b + 1)) * ((16 * (c + 1)) * (16 * (d + 1)))
          ≤ (17 * b) * ((17 * c) * (17 * d)) :=
        Nat.mul_le_mul k1 (Nat.mul_le_mul k2 k3)
      have hP : 4913 ≤ (b + 1) * ((c + 1) * (d + 1)) :=
        calc (4913 : ℕ) = 17 * (17 * 17) := by norm_num
          _ ≤ (b + 1) * ((c + 1) * (d + 1)) :=
            Nat.mul_le_mul (by omega) (Nat.mul_le_mul (by omega) (by omega))
      -- 4096·P ≤ 4913·Q and 12Q = 10P + 2 force 22·P ≤ 9826 — but P ≥ 4913.
      linarith only [prod, hP, heq]
    -- q prime in (5, 16] means q ∈ {7, 11, 13}.
    have hb : b = 6 ∨ b = 10 ∨ b = 12 := by
      interval_cases b <;> first | omega | norm_num at hq
    rcases hb with rfl | rfl | rfl
    · -- q = 7: cd = 35c + 35d + 36, i.e. (r−36)(s−36) = 1261 = 13·97.
      have heq' : c * d = 35 * c + 35 * d + 36 := by linarith only [heq]
      have hdc : c + 1 ≤ d := by omega
      -- c ≥ 36 (else cd ≤ 35d < 35c + 35d + 36 = cd).
      have hc36 : 36 ≤ c := by
        by_contra h
        have h35 : c ≤ 35 := by omega
        have h1 : c * d ≤ 35 * d := Nat.mul_le_mul h35 (le_refl d)
        linarith only [heq', h1, Nat.zero_le c]
      obtain ⟨e, rfl⟩ : ∃ e, c = e + 36 := ⟨c - 36, by omega⟩
      -- d·(e+1) = 35e + 1296 = 35(e+1) + 1261, so (e+1) ∣ 1261.
      have heq'' : e * d + d = 35 * e + 1296 := by linarith only [heq']
      -- d ≥ e + 37 caps e at 34, so e + 1 ∈ {1, 13} among divisors of 1261.
      have hecap : e ≤ 34 := by
        by_contra h
        have h35 : 35 ≤ e := by omega
        have h1 : 35 * d ≤ e * d := Nat.mul_le_mul h35 (le_refl d)
        linarith only [heq'', h1, hdc, h35]
      -- (e+1) ∣ 1261, and the only divisors of 1261 = 13·97 below 36 are 1 and 13.
      have hdvd : (e + 1) ∣ 1261 := by
        have h1 : (e + 1) * d = 35 * (e + 1) + 1261 := by linarith only [heq'']
        have h2 : (e + 1) ∣ 35 * (e + 1) + 1261 := ⟨d, h1.symm⟩
        have h3 : (e + 1) ∣ 35 * (e + 1) := ⟨35, by ring⟩
        exact (Nat.dvd_add_right h3).mp h2
      have hsmall : ∀ k < 36, k ∣ 1261 → k = 1 ∨ k = 13 := by decide
      have he : e = 0 ∨ e = 12 := by
        rcases hsmall (e + 1) (by omega) hdvd with h | h <;> omega
      rcases he with rfl | rfl
      · -- e = 0: d = 1296, so s = 1297 and n = 35·37·1297 = 1679615.
        omega
      · -- e = 12: r = 49 = 7² — not prime.
        norm_num at hr
    · -- q = 11: 5·cd = 55c + 55d + 56 — impossible mod 5.
      have heq' : 5 * (c * d) = 55 * c + 55 * d + 56 := by linarith only [heq]
      obtain ⟨m, hm⟩ : ∃ m, c * d = m := ⟨_, rfl⟩
      rw [hm] at heq'
      omega
    · -- q = 13: 7·cd = 65c + 65d + 66, i.e. (7r−72)(7s−72) = 4687 = 43·109 — no room.
      exfalso
      have heq' : 7 * (c * d) = 65 * c + 65 * d + 66 := by linarith only [heq]
      have hdc : c + 1 ≤ d := by omega
      have hc13 : 13 ≤ c := by omega
      -- r > 13 prime means r ≥ 17, i.e. c ≥ 16.
      have hc16 : 16 ≤ c := by
        by_contra h
        have h15 : c ≤ 15 := by omega
        interval_cases c <;> norm_num at hr
      -- Linear cap: c ≤ 18 (else 133d ≤ 7cd with d ≥ c+1 is absurd).
      have hccap : c ≤ 18 := by
        by_contra h
        have h19 : 19 ≤ c := by omega
        have h1 : 19 * d ≤ c * d := Nat.mul_le_mul h19 (le_refl d)
        linarith only [heq', h1, hdc, h19]
      -- c ∈ {16, 17, 18}: 47d = 1106 / 54d = 1171 / 61d = 1236 — none solvable.
      interval_cases c <;> omega
  · -- p = 7: 9·bcd = 7·(b+1)(c+1)(d+1) + 1.
    exfalso
    have hb7 : 7 ≤ b := by omega
    -- Cap the second prime: q ≤ 12, i.e. b ≤ 11.
    have hbcap : b ≤ 11 := by
      by_contra hcon
      -- b, c, d ≥ 12, so 12·(x+1) ≤ 13·x for each coordinate.
      have k1 : 12 * (b + 1) ≤ 13 * b := by omega
      have k2 : 12 * (c + 1) ≤ 13 * c := by omega
      have k3 : 12 * (d + 1) ≤ 13 * d := by omega
      have prod : (12 * (b + 1)) * ((12 * (c + 1)) * (12 * (d + 1)))
          ≤ (13 * b) * ((13 * c) * (13 * d)) :=
        Nat.mul_le_mul k1 (Nat.mul_le_mul k2 k3)
      have hP : 2197 ≤ (b + 1) * ((c + 1) * (d + 1)) :=
        calc (2197 : ℕ) = 13 * (13 * 13) := by norm_num
          _ ≤ (b + 1) * ((c + 1) * (d + 1)) :=
            Nat.mul_le_mul (by omega) (Nat.mul_le_mul (by omega) (by omega))
      -- 1728·P ≤ 2197·Q and 18Q = 14P + 2 force 173·P ≤ 2197 — but P ≥ 2197.
      linarith only [prod, hP, heq]
    -- q prime in (7, 12] means q = 11.
    have hb : b = 10 := by
      interval_cases b <;> first | rfl | norm_num at hq
    subst hb
    -- q = 11: 13·cd = 77c + 77d + 78, i.e. (13r−90)(13s−90) = 6943 = 53·131 — no room.
    have heq' : 13 * (c * d) = 77 * c + 77 * d + 78 := by linarith only [heq]
    have hdc : c + 1 ≤ d := by omega
    have hc11 : 11 ≤ c := by omega
    -- r > 11 prime means r ≥ 13, i.e. c ≥ 12.
    have hc12 : 12 ≤ c := by
      by_contra h
      have h11 : c ≤ 11 := by omega
      -- the single surviving value c = 11 gives r = 12 — not prime
      interval_cases c
      norm_num at hr
    -- 156d ≤ 13cd = 77c + 77d + 78 with d ≥ c+1 is absurd.
    have h1 : 12 * d ≤ c * d := Nat.mul_le_mul hc12 (le_refl d)
    linarith only [heq', h1, hdc, hc12]

end EG411Structure
