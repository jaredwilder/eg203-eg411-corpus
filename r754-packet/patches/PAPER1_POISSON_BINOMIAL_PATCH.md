# Patch for Paper 1 - Exact Poisson-Binomial Obstruction Count

Insert after CRT orthogonality.

```latex
\section{Exact distribution over a prime set}

Let \(\mathcal Q\) be a finite set of primes, \(P=\prod_{q\in\mathcal Q}q\), and
\[
B_q(m)=\mathbf 1_{\Gamma_q}(-m^{-1}),\qquad m\in(\mathbb Z/P\mathbb Z)^*.
\]
Then the variables \(B_q\) are independent Bernoulli variables with
\[
\mathbb P(B_q=1)=|\Gamma_q|/(q-1).
\]
Consequently
\[
N_{\mathcal Q}(m)=\sum_{q\in\mathcal Q}B_q(m)
\]
has generating function
\[
\mathbb E z^{N_{\mathcal Q}}=\prod_{q\in\mathcal Q}
\left(1-\frac{|\Gamma_q|}{q-1}+\frac{|\Gamma_q|}{q-1}z\right).
\]
```

This upgrades the existing CRT orthogonality result from covariance cancellation to full independence.
