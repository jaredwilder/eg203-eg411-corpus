# eg203-eg411-corpus

The full working corpus for Erdos-Graham #203 and #411: Lean proofs, GPU search certificates, the
omega kill tree, the r754 theorem packet, and 19 compiled papers.

Author: Jared Wilder. First public timestamp: 2026-09-10.

## Read this first

**Erdos-Graham #411 (r=2) is OPEN, and #203 is OPEN.** Neither is closed here.

An earlier claim in this program that #411 (r=2) was closed **was false and has been retracted by
its author**. The full retraction, with the structural reason the claimed proof was vacuous, and
the packets it withdraws, are published at
github.com/jaredwilder/erdos411-retraction-record. Read that before reading anything here.

## Erdos-Graham #411

**The reduction.** An exact reduction of the r=2 case to the Steinerberger totient equation
3 phi(N) = 2N + 2.

**What follows from it, unconditionally:** omega(N) >= 8, where omega counts distinct prime
factors.

**The exhaustion behind that.** `eg411-lean/omega7_tree.json` (67 MB) and
`eg411-lean/omega7-kill-tree.zip` carry the full kill tree: the omega <= 7 cases are exhausted,
with 272,676 terminals all empty. The omega(n) <= 4 solutions are completely classified as
{5, 35, 1295, 1679615}.

**The cascade.** n_j = 6^(2^j) - 1 solves the equation exactly when every 6^(2^k) + 1 for k < j is
prime; it terminates at j = 3, yielding exactly the primes 7 and 47.

**The search.** No exceptional prime below 1.33 x 10^14, extending the prior bound by roughly
13,000 times.

**`eg411-gpu-certificates/` (107 MB)** holds the GPU search runs: 59 certificates across seeds and
box sizes, all rows forced to depth 4 with no survivor, and a computed floor
x3_lower >= 0.9908274 that drops to >= 0.9849996 under the scale-stress runs at higher maximum
exponent. **This is a finite obstruction, not a global proof.** The global statement is blocked on
a lower-jump invariant that remains an unfilled `sorry`.

## Erdos-Graham #203

`eg203-lean/` holds 125 Lean files: bounded closure for m <= 1,000,000, kernel-clean, with explicit
prime witnesses across magnitude ranges. Roughly 1.08 billion values of m were checked to
3 x 10^9 with zero failures.

**The exact gap is named rather than glossed:** a Bombieri-Vinogradov or Bateman-Horn type
quantitative bound, independently confirmed to be unsolved.

Also recorded: the Sierpinski-style covering-system refutation route is **killed**, by a Sylow-2
and Lagrange obstruction, with a persistent 1/128 uncovered sublattice.

## r754 packet

`r754-packet/` carries eight further results on the obstruction calculus, with verification
scripts: CRT full independence rather than mere orthogonality; local obstruction counts as an
exact Poisson-binomial law; Kummer log rows as a representable matroid; synchronization defect as
matroid nullity; vertical lifting defect as a generalized Wieferich relation; SSDP as a
congruence-lattice shortest-vector problem; collision excess as Fourier energy over a rank-r
Kummer Galois group; and a finite-linear Tate-module port.

## papers-pdf

19 compiled PDFs, the same numbered series whose sources are at
github.com/jaredwilder/eg203-kummer-papers, including paper 05, the audit of the routes that fail.

## License

Apache-2.0.
