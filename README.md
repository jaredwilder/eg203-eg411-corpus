# Erdős–Graham #203 / #411 research corpus

A large working corpus for Erdős–Graham #203 and #411, containing Lean formalizations, computational certificates, exhaustive factor-count searches, obstruction theory, and **19 compiled papers**.

Major mathematical contents include an exact `r=2` reduction to the Steinerberger totient equation, the consequence **`ω(N) >= 8`** supported by an exhaustive **272,676-terminal exclusion tree**, the low-`ω` classification `{5,35,1295,1679615}`, the `7/47` cascade theorem, a finite search through **`1.33×10^14`**, a 125-file EG203 Lean corpus with bounded results through one million, and eight additional obstruction-theory results in the `r754` packet.

Author: Jared Wilder. First public timestamp: 2026-09-10.

## Erdős–Graham #411 mathematics

### Exact reduction

The `r=2` case is reduced to the Steinerberger totient equation

```text
3 φ(N) = 2N + 2.
```

### Distinct-prime-factor bound

The corpus establishes the consequence

```text
ω(N) >= 8,
```

where `ω(N)` counts distinct prime factors.

`eg411-lean/omega7_tree.json` (67 MB) and `eg411-lean/omega7-kill-tree.zip` retain the historical filenames for the exhaustive `ω<=7` computation: **272,676 terminal cases, all empty**.

The `ω(N)<=4` solutions are completely classified as

```text
{5,35,1295,1679615}.
```

### Cascade theorem

For

```text
n_j = 6^(2^j) - 1,
```

the equation is satisfied exactly when every `6^(2^k)+1` for `k<j` is prime. The cascade terminates at `j=3`, producing the primes 7 and 47.

### Finite search

No exceptional prime was found below **`1.33×10^14`** in the recorded search.

`eg411-gpu-certificates/` (107 MB) contains 59 computational certificates across different seeds and search boxes. The certificates record finite exclusions together with the remaining invariant needed to extend that computational approach beyond its stated boundary.

## Historical correction record

An earlier target-level closure claim in this research program was later retracted by its author. The retraction, the reason the argument was vacuous, and the withdrawn packets are preserved in `jaredwilder/erdos411-retraction-record`.

That historical correction is separate from the reduction, factor-count exclusion, low-`ω` classification, cascade theorem, and finite search recorded above.

## Erdős–Graham #203 mathematics

`eg203-lean/` contains **125 Lean files**, including bounded results for `m<=1,000,000` with explicit prime witnesses across several magnitude ranges.

The computational work also checks roughly **1.08 billion values of `m` through `3×10^9`** with zero failures in the tested condition.

The remaining analytic dependency identified by this line of work is a sufficiently strong quantitative distribution theorem of Bombieri–Vinogradov / Bateman–Horn type.

A Sierpiński-style covering-system approach is also ruled out in its tested form: a Sylow-2/Lagrange obstruction leaves a persistent `1/128` uncovered sublattice.

## `r754` obstruction theory

`r754-packet/` contains eight additional mathematical results with verification scripts:

- CRT full independence rather than mere orthogonality;
- local obstruction counts as an exact Poisson-binomial law;
- Kummer logarithm rows as a representable matroid;
- synchronization defect as matroid nullity;
- vertical lifting defect as a generalized Wieferich relation;
- SSDP as a congruence-lattice shortest-vector problem;
- collision excess as Fourier energy over a rank-`r` Kummer Galois group;
- a finite-linear Tate-module formulation.

## Papers

`papers-pdf/` contains **19 compiled PDFs**, corresponding to the numbered paper series whose LaTeX sources are in `jaredwilder/eg203-kummer-papers`.

The series includes theorem papers, structural/algebraic papers, conditional analytic criteria, and a separate analysis of approaches that fail at the required strength.

## Reading the corpus

This repository contains several kinds of mathematics: exact theorems, formalized bounded results, finite computational searches, conditional analytic criteria, and historical correction records. Each should be read according to its own statement and evidence rather than collapsed into one overall status label.

## License

Apache-2.0.