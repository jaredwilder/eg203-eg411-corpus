# Patch for Paper 6 - Matroid + Wieferich + Collision Excess

Add three sections:

1. Kummer log matroid:
\[
\rho_\ell(S)=\rank_{\mathbb F_\ell}\{x_\ell(q):q\in S\},
\qquad
\eta_\ell(S)=|S|-\rho_\ell(S).
\]
Then first-level synchronization defect equals matroid nullity:
\[
\delta_\ell(S;\mathbf a)=\eta_\ell(S).
\]

2. Generalized Wieferich relation map:
\[
R_q(\mathbf a)=\{n\in\mathbb Z^r:\mathbf a^n\equiv1\pmod q\},
\]
\[
\lambda_q(n)=\frac{\mathbf a^n-1}{q}\pmod q.
\]
Then \(K_1\ne1\) iff \(\lambda_q\) is nonzero.  For \(r=1\), \(K_1=1\) iff \(a^{q-1}\equiv1\pmod{q^2}\).

3. Collision-excess Parseval:
\[
\mathcal C_\ell(N)=\sum_{v\in\mathbb F_\ell^r}(N(v)-\bar N)^2
=
\ell^{-r}\sum_{A\ne0}|\widehat N(A)|^2.
\]
Each nonzero Fourier mode corresponds to an order-\(\ell\) Kummer hyperplane subextension.
