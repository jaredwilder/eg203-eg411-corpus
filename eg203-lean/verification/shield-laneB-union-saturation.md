# LANE B — Union Saturation (entanglement shield) — receipts

Date: 2026-06-10T20:39:47Z · seed 20260610 · n=2,000,000 samples/m · carriers: q<10^6, H_q<=200 · script `shield-laneB-compute.py`
JSON receipt: `shield-laneB-union-saturation.json` (sha256 `8cb6ac4cf7367041e97b4677f34cdd2907eea04e45cfc41973e9262ff6a5c1b3`)

## Carriers — VERIFIED
Exhaustive scan of all primes 5 <= q < 10^6: **59 carriers** with H_q = lcm(ord_q 2, ord_q 3) <= 200. Cross-checked against sympy `n_order` (independent implementation), zero mismatches.

## Per-m sampled union — SUPPORTED-SAMPLED (exact-uniform on the lcm torus)

| m | #trig | sum 1/H | indep. pred. | union (meas.) | uncovered ±95%CI | survivor (k,l) |
|---|---|---|---|---|---|---|
| primorial(first 17 primes)-1 (m=(22 digits)) | 45 | 1.3265 | 0.7540 | 0.73411 | 0.26589 ± 0.00061 | [0, 1] |
| primorial(first 18 primes)-1 (m=(24 digits)) | 48 | 1.3463 | 0.7588 | 0.74490 | 0.25510 ± 0.00060 | [0, 1] |
| primorial(first 19 primes)-1 (m=(25 digits)) | 42 | 1.2930 | 0.7455 | 0.73595 | 0.26405 ± 0.00061 | [0, 1] |
| primorial(first 20 primes)-1 (m=(27 digits)) | 45 | 1.3295 | 0.7547 | 0.74387 | 0.25613 ± 0.00060 | [0, 1] |
| primorial(first 21 primes)-1 (m=(29 digits)) | 45 | 1.3404 | 0.7574 | 0.74903 | 0.25097 ± 0.00060 | [0, 1] |
| primorial(first 22 primes)-1 (m=(31 digits)) | 53 | 1.4217 | 0.7765 | 0.76626 | 0.23374 ± 0.00059 | [0, 1] |
| primorial(first 23 primes)-1 (m=(33 digits)) | 47 | 1.3584 | 0.7618 | 0.74470 | 0.25530 ± 0.00060 | [0, 1] |
| primorial(first 24 primes)-1 (m=(35 digits)) | 46 | 1.3465 | 0.7589 | 0.74427 | 0.25573 ± 0.00060 | [0, 1] |
| primorial(first 25 primes)-1 (m=(37 digits)) | 49 | 1.3769 | 0.7662 | 0.74609 | 0.25391 ± 0.00060 | [0, 1] |
| primorial(first 26 primes)-1 (m=(39 digits)) | 47 | 1.3610 | 0.7624 | 0.74235 | 0.25765 ± 0.00061 | [0, 1] |
| primorial(first 27 primes)-1 (m=(41 digits)) | 51 | 1.3909 | 0.7694 | 0.75108 | 0.24892 ± 0.00060 | [0, 1] |
| primorial(first 28 primes)-1 (m=(43 digits)) | 46 | 1.3506 | 0.7599 | 0.73663 | 0.26337 ± 0.00061 | [0, 1] |
| primorial(first 29 primes)-1 (m=(45 digits)) | 48 | 1.3620 | 0.7626 | 0.74036 | 0.25964 ± 0.00061 | [0, 1] |
| primorial(first 30 primes)-1 (m=(47 digits)) | 48 | 1.3600 | 0.7622 | 0.73662 | 0.26338 ± 0.00061 | [0, 1] |
| primorial(first 31 primes)-1 (m=(49 digits)) | 47 | 1.3608 | 0.7624 | 0.74231 | 0.25769 ± 0.00061 | [1, 0] |
| primorial(first 32 primes)-1 (m=(51 digits)) | 48 | 1.3688 | 0.7642 | 0.74246 | 0.25754 ± 0.00061 | [0, 1] |
| primorial(first 33 primes)-1 (m=(53 digits)) | 47 | 1.3559 | 0.7612 | 0.73535 | 0.26465 ± 0.00061 | [0, 1] |
| primorial(first 34 primes)-1 (m=(56 digits)) | 50 | 1.4051 | 0.7727 | 0.74714 | 0.25286 ± 0.00060 | [0, 1] |
| primorial(first 35 primes)-1 (m=(58 digits)) | 47 | 1.3591 | 0.7620 | 0.73116 | 0.26884 ± 0.00061 | [0, 1] |
| primorial(first 36 primes)-1 (m=(60 digits)) | 47 | 1.3632 | 0.7629 | 0.73976 | 0.26024 ± 0.00061 | [1, 0] |
| primorial(first 37 primes)-1 (m=(62 digits)) | 46 | 1.3544 | 0.7608 | 0.73437 | 0.26563 ± 0.00061 | [0, 1] |
| primorial(first 38 primes)-1 (m=(64 digits)) | 47 | 1.3620 | 0.7626 | 0.73665 | 0.26335 ± 0.00061 | [0, 1] |
| primorial(first 39 primes)-1 (m=(66 digits)) | 47 | 1.3655 | 0.7635 | 0.74157 | 0.25843 ± 0.00061 | [0, 1] |
| primorial(p<=17..18)-1 (m=510509) | 43 | 1.1667 | 0.7096 | 0.72572 | 0.27428 ± 0.00062 | [0, 1] |
| primorial(p<=19..22)-1 (m=9699689) | 45 | 1.2397 | 0.7312 | 0.71543 | 0.28457 ± 0.00063 | [0, 1] |
| primorial(p<=23..28)-1 (m=223092869) | 45 | 1.2555 | 0.7354 | 0.72799 | 0.27201 ± 0.00062 | [0, 1] |
| primorial(p<=29..30)-1 (m=6469693229) | 45 | 1.2937 | 0.7456 | 0.74608 | 0.25392 ± 0.00060 | [0, 1] |
| primorial(p<=31..36)-1 (m=200560490129) | 48 | 1.3567 | 0.7613 | 0.74669 | 0.25331 ± 0.00060 | [0, 2] |
| primorial(p<=37..39)-1 (m=7420738134809) | 47 | 1.3383 | 0.7568 | 0.74187 | 0.25813 ± 0.00061 | [0, 1] |
| m=1831 (m=1831) | 49 | 1.3910 | 0.7695 | 0.77438 | 0.22562 ± 0.00058 | [0, 0] |
| random_1e12_00 (m=1136685364967) | 45 | 1.2660 | 0.7383 | 0.73540 | 0.26460 ± 0.00061 | [0, 0] |
| random_1e12_01 (m=1716086014853) | 40 | 1.0051 | 0.6534 | 0.62210 | 0.37790 ± 0.00067 | [0, 0] |
| random_1e12_02 (m=1237972048159) | 42 | 0.9096 | 0.6166 | 0.61043 | 0.38957 ± 0.00068 | [1, 0] |
| random_1e12_03 (m=1959868227311) | 43 | 1.1910 | 0.7167 | 0.71579 | 0.28421 ± 0.00063 | [0, 0] |
| random_1e12_04 (m=1010309231191) | 40 | 1.1203 | 0.6959 | 0.69300 | 0.30700 ± 0.00064 | [1, 0] |
| random_1e12_05 (m=1646452601003) | 45 | 1.0722 | 0.6763 | 0.67429 | 0.32571 ± 0.00065 | [0, 0] |
| random_1e12_06 (m=1312917569833) | 49 | 1.3443 | 0.7583 | 0.74445 | 0.25555 ± 0.00060 | [0, 2] |
| random_1e12_07 (m=1095912972559) | 40 | 1.1626 | 0.7086 | 0.65566 | 0.34434 ± 0.00066 | [0, 1] |
| random_1e12_08 (m=1588015490869) | 45 | 1.2791 | 0.7417 | 0.73829 | 0.26171 ± 0.00061 | [2, 0] |
| random_1e12_09 (m=1595961832543) | 48 | 1.2062 | 0.7204 | 0.70737 | 0.29263 ± 0.00063 | [0, 0] |
| random_1e12_10 (m=1721972771545) | 43 | 0.8647 | 0.5908 | 0.59115 | 0.40885 ± 0.00068 | [0, 0] |
| random_1e12_11 (m=1011292425437) | 43 | 0.9952 | 0.6498 | 0.64611 | 0.35389 ± 0.00066 | [0, 0] |
| random_1e12_12 (m=1547363891995) | 45 | 1.0486 | 0.6624 | 0.66904 | 0.33096 ± 0.00065 | [0, 1] |
| random_1e12_13 (m=1685478497881) | 44 | 1.2268 | 0.7274 | 0.73580 | 0.26420 ± 0.00061 | [1, 1] |
| random_1e12_14 (m=1549102263353) | 43 | 1.1883 | 0.7160 | 0.71879 | 0.28121 ± 0.00062 | [1, 0] |
| random_1e12_15 (m=1029689373865) | 45 | 0.9897 | 0.6406 | 0.63842 | 0.36158 ± 0.00067 | [0, 0] |
| random_1e12_16 (m=1032800059987) | 48 | 1.3437 | 0.7582 | 0.75785 | 0.24215 ± 0.00059 | [1, 1] |
| random_1e12_17 (m=1709177266529) | 47 | 1.3385 | 0.7569 | 0.75611 | 0.24389 ± 0.00060 | [2, 1] |
| random_1e12_18 (m=1006915342165) | 40 | 0.9246 | 0.6168 | 0.60995 | 0.39005 ± 0.00068 | [0, 0] |
| random_1e12_19 (m=1048815946271) | 44 | 1.1250 | 0.6967 | 0.68411 | 0.31589 ± 0.00064 | [0, 0] |

Sampling is exact-uniform over the joint torus Z_Lk x Z_Ll (Lk=lcm ord_q(2), Ll=lcm ord_q(3) over triggered carriers) via CRT prime-power residues — unbiased for the natural density. Per-carrier sampled densities matched 1/H within CI for every carrier of every m (max abs deviation 8.07e-04).

Each survivor cell (k,l) was re-verified by primitive bigint arithmetic: q does not divide m·2^k·3^l + 1 for ALL carriers (triggered or not). VERIFIED per cell.

## EXACT union, top-8 densest carriers of primorial(first 22 primes)-1 (m = 3217644767340672907899084554129, 31 digits) — VERIFIED

Picked (greedy by density 1/H): [(5, 4), (7, 6), (11, 10), (23, 11), (13, 12), (17, 16), (19, 18), (31, 30)]
Joint torus: 3960 × 7920 = 31,363,200 cells (full period, exact integer count).
- Covered cells: **18,406,080** → exact union = **0.586869** (= 581/990)
- Exact uncovered = **0.413131** (= 409/990)
- Subset density sum Σ1/H = 0.8423; independence would predict union 0.5988
- Sampled (2M) subset uncovered = 0.413516, z = 1.10 vs exact — cross-check PASSED
- Per-carrier exact density = 1/H verified exactly on the torus for all 8 carriers (local law, integer identity count·H = cells).

## Pairwise entanglement law (primorial(first 22 primes)-1) — VERIFIED on tested pairs

All 847 triggered pairs computed exactly on their joint tori (531 skipped by the 4,000,000-cell cap). Law: joint density ∈ {0} ∪ {E/(H1·H2)}, E integer ≥ 1.
- Incompatible (density 0): **118**
- E = 1 (independence-like): **585**
- E > 1 (forced excess overlap): **144** · max E = 8
- Every nonzero joint density had integer E: **True**

## Cross-implementation check — PASSED
Direct bigint-pow path (no tables, no CRT), n=40,000: uncovered 0.23035 vs fast path 0.23374 (z=-1.60).

## SHIELD TEST verdict

- min uncovered = **0.22562** at m=1831
- mean uncovered = 0.28102
- max uncovered = 0.40885 at random_1e12_10
- max union = 0.77438 at m=1831
- covering threat (uncovered < 0.01 for some m): **False**

Labels per PROCESS-GOLD-2026-06-10:
- `carrier_enumeration_q_lt_1e6_H_le_200`: VERIFIED (exhaustive numpy order scan + sympy n_order cross-check)
- `local_law_density_1_over_H`: VERIFIED exactly on the full joint torus for the 8 picked carriers of primorial(22)-1; sampled per-carrier densities match 1/H within CI for all m
- `exact_union_top8_primorial_first22`: VERIFIED (exact integer cell count over the full joint torus)
- `pairwise_joint_density_law_0_or_E_over_H1H2_E_integer`: VERIFIED on 847 computed pairs (531 skipped for size); all nonzero joint densities have integer E>=1: True
- `union_saturation_below_1_for_adversarial_set`: SUPPORTED-SAMPLED (50 m, 2M exact-uniform samples each, 95% CI ~ 0.0007) + VERIFIED exactly for the top-8 subset of primorial(first 22 primes)-1
- `shield_for_EVERY_m`: OPEN as a universal statement - only the 50-m adversarial set was tested; no tested m drives uncovered toward 0

Elapsed: 240.0s · reproduce: `python public/proofs/eg203/verification/shield-laneB-compute.py`
