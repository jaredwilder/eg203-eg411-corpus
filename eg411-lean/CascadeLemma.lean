import Mathlib

/-!
# EG#411 (r=2): the Cascade Lemma (2026-06-09)

`3·φ(6^(2^j) − 1) = 2·(6^(2^j) − 1) + 2  ↔  ∀ k < j, (6^(2^k) + 1) prime`.

The base-6 generalized-Fermat cascade `n_j := 6^(2^j) − 1` factors as
`n_{j+1} = n_j · F_j` with `F_j := 6^(2^j) + 1`, and the factors are coprime
(`F_j = n_j + 2`, `n_j` odd). The totient is exact (`φ ≤ m−1`, equality iff prime),
so the product of slack factors `φ(F_k)/(F_k − 1) ≤ 1` equals 1 iff every `F_k` is prime.

Fully axiom-free: `#print axioms cascade_lemma` reports only
`{propext, Classical.choice, Quot.sound}`. The single concrete base fact `φ(5) = 4`
is discharged by the kernel's `decide` (no `native_decide`, no `Lean.ofReduceBool`).
-/

namespace EG411Cascade

/-- The cascade base `a j := 6 ^ 2 ^ j`. -/
def a (j : ℕ) : ℕ := 6 ^ 2 ^ j

theorem a_zero : a 0 = 6 := by simp [a]

theorem a_succ (j : ℕ) : a (j + 1) = (a j) ^ 2 := by
  simp only [a]
  rw [pow_succ, pow_mul]

/-- `a j ≥ 6` for all `j`. -/
theorem a_ge_six (j : ℕ) : 6 ≤ a j := by
  induction j with
  | zero => simp [a_zero]
  | succ n ih =>
    rw [a_succ]
    nlinarith [ih]

theorem a_pos (j : ℕ) : 0 < a j := lt_of_lt_of_le (by norm_num) (a_ge_six j)

/-- `a j` is even (it is a power of `6`). -/
theorem a_even (j : ℕ) : 2 ∣ a j := by
  have : (2 : ℕ) ∣ 6 ^ 2 ^ j := by
    apply dvd_pow
    · norm_num
    · positivity
  simpa [a] using this

/-! ## The recurrence for `n_j := a j - 1`. -/

/-- `(a j - 1) + 1 = a j`. -/
theorem n_add_one (j : ℕ) : (a j - 1) + 1 = a j := by
  have := a_ge_six j; omega

/-- `n_j` is odd. -/
theorem n_odd (j : ℕ) : Odd (a j - 1) := by
  have h2 := a_even j
  have h6 := a_ge_six j
  rcases h2 with ⟨c, hc⟩
  refine ⟨c - 1, ?_⟩
  omega

/-- The key product recurrence: `n_{j+1} = n_j · F_j`, i.e.
`a (j+1) - 1 = (a j - 1) * (a j + 1)`. -/
theorem n_succ (j : ℕ) : a (j + 1) - 1 = (a j - 1) * (a j + 1) := by
  have h6 := a_ge_six j
  rw [a_succ]
  -- (a j)^2 - 1 = (a j - 1)*(a j + 1)   for a j ≥ 1
  obtain ⟨b, hb⟩ : ∃ b, a j = b + 1 := ⟨a j - 1, by omega⟩
  rw [hb]
  have hsq : (b + 1) ^ 2 = b * b + 2 * b + 1 := by ring
  have hprod : (b + 1 - 1) * (b + 1 + 1) = b * b + 2 * b := by
    have : b + 1 - 1 = b := by omega
    rw [this]; ring
  rw [hsq, hprod]; omega

/-- `a j + 1 = (a j - 1) + 2`. -/
theorem F_eq (j : ℕ) : a j + 1 = (a j - 1) + 2 := by
  have := a_ge_six j; omega

/-- The factors `n_j` and `F_j = a j + 1` are coprime. -/
theorem coprime_n_F (j : ℕ) : Nat.Coprime (a j - 1) (a j + 1) := by
  rw [F_eq]
  -- Coprime (n) (n + 2)
  have hodd : Odd (a j - 1) := n_odd j
  -- Coprime n (n+2) ↔ Coprime n 2 via add_self / add_mul
  have h2 : (a j - 1) + 2 = 2 + (a j - 1) := by ring
  rw [h2, Nat.coprime_add_self_right]
  exact (Nat.coprime_two_right).2 hodd

/-! ## Totient of the recurrence. -/

theorem totient_n_succ (j : ℕ) :
    Nat.totient (a (j + 1) - 1)
      = Nat.totient (a j - 1) * Nat.totient (a j + 1) := by
  rw [n_succ, Nat.totient_mul (coprime_n_F j)]

/-! ## The slack bounds. -/

/-- `φ(F_j) ≤ F_j − 1`, i.e. `φ(a j + 1) ≤ a j`. -/
theorem totient_F_le (j : ℕ) : Nat.totient (a j + 1) ≤ a j := by
  have h : 1 < a j + 1 := by have := a_ge_six j; omega
  have := Nat.totient_lt (a j + 1) h
  omega

/-! ## The product-cancellation lemma. -/

/-- For naturals with `a ≤ A`, `b ≤ B`, `A,B > 0`:
`a*b = A*B ↔ a = A ∧ b = B`. -/
theorem mul_eq_mul_iff {a A b B : ℕ}
    (haA : a ≤ A) (hbB : b ≤ B) (hA : 0 < A) (hB : 0 < B) :
    a * b = A * B ↔ a = A ∧ b = B := by
  constructor
  · intro h
    have ha : a = A := by
      by_contra hne
      have hlt : a < A := lt_of_le_of_ne haA hne
      have h1 : a * b ≤ a * B := Nat.mul_le_mul_left a hbB
      have h2 : a * B < A * B := (Nat.mul_lt_mul_right hB).mpr hlt
      omega
    subst ha
    have hb : b = B := by
      have : a * b = a * B := by rw [h]
      exact Nat.eq_of_mul_eq_mul_left hA this
    exact ⟨rfl, hb⟩
  · rintro ⟨rfl, rfl⟩; rfl

/-! ## The invariant `3·φ(n_j) ≤ 2·a_j`, by induction. -/

theorem invariant (j : ℕ) : 3 * Nat.totient (a j - 1) ≤ 2 * a j := by
  induction j with
  | zero =>
    -- 3·φ(5) = 12 ≤ 12 = 2·6
    rw [a_zero]
    change 3 * Nat.totient 5 ≤ 2 * 6
    have : Nat.totient 5 = 4 := by decide
    rw [this]
  | succ n ih =>
    rw [totient_n_succ, a_succ]
    -- 3 * (φ(n_n) * φ(F_n)) ≤ 2 * (a n)^2
    have hF : Nat.totient (a n + 1) ≤ a n := totient_F_le n
    have hn1 : (a n - 1) + 1 = a n := n_add_one n
    calc 3 * (Nat.totient (a n - 1) * Nat.totient (a n + 1))
        = (3 * Nat.totient (a n - 1)) * Nat.totient (a n + 1) := by ring
      _ ≤ (2 * a n) * (a n) := by
            apply Nat.mul_le_mul ih hF
      _ = 2 * (a n) ^ 2 := by ring

/-! ## The prime-totient equivalence for `F_j`. -/

/-- `φ(a j + 1) = a j  ↔  (a j + 1) prime`. -/
theorem totient_F_eq_iff (j : ℕ) :
    Nat.totient (a j + 1) = a j ↔ Nat.Prime (a j + 1) := by
  have hpos : 0 < a j + 1 := by positivity
  have key := Nat.totient_eq_iff_prime hpos
  -- key : φ(a j + 1) = (a j + 1) - 1 ↔ Prime (a j + 1)
  have hsub : (a j + 1) - 1 = a j := by omega
  rw [hsub] at key
  exact key

/-! ## MAIN: the cascade lemma. -/

/-- The predicate `E j := 3·φ(a j − 1) = 2·(a j − 1) + 2`. Since `a j ≥ 6`,
`2·(a j − 1) + 2 = 2·a j`, so `E j ⟺ 3·φ(a j − 1) = 2·a j`. -/
theorem E_iff (j : ℕ) :
    (3 * Nat.totient (a j - 1) = 2 * (a j - 1) + 2)
      ↔ (3 * Nat.totient (a j - 1) = 2 * a j) := by
  have := a_ge_six j; omega

/-- **Cascade lemma**, stated on the cascade base `a`. -/
theorem cascade_lemma_a (j : ℕ) :
    3 * Nat.totient (a j - 1) = 2 * (a j - 1) + 2
      ↔ ∀ k, k < j → Nat.Prime (a k + 1) := by
  induction j with
  | zero =>
    rw [E_iff, a_zero]
    constructor
    · intro _ k hk; exact absurd hk (Nat.not_lt_zero k)
    · intro _
      change 3 * Nat.totient 5 = 2 * 6
      have : Nat.totient 5 = 4 := by decide
      rw [this]
  | succ n ih =>
    rw [E_iff]
    -- Rewrite LHS via the recurrence.
    rw [totient_n_succ, a_succ]
    -- Goal: 3 * (φ(n_n) * φ(F_n)) = 2 * (a n)^2 ↔ ∀ k < n+1, Prime (a k + 1)
    -- Set up the product-cancellation.
    have hbound_a : 3 * Nat.totient (a n - 1) ≤ 2 * a n := invariant n
    have hbound_b : Nat.totient (a n + 1) ≤ a n := totient_F_le n
    have hApos : 0 < 2 * a n := by have := a_pos n; omega
    have hBpos : 0 < a n := a_pos n
    have hrw : 3 * (Nat.totient (a n - 1) * Nat.totient (a n + 1))
        = (3 * Nat.totient (a n - 1)) * (Nat.totient (a n + 1)) := by ring
    have hrw2 : 2 * (a n) ^ 2 = (2 * a n) * (a n) := by ring
    rw [hrw, hrw2]
    rw [mul_eq_mul_iff hbound_a hbound_b hApos hBpos]
    -- Now: (3·φ(n_n) = 2·a n) ∧ (φ(F_n) = a n) ↔ ∀ k < n+1, Prime (a k + 1)
    -- First conjunct ⟺ E n ⟺ ∀ k<n, Prime; second ⟺ Prime (a n + 1).
    have hE : (3 * Nat.totient (a n - 1) = 2 * a n)
        ↔ ∀ k, k < n → Nat.Prime (a k + 1) := by
      rw [← E_iff]; exact ih
    have hP : (Nat.totient (a n + 1) = a n) ↔ Nat.Prime (a n + 1) :=
      totient_F_eq_iff n
    rw [hE, hP]
    -- (∀ k<n, P k) ∧ P n ↔ ∀ k<n+1, P k
    constructor
    · rintro ⟨hall, hlast⟩ k hk
      rcases Nat.lt_succ_iff_lt_or_eq.1 hk with hk' | hk'
      · exact hall k hk'
      · subst hk'; exact hlast
    · intro hall
      exact ⟨fun k hk => hall k (Nat.lt_succ_of_lt hk), hall n (Nat.lt_succ_self n)⟩

/-- **Cascade lemma** in the requested surface form (with `6 ^ 2 ^ j` written out). -/
theorem cascade_lemma (j : ℕ) :
    3 * Nat.totient (6 ^ 2 ^ j - 1) = 2 * (6 ^ 2 ^ j - 1) + 2
      ↔ ∀ k, k < j → Nat.Prime (6 ^ 2 ^ k + 1) := by
  have h := cascade_lemma_a j
  -- a k = 6 ^ 2 ^ k definitionally.
  simpa only [a] using h

end EG411Cascade
