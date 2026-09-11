# eg203-eg411-corpus

**The full working corpus for Erdős–Graham #203 and #411**, including Lean proofs, GPU search
certificates, the omega kill tree, the r754 obstruction-theory packet, and 19 compiled papers.

Headline mathematical assets include an exact r=2 reduction to the Steinerberger totient equation,
an unconditional **omega(N) >= 8** consequence with a **272,676-terminal empty kill tree**, the
low-omega classification `{5, 35, 1295, 1679615}`, the 7/47 cascade theorem, a search frontier to
**1.33 × 10^14**, a 125-file EG203 Lean corpus with bounded closure through one million, and eight
further obstruction-calculus results in the r754 packet.

Author: Jared Wilder. First public timestamp: 2026-09-10.

## Erdős–Graham #411 mathematics

**Exact reduction.** The r=2 case is reduced to the Steinerberger totient equation

`3 phi(N) = 2N + 2`.

**Unconditional consequence.** `omega(N) >= 8`, where `omega` counts distinct prime factors.

**Exhaustion behind the bound.** `eg411-lean/omega7_tree.json` (67 MB) and
`eg411-lean/omega7-kill-tree.zip` carry the complete `omega <= 7` kill tree: **272,676 terminals,
all empty**. The `omega(N) <= 4` solutions are completely classified as

`{5, 35, 1295, 1679615}`.

**Cascade theorem.** `n_j = 6^(2^j) - 1` solves the equation exactly when every
`6^(2^k) + 1` for `k < j` is prime; the cascade terminates at `j = 3`, yielding exactly the primes
7 and 47.

**Search frontier.** No exceptional prime appears below **1.33 × 10^14**, extending the previously
recorded bound by roughly 13,000 times.

**GPU certificate bank.** `eg411-gpu-certificates/` (107 MB) holds 59 search certificates across
seeds and box sizes, all rows forced to depth 4 with no survivor, plus the recorded `x3_lower`
floor and scale-stress runs. This is a finite obstruction layer; the global GPU route still has a
named lower-jump invariant obligation.

## Historical claim record

An earlier target-level closure claim in this program was later retracted by its author. The full
retraction, the structural reason the claimed proof was vacuous, and the packets it withdraws are
preserved at `jaredwilder/erdos411-retraction-record`.

That historical record is retained as provenance. It is separate from the reduction, kill tree,
classification, cascade, and finite search results above, each of which should be read at its own
stated scope.

## Erdős–Graham #203 mathematics

`eg203-lean/` holds **125 Lean files**: bounded closure for `m <= 1,000,000`, kernel-clean, with
explicit prime witnesses across magnitude ranges. Roughly **1.08 billion values of m** were checked
to `3 × 10^9` with zero failures.

The remaining analytic seam is named explicitly: a Bombieri–Vinogradov or Bateman–Horn type
quantitative bound.

The corpus also contains a killed Sierpiński-style covering-system route: a Sylow-2/Lagrange
obstruction leaves a persistent `1/128` uncovered sublattice.

## r754 obstruction packet

`r754-packet/` carries eight further mathematical results with verification scripts:

- CRT full independence rather than mere orthogonality;
- local obstruction counts as an exact Poisson-binomial law;
- Kummer log rows as a representable matroid;
- synchronization defect as matroid nullity;
- vertical lifting defect as a generalized Wieferich relation;
- SSDP as a congruence-lattice shortest-vector problem;
- collision excess as Fourier energy over a rank-r Kummer Galois group;
- a finite-linear Tate-module port.

## Papers

`papers-pdf/` contains **19 compiled PDFs**, the same numbered series whose sources are at
`jaredwilder/eg203-kummer-papers`, including the failed-routes audit as one component of the larger
paper program.

## Scope

The corpus mixes exact theorems, formalized bounded results, finite computational frontiers,
conditional analytic architecture, and historical claim records. Those evidence classes are
separated above rather than collapsed into one status sentence.

## License

Apache-2.0.
