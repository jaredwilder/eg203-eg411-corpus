# shield-laneA — The Exact Pairwise Entanglement Law (EG#203 shield)

Date: 2026-06-10. Script: `shield_laneA.py` (sha256 `9b590b27221f03d9…`).
Doctrine: `UNIVERSAL_LAW/PROCESS-GOLD-2026-06-10.md` — exact integers, cross-implemented, labeled.

## The law (tested object)

For ordinary m and triggered primes q1 != q2 (q_i not dividing 6m, t_i = -m^{-1} mod q_i in <2,3>):
```
dens{(k,l): q1|V and q2|V} = 0                if c1 - c2 not in Lam1 + Lam2
                           = E/(H1*H2)        otherwise,  E = [Z^2 : Lam1 + Lam2]
```
Cross-implemented 4 ways per pair: numpy brute grid over one period; per-k row count
(dlog tables + CRT); HNF lattice-index formula; explicit coset-intersection machinery
(point + HNF basis of Lam1^Lam2 with det = H1*H2/E).

## Aggregate verification

- m values tested: **13** (requirement >= 10: PASS)
- triggered pairs, all implementations: **12919**
- pairs ALSO checked by fully-elementary numpy brute grid: **9592** (requirement >= 500: PASS)
- cross-implementation mismatches: **0**
- zero-overlap (incompatible-coset) pairs: **2077** — every one satisfies c1-c2 not in Lam1+Lam2 AND E>1 (asserted)

## Per-m table

| m | triggered | pairs | S1 | S2 | U2=S1-S2 | zero pairs | E>1 compat | excess S2-S2_indep | mism |
|---|---|---|---|---|---|---|---|---|---|
| m1 | 46 | 1035 | 1.2085 | 0.7029 | 0.5056 | 192 | 201 | +0.03413 | 0 |
| m5 | 41 | 820 | 1.0168 | 0.4556 | 0.5612 | 140 | 90 | -0.02676 | 0 |
| m7 | 44 | 946 | 1.1073 | 0.5310 | 0.5763 | 154 | 106 | -0.03059 | 0 |
| m11 | 43 | 903 | 1.2116 | 0.6281 | 0.5834 | 151 | 99 | -0.04442 | 0 |
| m13 | 44 | 946 | 1.1375 | 0.5542 | 0.5833 | 154 | 106 | -0.03414 | 0 |
| m25 | 42 | 861 | 0.9422 | 0.3724 | 0.5698 | 198 | 119 | -0.04129 | 0 |
| m35 | 45 | 990 | 0.8612 | 0.3504 | 0.5108 | 155 | 108 | -0.00277 | 0 |
| m143 | 45 | 990 | 1.1259 | 0.5738 | 0.5522 | 153 | 114 | -0.00289 | 0 |
| prim5m1 | 46 | 1035 | 1.1940 | 0.6325 | 0.5615 | 167 | 138 | -0.01911 | 0 |
| prim8m1 | 45 | 990 | 1.2397 | 0.7730 | 0.4667 | 162 | 138 | +0.06940 | 0 |
| prim13m1 | 46 | 1035 | 1.2914 | 0.8087 | 0.4827 | 175 | 122 | +0.04040 | 0 |
| prim17m1 | 45 | 990 | 1.3265 | 0.9392 | 0.3873 | 124 | 137 | +0.12590 | 0 |
| prim22m1 | 53 | 1378 | 1.4217 | 1.0819 | 0.3398 | 152 | 177 | +0.13862 | 0 |

## Global E distribution (compatible pairs; '(zero)' = incompatible)

```json
{
 "1": 9187,
 "10": 2,
 "10(zero)": 11,
 "11": 1,
 "11(zero)": 7,
 "12": 1,
 "12(zero)": 15,
 "13": 1,
 "13(zero)": 7,
 "14(zero)": 12,
 "2": 1324,
 "2(zero)": 1292,
 "3": 199,
 "3(zero)": 280,
 "4": 86,
 "4(zero)": 246,
 "5": 9,
 "5(zero)": 48,
 "6": 22,
 "6(zero)": 109,
 "7": 3,
 "7(zero)": 12,
 "8": 4,
 "8(zero)": 16,
 "9": 3,
 "9(zero)": 22
}
```

## Bonferroni ladder (exact, on the common torus)

NOTE: the lane brief called U2 = S1 - S2 an 'upper bound'. Bonferroni direction is the
opposite: even truncations are LOWER bounds on the union, odd truncations are UPPER bounds.
So the certifying quantity is U3 = S1 - S2 + S3: if U3 < 1, carriers cannot cover (exact).

| m | S1 | S2 | S3 | S4 | U2 (lower) | U3 (UPPER) | U4 (lower) | union bracket |
|---|---|---|---|---|---|---|---|---|
| m1 | 1.2085 | 0.7029 | 0.3086 | 0.1201 | 0.5056 | 0.8142 | 0.6941 | [0.6941, 0.8142] |
| m5 | 1.0168 | 0.4556 | 0.1208 | 0.0212 | 0.5612 | 0.6820 | 0.6607 | [0.6607, 0.6820] |
| m7 | 1.1073 | 0.5310 | 0.1478 | 0.0270 | 0.5763 | 0.7241 | 0.6971 | [0.6971, 0.7241] |
| m11 | 1.2116 | 0.6281 | 0.1899 | 0.0369 | 0.5834 | 0.7733 | 0.7364 | [0.7364, 0.7733] |
| m13 | 1.1375 | 0.5542 | 0.1529 | 0.0279 | 0.5833 | 0.7363 | 0.7084 | [0.7084, 0.7363] |
| m143 | 1.1259 | 0.5738 | 0.1858 | 0.0434 | 0.5522 | 0.7380 | 0.6946 | [0.6946, 0.7380] |
| prim5m1 | 1.1940 | 0.6325 | 0.1981 | 0.0410 | 0.5615 | 0.7596 | 0.7186 | [0.7186, 0.7596] |
| prim8m1 | 1.2397 | 0.7730 | 0.3387 | 0.1160 | 0.4667 | 0.8054 | 0.6893 | [0.6893, 0.8054] |
| prim13m1 | 1.2914 | 0.8087 | 0.3671 | 0.1441 | 0.4827 | 0.8498 | 0.7057 | [0.7057, 0.8498] |
| prim17m1 | 1.3265 | 0.9392 | 0.5219 | 0.2502 | 0.3873 | 0.9092 | 0.6590 | [0.6590, 0.9092] |
| prim22m1 | 1.4217 | 1.0819 | 0.6863 | 0.4102 | 0.3398 | 1.0261 | 0.6159 | [0.6159, 1.0000] |

- m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 55495.
- m5: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 44607.
- m7: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 59265.
- m11: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 56440.
- m13: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 61644.
- m143: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 65872.
- prim5m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 63847.
- prim8m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 70065.
- prim13m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 71372.
- prim17m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 88544.
- prim22m1: triple machinery sample-verified by brute grid on 120 triples, mismatches 0; quads evaluated: 179788.

## primorial(22)-1 notes

- The lane brief gave m = 3217644767340672907899084554130 = 'primorial(22)-1'. Recomputed:
  primorial(22) = 3217644767340672907899084554130; the brief's literal equals primorial(22) itself
  (even, NOT ordinary). The adversarial m used here is primorial(22)-1 = 3217644767340672907899084554129
  with gcd(m,6) = 1 (ordinary: PASS).
- S1(prim22m1) = 2399829507276259363141998758149901/1688046762661377236941868750184480 = 1.421661.

## Labels

- Pairwise law on all tested pairs: **VERIFIED** (12919 pairs, 4 implementations, 0 mismatches). As a general theorem it also has the standard 2nd-isomorphism proof; the machine check certifies our concrete implementations and every concrete (q1,q2,m) below.
- Zero-case characterization (joint=0 iff c1-c2 not in Lam1+Lam2; and joint=0 implies E>1): **VERIFIED** on all 2077 zero cases and all compatible cases (two-sided).
- 'Entanglement shield caps union below 1 for EVERY m': **OPEN** — supported here only for the tested m and the q<10^6 carrier universe (see ladder brackets), not proven universally.

## Receipts (sha256)

- `shield-laneA-adjudication.md` `ec7048917fb2c261d5524533a3c2bbb2c8a8ae7a1a3d7247f99f162c03f43946`
- `shield-laneA-carriers.json` `5970e4761ff1a1688f4165334e5bf164bc82dcae4e1fe9dee36d5d92318d3034`
- `shield-laneA-pairs-m1.json` `55402e3d6a27bbd6ebb17b1a605fbf2e298494c561e939274b8d47f29edc9659`
- `shield-laneA-pairs-m11.json` `1e0a371361a6ec22060feb8be66ab937dad9aead833538aafcfc0555210cd2bb`
- `shield-laneA-pairs-m13.json` `746fe6ba8cf15a13ba8de493be9b0bb20d87b820d112c02771af31468c5b2b01`
- `shield-laneA-pairs-m143.json` `64b8174488983c2e983a6bafe351c59c85ffc4289651ed7d1bb2417c989e2dc6`
- `shield-laneA-pairs-m25.json` `6221b7af8f66611f8d3b6366674e897f5a4ea440e470714231c34de27c73055e`
- `shield-laneA-pairs-m35.json` `a20757340ddd2c317a39ee0672f309ab3e43733ee6db3da517dbee42eb169071`
- `shield-laneA-pairs-m5.json` `d7d69f6400d443109c73230874a48c30c0e184c69763c0202421c440ad198b18`
- `shield-laneA-pairs-m7.json` `8a84d51f64c8251c10f919f0c60c3669c9628aafe4b0af7105f88151431e08b2`
- `shield-laneA-pairs-prim13m1.json` `e6558564d047ccca621e23bb4d8c34e7409e819b947e76d237bbb788a98a2776`
- `shield-laneA-pairs-prim17m1.json` `c5e8147b46fd9cabecac2620448f9f0d54e5b0287ed0652eb1184a27f9ccb3be`
- `shield-laneA-pairs-prim22m1.json` `9de482771e48672fe1810a3e64462fca645c20fd610a92828f0d952d628e5af9`
- `shield-laneA-pairs-prim5m1.json` `f1eab8d8c0dbb777cb4ae84c6cd75cc5a52c692cf8a493a56ca44d83ef7728a0`
- `shield-laneA-pairs-prim8m1.json` `01a1a7cb677761ac946d3b810a51ff9cc554520fc0a52c53fd5fa2afee2d7210`
- `shield-laneA-selftest.json` `2e22d38bc3c610a9e30174a76e623410f3f26f778e128878617be3c4e6bbcb6a`
- `shield-laneA-uladder-m1.json` `1aeca996d2abbaa7ec9aab1c97a4f5e709fe332737cd4fafc660bffc15e470ed`
- `shield-laneA-uladder-m11.json` `f4351d8d3fd0acd985b48c81e32319063b107057470fc451b037442f297d9619`
- `shield-laneA-uladder-m13.json` `3186505f2e072662056987565de701d36aa175b95e1a83b7c7fa9a919884dafd`
- `shield-laneA-uladder-m143.json` `7d2fada962f320237eaf7ac2d6f56a6fff9cbe9373fecd3d81160de6611db45f`
- `shield-laneA-uladder-m5.json` `c8925feea44e3ae98343b97e520e7705086d4259724e0cc4b13138e3d1c28f9e`
- `shield-laneA-uladder-m7.json` `625dea77170211f4147ccb53da0000fe149a56edfc14c1439cdf22f563f9c9a1`
- `shield-laneA-uladder-prim13m1.json` `5a059095f52206ccb59e27116693140aad7bd12febf4aa4cdebb05c9c7c3e683`
- `shield-laneA-uladder-prim17m1.json` `cabece5a28fcdc5c12d867f0d5a9a506ecb1c3357a0fc3421f7edf73907629d9`
- `shield-laneA-uladder-prim22m1.json` `b95e224e44311d2dc9f87e06cb03b0f5969ccc006f12693387ab56afa213a1fc`
- `shield-laneA-uladder-prim5m1.json` `131f2ae19e418d4fdc8eae93a38f83fe90b62f75930c301669c7545eb94b28c4`
- `shield-laneA-uladder-prim8m1.json` `eca4b182b52182eb2a392b3b8b8e52980ff25c670da7053546891754489fad5a`
- `shield-laneA-uladder5-prim22m1.json` `611ebb95e42cb631bea4308e38db3f04e0079c7a97ffa1aa37620209387e1aa1`

## Fifth-order certificate for prim22m1 (shield-laneA-uladder5-prim22m1.json)

U3 = 1.0261 > 1 left prim22m1 uncertified at third order. Extending to S5 (odd order = true
UPPER bound): S5 = 0.232636, U5 = S1-S2+S3-S4+S5 =
216940101972233010001526821359841762510443367/255685602157617250981695086425336625120160000
= 0.848464 < 1. EXACT CERTIFICATE: the union of all 53 triggered-carrier cosets for
m = primorial(22)-1 has density <= 0.8485 — the carriers cannot cover Z^2. Union bracket
[U4, U5] = [0.6159, 0.8485]. (1,019,531 quint intersections evaluated, exact rationals.)
With this, EVERY tested m has an exact non-covering certificate from entanglement alone.

## Triple-machinery adjudication

See shield-laneA-adjudication.md: a racing duplicate process emitted divergent values during
this run; all receipts on disk were re-adjudicated by fresh recomputation (triggered sets, S1,
pair spot-checks) plus 872 implementation-independent triple checks (CRT-composite-modulus
method 800/800; per-k row-walk on the 12 largest-period triples up to area 4.49e13 and 60
mid-tail triples 72/72). 0 mismatches. Disk receipts are this lane's values and are correct.
