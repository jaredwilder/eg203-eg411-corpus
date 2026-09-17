# Erdős–Graham #203 / #411 research corpus

A combined source corpus for two Erdős–Graham problems, containing Lean formalizations, finite searches, exact obstruction calculations, computational certificates, and 19 compiled papers.

The mathematical programs are distinct; they share a repository only because their source material was developed and archived together.

## Erdős–Graham #411

For the `r=2` equation, the work reduces the problem to

\[
3\varphi(N)=2N+2.
\]

The corpus contains several exact consequences and finite results around this equation.

### Low prime-factor structure

The recorded finite classification for `\omega(N)\le4` is

\[
\boxed{N\in\{5,35,1295,1679615\}}.
\]

An exhaustive exclusion tree with **272,676 terminal cases** rules out the next low-`\omega` range used in the program and yields the recorded lower bound

\[
\omega(N)\ge8
\]

for any further solution covered by that reduction.

The source objects are `eg411-lean/omega7_tree.json` and `eg411-lean/omega7-kill-tree.zip`.

### Cascade family

For

\[
n_j=6^{2^j}-1,
\]

the totient equation holds exactly when all preceding numbers

\[
6^{2^k}+1
\]

are prime. The cascade terminates at `j=3`, with the prime steps 7 and 47.

### Finite search

The corpus records a search through approximately

\[
1.33\times10^{14},
\]

with 59 associated finite-search certificate files under `eg411-gpu-certificates/`.

A historical proof route based on a semantically insufficient formal check was later withdrawn; that source history is isolated in [`erdos411-retraction-record`](https://github.com/jaredwilder/erdos411-retraction-record). The surviving reduction, factor-count, cascade, and finite-search mathematics belongs in the main #411 program rather than in the retraction record.

## Erdős–Graham #203

`eg203-lean/` contains **125 Lean files**, including bounded statements with explicit prime witnesses through `m<=1,000,000`.

The accompanying computation tests roughly **1.08 billion values through `3×10^9`** with no failures in the finite condition being checked.

A Sierpiński-style covering route is also excluded in the tested formulation: the Sylow-2/Lagrange obstruction leaves a persistent `1/128` uncovered sublattice.

The remaining analytic route is expressed in terms of a quantitative distribution theorem for the relevant prime/Kummer data. The exact finite prime-fibre approach has a focused home in [`erdos203`](https://github.com/jaredwilder/erdos203), while the subgroup/Kummer obstruction theory is in [`erdos203-obstruction-calculus`](https://github.com/jaredwilder/erdos203-obstruction-calculus).

## Additional obstruction structure

The `r754-packet/` develops eight further algebraic/combinatorial coordinates:

- CRT full independence;
- exact Poisson-binomial local obstruction counts;
- Kummer logarithm rows as a representable matroid;
- synchronization defect as matroid nullity;
- vertical lifting defect as a generalized Wieferich relation;
- SSDP as a congruence-lattice shortest-vector problem;
- collision excess as Fourier energy on a rank-`r` Kummer Galois group;
- a finite-linear Tate-module formulation.

## Papers

`papers-pdf/` contains **19 compiled PDFs**. The corresponding LaTeX sources and paper-by-paper index are maintained in [`eg203-kummer-papers`](https://github.com/jaredwilder/eg203-kummer-papers).

## Reading map

Use this repository for the combined source corpus and historical computation files. For the current mathematical presentation, prefer the focused #203 and #411 repositories linked above.

Author: Jared Wilder. License: Apache-2.0.
