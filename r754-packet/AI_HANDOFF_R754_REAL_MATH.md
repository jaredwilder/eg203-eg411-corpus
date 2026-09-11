# AI Handoff - R754 Real Math Addenda

## New theorem note

`07_exact_distribution_matroid_lifting_addenda.tex`

## The new hard content

1. Exact CRT independence of local obstruction indicators.
2. Exact Poisson-binomial distribution for obstruction counts.
3. Erdős-Kac normalization criterion via Lindeberg-Feller.
4. Kummer log matroid as representable matroid.
5. Synchronization defect equals matroid nullity.
6. Kummer Tutte polynomial packages all first-level defects.
7. Relation homomorphism \(\lambda_q\) for prime-power lifting.
8. Vertical lifting defect = generalized Wieferich relation.
9. Rank-one equivalence to classical Wieferich criterion.
10. SSDP is an explicit congruence-lattice SVP.
11. Collision-excess Parseval identity over \(\mathbb F_\ell^r\).
12. Hyperplane subextensions control collision excess.
13. Finite-linear/Tate-module obstruction calculus.

## Where to integrate

- Paper 1: add the Poisson-binomial law section.
- Paper 6: add matroid, Wieferich, collision-excess sections.
- Program overview: add Tate-module port and SSDP as new branches.
- Computational stack: add `compute_poisson_binomial_and_matroid.py`.

## No weakening

These are finite algebra/probability results. They do not prove EG203. They strengthen the stack with exact reusable machinery.
