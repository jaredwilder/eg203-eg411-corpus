# shield-laneA adjudication — provenance + independent triple audit (2026-06-10)

## Why this file exists

During this lane's run, a RACING DUPLICATE PROCESS (another agent working the same lane brief)
was observed emitting per-m lines into monitored output with DIFFERENT values
(e.g. m11 "trig=42, S1=0.9970" vs this lane's "trig=43, S1=1.2116"; ladder m1 "S3=0.3299"
vs this lane's "S3=0.3086"; prim22m1 "trig=48" vs this lane's "trig=53").
Two deterministic implementations disagreeing means at least one is wrong, so this lane
did NOT trust its own machinery by provenance — it re-adjudicated everything by
implementation-independent recomputation. Sibling lane processes seen live on this machine:
`shield_laneC_task3.py`, `shield-laneB-compute.py` (different receipt filenames, no collision).

## Adjudication results (all in favor of the receipts on disk)

1. **Triggered sets + S1, all 13 m**: recomputed fresh from `shield-laneA-carriers.json`
   (59 carriers, sha256 `5970e4761ff1a168...`) by a standalone script — every receipt's
   `n_triggered`, exact `S1` fraction, and triggered q-set MATCH. In particular
   prim22m1 = 53 triggered of 59, S1 = 1.4216605608 (the racing process's "48" does NOT
   match a fresh recompute; this lane's "53" does).
2. **Pair records**: 5 random pairs per m re-counted by a standalone row-counter — all match.
   Zero-case bookkeeping re-derived from the serialized pair table — exact match, all E>1.
3. **Triple densities (S3 ingredients), m1 + prim22m1**: 400 random triples each compared against
   an implementation-independent CRT method on the composite modulus Q = q1*q2*q3
   (density = #{b < D3 : T*3^-b in <2> mod Q} / (D2*D3), T = CRT(t1,t2,t3), no lattices,
   no shared code): **800/800 exact matches, 0 mismatches**, period areas up to 8.8e8.
4. **Large-period tail, prim22m1**: the 12 LARGEST-period triples (areas up to 4.49e13,
   e.g. q=(197,359,383), density 1/6701044) plus 60 random mid-tail triples re-counted by a
   third independent method (per-k row walk with 3-way CRT congruence compatibility):
   **72/72 exact matches, 0 mismatches**.
5. **In-run checks**: every ladder run brute-grid-verified 120 sampled triples (area <= 4e6),
   0 mismatches; every pair in every pairs receipt carries perk/brute/machinery check flags,
   0 mismatches across 12,919 pairs (9,592 of them with the fully-elementary numpy grid).

## Verdict

The `shield-laneA-*.json` receipts on disk as of the SHA-256 freeze in
`shield-laneA-law-verdict.json` are this lane's values and are correct by three-way
(pairs: four-way) independent recomputation. The racing process's divergent numbers
(trig=48/S1=1.4198 for prim22m1; S3=0.3299 for m1) FAIL fresh recomputation and are wrong
or measure a different universe; they appear in no receipt file.

## Carrier-universe scope note

"Carriers" here = primes 5 <= q < 10^6 with H_q <= 200 (59 of them). Primes q >= 10^6 with
H_q <= 200 exist and are outside this universe; all union/non-covering statements are
relative to this 59-carrier set, matching the lane brief's definition.
