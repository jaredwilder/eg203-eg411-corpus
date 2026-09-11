# R660/R661 Scale-Stress Report

## Round Binary

Prove the scale deterioration is bounded OR kill this route as finite-only.

## R660 Hard Output

- R652 artifact: `r652_gpu_8m_box_maxexp12_seed660_top2048_fastfactor.json`
- Max exponent: `12`
- Samples: `8,000,000`
- Strict GPU candidates: `4,000,639`
- Exact checks: `2,048`
- Candidate p-digit range in exact checks: `220` to `1049`
- Exact status counts: `C2_FACTORING_INCOMPLETE=9`, `P_COMPOSITE_OR_NOT_PROVED_BY_SYMPY=2039`
- R652 verdict: `closed_by_this_pass=true`
- R654 closure: `DEPTH4_FORCED_BY_ROUGH_C2=9`
- Minimum `x3_lower`: `0.985369284614279`
- Minimum `x4_lower`: `1.0486247958755877`

## R661 Hard Output

- R652 artifact: `r652_gpu_8m_box_maxexp16_seed661_top4096_fastfactor.json`
- Max exponent: `16`
- Samples: `8,000,000`
- Strict GPU candidates: `4,001,943`
- Exact checks: `4,096`
- Candidate p-digit range in exact checks: `220` to `1373`
- Exact status counts: `C2_FACTORING_INCOMPLETE=8`, `P_COMPOSITE_OR_NOT_PROVED_BY_SYMPY=4087`, `DEPTH4_FORCED=1`
- R652 verdict: `closed_by_this_pass=true`
- R654 closure: `DEPTH4_FORCED_BY_ROUGH_C2=8`
- Minimum `x3_lower`: `0.9849996381393205`
- Minimum `x4_lower`: `1.0461169979767155`

## Percent

- Before R657: `63.67%`
- After R657: `65.00%`
- After R659 max-exp 8: `63.84%`
- After R660 max-exp 12: `63.68%`
- After R661 max-exp 16: `63.61%`

## Verdict

`ESCALATION`

All hard rows still close by depth 4, so this route is not dead. But the observed lower-jump floor deteriorated across all three scale probes:

```text
0.9908274015338756
0.9861316945885408
0.985369284614279
0.9849996381393205
```

More raw scale search is now low-yield unless it produces a new worst floor or a survivor. The material path is the invariant itself:

```text
Prove a uniform lower bound for x3_lower as p grows,
or demote the Cambie-tail route to finite-only.
```
