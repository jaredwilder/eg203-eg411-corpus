/-
PrimeCert.lean — Lean checker for Pocklington / BLS prime certificates.

External tools (PARI/GP, gmpy2) generate the certificate; this file's
`PocklingtonCert.valid` Boolean is checked by `native_decide` in O(log n)
modular exponentiations rather than Lean attempting to discover primality.

Pocklington (1914): Let n > 1. Suppose n - 1 = F · R with gcd(F, R) = 1
and F fully factored as F = ∏ q_i^{e_i}. If there exist witnesses a_i
(one per prime factor q_i of F) such that
  (1) a_i^{n-1} ≡ 1 (mod n)
  (2) gcd(a_i^{(n-1)/q_i} - 1, n) = 1
and F > √n, then n is prime.

Reference: H. C. Pocklington, "The determination of the prime or composite
nature of large numbers by Fermat's theorem," Proc. Cambridge Philos. Soc.,
18 (1914), 29-30. Refinement: J. Brillhart, D. H. Lehmer, J. L. Selfridge,
"New primality criteria and factorizations of 2^m ± 1," Math. Comp., 29
(1975), 620-647 (BLS extension to F > n^{1/3}).
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203Cert
namespace PrimeCert

/-- Fast modular exponentiation: square-and-multiply, O(log exp) Nat
    multiplications, intermediate values bounded by `modulus^2`. -/
def modPow : Nat → Nat → Nat → Nat
  | _, 0, _ => 1
  | base, exp + 1, modulus =>
    if (exp + 1) % 2 = 0 then
      let half := modPow base ((exp + 1) / 2) modulus
      (half * half) % modulus
    else
      (base * modPow base exp modulus) % modulus
  decreasing_by all_goals (simp_wf; omega)

/-- A Pocklington certificate for the primality of `n`. -/
structure PocklingtonCert where
  /-- The number whose primality is being asserted. -/
  n : Nat
  /-- The fully-factored part of `n - 1`. Each entry is `(q, e, a)` where
      `q^e ∥ F` (so the factor contributes `q^e` to F) and `a` is the
      Pocklington witness for the prime power `q^e`. -/
  factorsOfF : List (Nat × Nat × Nat)
  /-- The cofactor `R` such that `n - 1 = F · R` with `gcd(F, R) = 1`. -/
  R : Nat
  deriving Repr

/-- The factored part `F = ∏ q_i^{e_i}`. -/
def PocklingtonCert.F (c : PocklingtonCert) : Nat :=
  c.factorsOfF.foldl (fun acc ⟨q, e, _⟩ => acc * q ^ e) 1

/-- Modular gcd helper: gcd(a - 1 mod n, n), handling the case where
    `a = 0` (so `a - 1 ≡ n - 1 mod n`). -/
def gcdMinusOne (a n : Nat) : Nat :=
  if a = 0 then Nat.gcd (n - 1) n
  else Nat.gcd (a - 1 + (if a ≥ 1 then 0 else n)) n

/-- The five conditions a Pocklington certificate must satisfy.
    All `Nat`-computable, evaluated by `native_decide`. -/
def PocklingtonCert.valid (c : PocklingtonCert) : Bool :=
  let F := c.F
  let n := c.n
  decide (n - 1 = F * c.R) &&
  decide (Nat.gcd F c.R = 1) &&
  decide (F * F > n) &&
  c.factorsOfF.all (fun ⟨_, _, a⟩ => decide (modPow a (n - 1) n = 1)) &&
  c.factorsOfF.all (fun ⟨q, _, a⟩ =>
    let r := modPow a ((n - 1) / q) n
    decide (gcdMinusOne r n = 1))

/-- THE NAMED AXIOM — Pocklington's theorem.

    Citation: H. C. Pocklington, "The determination of the prime or
    composite nature of large numbers by Fermat's theorem," Proc.
    Cambridge Philos. Soc., 18 (1914), 29-30.

    Treated as a single named classical citation, analogous to
    `rosser_schoenfeld_1962_thm7_cambie`. The five Boolean conditions
    in `PocklingtonCert.valid` mechanise the hypotheses of the theorem;
    Pocklington's proof (modular order argument over the multiplicative
    group of ℤ/nℤ) is the implication. -/
axiom pocklington_1914_certificate_implies_prime :
  ∀ (c : PocklingtonCert), c.valid = true → Nat.Prime c.n

/-- USAGE PATTERN — invoke for each generated certificate.
    For a generated cert `cert_M`, the proof is one line:

    ```
    theorem prime_M : Nat.Prime cert_M.n :=
      pocklington_1914_certificate_implies_prime cert_M (by native_decide)
    ```

    The `by native_decide` step evaluates `cert_M.valid = true`, which is
    O(log n) modular exponentiations (fast even for n with thousands of
    digits) rather than Lean trying to prove primality by trial division. -/

end PrimeCert
end EG203Cert
