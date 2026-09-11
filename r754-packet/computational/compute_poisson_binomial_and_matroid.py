from __future__ import annotations
from fractions import Fraction
from itertools import combinations

def poisson_binomial_coeffs(ps):
    """Return coefficients of prod_q (1-p_q + p_q z), exact Fractions."""
    coeffs = [Fraction(1)]
    for p in ps:
        new = [Fraction(0)] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i] += c * (1 - p)
            new[i+1] += c * p
        coeffs = new
    return coeffs

def rank_mod_l(rows, ell):
    rows = [list(map(lambda x: x % ell, r)) for r in rows if any(x % ell for x in r)]
    if not rows:
        return 0
    m, n = len(rows), len(rows[0])
    rank = 0
    col = 0
    while rank < m and col < n:
        piv = None
        for i in range(rank, m):
            if rows[i][col] % ell:
                piv = i
                break
        if piv is None:
            col += 1
            continue
        rows[rank], rows[piv] = rows[piv], rows[rank]
        inv = pow(rows[rank][col], -1, ell)
        rows[rank] = [(x * inv) % ell for x in rows[rank]]
        for i in range(m):
            if i != rank and rows[i][col] % ell:
                factor = rows[i][col]
                rows[i] = [(rows[i][j] - factor * rows[rank][j]) % ell for j in range(n)]
        rank += 1
        col += 1
    return rank

def matroid_nullity(rows, subset, ell):
    selected = [rows[i] for i in subset]
    return len(selected) - rank_mod_l(selected, ell)

def tutte_data(rows, ell):
    n = len(rows)
    full_rank = rank_mod_l(rows, ell)
    data = {}
    for k in range(n+1):
        for S in combinations(range(n), k):
            rS = rank_mod_l([rows[i] for i in S], ell)
            a = full_rank - rS
            b = len(S) - rS
            data[(a,b)] = data.get((a,b), 0) + 1
    return data

if __name__ == "__main__":
    ps = [Fraction(1,2), Fraction(1,3), Fraction(1,5)]
    print("Poisson-binomial coefficients:", poisson_binomial_coeffs(ps))
    rows = [(1,2,3), (2,4,6), (1,0,1), (0,1,1)]
    ell = 7
    print("rank:", rank_mod_l(rows, ell))
    print("Tutte exponent-count data:", tutte_data(rows, ell))
