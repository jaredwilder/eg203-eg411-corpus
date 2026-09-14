import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

/-!
# Chain 103 — CORRECTED axiom matching NUCLEAR-MASTER-LOG verbatim

Operator's research (2026-06-02) located the exact chain 103 statement at
`EG203-NUCLEAR-MASTER-LOG-2026-05-31.md` lines 549-580. The TRUE chain 103
result is **m-INDEPENDENT**: it is a statement about `2^k · 3^l ≢ -1 (mod q)`,
NOT about V coprimality for arbitrary m.

## Verbatim statement (internal research notes)

> Theorem (chain 103, proved by direct enumeration):
> The uncovered base cells under fiber-lift projection of all eligible prime
> cosets are EXACTLY:
> `{(k0, l0) ∈ Z/2520 × Z/5040 : k0 ≡ 0 (mod 8) ∧ l0 ≡ 0 (mod 16)}`
> Cardinality 315² = 99,225 = 2520·5040 / 128.
>
> For every eligible prime q (h_q | lcm(P_A, P_B), q ≥ 5), and every
> (k0, l0) ∈ Z/2520 × Z/5040 with k0 ≡ 0 mod 8 ∧ l0 ≡ 0 mod 16, and every
> fiber lift (k, l) = (k0 + 2520·k1, l0 + 5040·l1):
> `2^k · 3^l ≢ -1 (mod q)`

This is the m=1 cover rule. For ordinary m ≠ 1, the cover rule shifts to
`2^k · 3^l ≡ -m⁻¹ (mod q)`, which chain 103 does NOT directly bound.

## Why m=19 broke the previous mis-encoding

m=19, q=5: chain 103 says `2^k · 3^l ≢ -1 ≡ 4 (mod 5)` on (k%8=0, l%16=0).
But `V(19, k, l) ≡ 0 (mod 5)` iff `19 · 2^k · 3^l ≡ -1 (mod 5)`, equivalently
`2^k · 3^l ≡ -19⁻¹ ≡ -4⁻¹ ≡ -4 ≡ 1 (mod 5)`. Chain 103 doesn't exclude
`2^k · 3^l ≡ 1`, so V can still be divisible by 5 — and is for all chain cells
with m=19 (where -19⁻¹ ≡ 1 mod 5).
-/

namespace EG203R13Chain103Correct

/-- The CORRECT chain 103 axiom (m=1 form, verbatim from internal research notes).

 For each eligible prime q ≥ 5 and each fiber lift of a base cell with
 k0 ≡ 0 mod 8 and l0 ≡ 0 mod 16, the value `2^k · 3^l` is NEVER ≡ -1 mod q.

 Equivalently: for m = 1, V(1, k, l) = 2^k · 3^l + 1 is NEVER divisible by q
 on the chain 103 cells.

 Citation: operator's NUCLEAR-MASTER-LOG chain 103, proved by direct
 enumeration up to gate-4 period (140,900,760 × 281,801,520). Receipt SHA:
 894b3876596c2edf263cc52e0a19395e0f98b2c015839fa039603f9c658b11ce.

 "Eligibility" of q: the internal research notes specifies `h_q | lcm(P_A, P_B)` where
 h_q is the order of the subgroup. The Lean axiom approximates with q ≥ 5
 (which the chain 103 enumeration covers for q ≤ 19 explicitly). -/
axiom chain_103_m1_no_neg_one_mod_q :
 ∀ (q : ℕ), q.Prime → 5 ≤ q → q ≤ 19 →
 ∀ (k0 l0 k1 l1 : ℕ),
 k0 < 2520 → l0 < 5040 →
 k0 % 8 = 0 → l0 % 16 = 0 →
 ¬ (q ∣ (2^(k0 + 2520*k1) * 3^(l0 + 5040*l1) + 1))

/-- Direct corollary for m = 1: V(1, k, l) is coprime to all chain primes
 on chain 103 cells. -/
theorem V_one_coprime_chain_primes_on_chain_103 (q : ℕ) (hp : q.Prime)
 (hq5 : 5 ≤ q) (hq19 : q ≤ 19)
 (k0 l0 k1 l1 : ℕ)
 (hk0 : k0 < 2520) (hl0 : l0 < 5040)
 (hkmod : k0 % 8 = 0) (hlmod : l0 % 16 = 0) :
 ¬ (q ∣ (1 * 2^(k0 + 2520*k1) * 3^(l0 + 5040*l1) + 1)) := by
 simp only [one_mul]
 exact chain_103_m1_no_neg_one_mod_q q hp hq5 hq19 k0 l0 k1 l1 hk0 hl0 hkmod hlmod

/-! ## What chain 103 does NOT give (for the record)

 For ordinary m ≠ 1 (mod q for some chain q), the cover rule shifts to
 `2^k · 3^l ≡ -m⁻¹ (mod q)`, and chain 103 cells may still have V ≡ 0 mod q.

 To close EG#203 for general m, we need EITHER:
 1. m-DEPENDENT cell shift (a_m, b_m) such that V(m, k0 + a_m, l0 + b_m) =
 2^{a_m} · 3^{b_m} · V(1, k0, l0) - (2^{a_m} · 3^{b_m} - m) mod q. Doesn't
 directly translate.
 2. Analytic sieve (V_family_RI_count style) — what R11 monolithic uses.
 3. Compute m-specific obstruction cells via CRT on m mod (3·5·7·11·13·17·19)
 = 4849845, and find the cell shift per residue class.

 None of these are immediate from chain 103 alone.
-/

end EG203R13Chain103Correct
