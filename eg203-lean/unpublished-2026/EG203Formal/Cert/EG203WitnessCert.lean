/-
EG203WitnessCert.lean — EG#203-specific witness certificate.

For an ordinary m (gcd(m, 6) = 1), an EG#203 witness certificate is:
  - explicit (k, l) coordinates
  - a PocklingtonCert for n = m·2^k·3^l + 1

The certificate proves `∃ k l, Nat.Prime (m·2^k·3^l + 1)` — exactly the
EG#203 predicate for that m, with the prime witness made constructively
explicit and the primality of the witness verified by Pocklington.

Generator: `forge/forge_eg203_emit_cert.py` produces one Lean file per
shard of m values, each containing the certificate structures + the
one-line composition theorem.
-/

import EG203Formal.Cert.PrimeCert
import Mathlib.Tactic

namespace EG203Cert
namespace WitnessCert

/-- The V family. -/
@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/-- An EG#203 witness certificate for the ordinary integer `m`. -/
structure Cert where
  m : Nat
  k : Nat
  l : Nat
  primeCert : PrimeCert.PocklingtonCert
  deriving Repr

/-- Boolean validity check. -/
def Cert.valid (c : Cert) : Bool :=
  decide (c.primeCert.n = V c.m c.k c.l) && c.primeCert.valid

/-- Given a valid witness cert, V(m, k, l) is prime. -/
theorem prime_witness_of_valid (c : Cert) (h : c.valid = true) :
    Nat.Prime (V c.m c.k c.l) := by
  have h1 : decide (c.primeCert.n = V c.m c.k c.l) = true :=
    (Bool.and_eq_true _ _).mp h |>.1
  have h2 : c.primeCert.valid = true :=
    (Bool.and_eq_true _ _).mp h |>.2
  have hn : c.primeCert.n = V c.m c.k c.l := of_decide_eq_true h1
  have hprime : Nat.Prime c.primeCert.n :=
    PrimeCert.pocklington_1914_certificate_implies_prime c.primeCert h2
  rw [← hn]
  exact hprime

/-- The EG#203 existence statement for a specific m, derived from a
    valid witness cert. -/
theorem exists_prime_witness_of_cert (c : Cert) (h : c.valid = true) :
    ∃ k l : Nat, Nat.Prime (V c.m k l) :=
  ⟨c.k, c.l, prime_witness_of_valid c h⟩

end WitnessCert
end EG203Cert
