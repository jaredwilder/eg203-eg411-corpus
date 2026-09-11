# Lane C receipt 0 — carrier census + infrastructure cross-checks

Date: 2026-06-10. Scripts: `shield_laneC_common.py` (SHA-256 in JSON meta).
JSON: `shield-laneC-0-carriers.json`. Cache: `shield-laneC-orders-cache.npz`.
Doctrine: PROCESS-GOLD-2026-06-10 (execute everything, cross-implement load-bearing claims).

## What was computed (from scratch, nothing reused from prior sessions)

For every prime 3 < q <= 10^6 (78,496 primes): d2 = ord_q(2), d3 = ord_q(3),
H_q = lcm(d2,d3), via trial-division factorization of q-1 + order reduction.

**Carrier census: exactly 59 primes q <= 10^6 with H_q <= 200** (the setup said
"~50-60" — confirmed, the exact number is 59).

## Cross-implementations (all PASS — verdict VERIFIED)

1. **sympy.n_order** (independent engine) on 30 seeded-random primes: 0 mismatches.
2. **Brute cycle-walk orders** (no factorization at all — multiply until 1) for ALL
   59 carriers: d2, d3, H all match.
3. **Route-B census** (fully independent characterization): q is a carrier iff
   q | gcd(2^H - 1, 3^H - 1) for some H <= 200. Factoring all 200 gcds and
   collecting prime factors <= 10^6 gives a set EXACTLY equal to the order-route
   set: routeA_count = routeB_count = 59, symmetric difference empty.
4. **Triggered test** `pow(-m^{-1} mod q, H_q, q) == 1` vs brute enumeration of the
   full subgroup <2,3> mod q (also asserting |<2,3>| == H_q cell-by-cell) on 200
   seeded-random (m, q) pairs: 0 mismatches.

## Grade

- Carrier list (59 entries, in JSON): **VERIFIED** (two independent routes agree exactly).
- Triggered-decision procedure: **VERIFIED** on 200 sampled pairs against brute
  enumeration (the subgroup identity <2,3> = unique subgroup of order lcm in a
  cyclic group is a theorem, not sampled).
