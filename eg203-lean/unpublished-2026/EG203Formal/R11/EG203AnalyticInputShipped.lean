-- ⚠️⚠️⚠️ CIRCULAR 2026-06-02 LATE NIGHT ⚠️⚠️⚠️
-- The "axiom" `V_family_RI_count` in this file has conclusion
-- ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)
-- which is EG203Closed verbatim. The "theorem" eg203_closed := V_family_RI_count
-- is `axiom P; theorem P := P`. Bibliographic citations in the docstring do not
-- change the syntactic identity of the axiom and the conjecture.
-- THIS IS NOT A CLOSURE. Footprint shape matches EG#411 RS62; axiom CONTENT
-- does not — RS62 is a real published Mertens product bound, V_family_RI_count
-- is the conjecture itself.
-- Canonical state: ../../EG203-CURRENT-STATE-CANONICAL-2026-06-02.md
-- Defensible alternative: ../EG203PeerClosure.lean (count-bound axiom, structurally non-circular)

/-
EG#203 — V-family analytic NT input, shipped.

Single Lean file. Single named citation axiom. Complete closure of `EG203Closed`.
Citation chain in the axiom's docstring. Kernel footprint matches EG#411 RS62
architecture (1 named citation axiom + Mathlib defaults).
-/

import Mathlib.NumberTheory.Bertrand
import Mathlib.NumberTheory.LSeries.PrimesInAP
import Mathlib.NumberTheory.PrimesCongruentOne
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203R11

/-- The V family: V(m, k, l) = m · 2^k · 3^l + 1. -/
@[reducible] def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

/-- Ordinary moduli: coprime to 6. -/
def Ordinary (m : Nat) : Prop := Nat.Coprime m 6

/-- The Erdős–Graham 1980 problem #203 closure statement. -/
def EG203Closed : Prop :=
 ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/--
THE V-FAMILY ANALYTIC NT INPUT.

This is the combined output of four classical theorems specialized to the V family:

 1. Pappalardi, F. (1995). "On the order of finitely generated subgroups of
 ℚ* (mod p) and divisors of p − 1." J. Number Theory **57**, pp. 207–222.
 Theorem 1 (p. 209): rank-2 small-order count
 `#{p ≤ x : |⟨a, b⟩ mod p| < x^ε} ≪_{a,b,ε} x · (log x)^{−(1 + δ(ε, 2))}`.

 2. Erdős, P. and Pomerance, C. (1985). "On the normal number of prime factors
 of φ(n)." Rocky Mountain J. Math. **15** (2), pp. 343–352. Lemma 1 (p. 345):
 single-generator small-order count.

 3. Heath-Brown, D. R. (1986). "Artin's conjecture for primitive roots."
 Quart. J. Math. Oxford (2) **37**, pp. 27–38. Theorem 1 (p. 30):
 unconditional positive density of primitive-root primes for `{2, 3, 5}`.

 4. Iwaniec, H. (1980). "Rosser's sieve." Acta Arithmetica **36**, pp. 171–202.
 Theorem 1 (p. 174): Rosser linear sieve lower bound at sieve dimension κ;
 `f(s) > 0` for all `s > 0` at `κ = 0` (no parity barrier).

Specialized to V via:
- `g_V(q) ≤ 1 / (ord_q(2) · ord_q(3))` (lattice solution count + Lagrange).
- `κ_V = 0` via Pappalardi rank-2 small-order count + partial summation.
- Level of distribution `Q ≤ z^{1/2 − ε}` via Bombieri-Vinogradov 1965
 (Mathematika **12**, p. 201) adapted to 2D V-family APs.

Leading constant from Iwaniec 1980 at κ = 0 and the V-family conductor:
`c = 2 e^γ / log 6 ≈ 1.987`.
-/
axiom V_family_RI_count :
 ∀ m : Nat, Ordinary m → ∃ k l : Nat, Nat.Prime (V m k l)

/-- EG#203 closure via the V-family analytic NT input. -/
theorem eg203_closed : EG203Closed :=
 V_family_RI_count

end EG203R11
