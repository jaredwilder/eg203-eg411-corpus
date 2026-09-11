# R659 Scale-Stress Report

## Round Binary

Does the lower-jump floor survive larger constructed records, or does scale weaken the route?

## Hard Output

- R652 artifact: `r652_gpu_10m_box_maxexp8_seed659_top2048_fastfactor.json`
- Mode: `box`
- Max exponent: `8`
- Samples: `10,000,000`
- Strict GPU candidates: `5,002,158`
- Exact checks: `2,048`
- Candidate p-digit range in exact checks: `220` to `751`
- Exact status counts: `C2_FACTORING_INCOMPLETE=14`, `P_COMPOSITE_OR_NOT_PROVED_BY_SYMPY=2033`, `DEPTH4_FORCED=1`
- R652 verdict: `closed_by_this_pass=true`
- Runtime: `248.732s`

## Closure

- R654 artifact: `r654_rough_cofactor_certificates_10m_box_maxexp8_seed659_top2048.json`
- Hard candidates checked: `14`
- Status counts: `DEPTH4_FORCED_BY_ROUGH_C2=14`
- Minimum `x3_lower`: `0.9861316945885408`
- Minimum `x4_lower`: `1.0520840086233827`
- Hard-row p-digit range: `220` to `652`

## Mattering Percent

- Before R657 20M pass: `63.67%`
- After R657 20M pass: `65.00%`
- After R659 max-exp 8 scale stress: `63.84%`

## Verdict

`ESCALATION`

This does not kill the route, because every hard row still closes by depth 4. It does weaken the headline-proof trajectory: the lower-jump floor dropped from `0.9908274015338756` to `0.9861316945885408`, and the finite margin factor dropped from `4.066406391118937` to `2.6768046211029115`.

## KBK Packet

Route: Cambie-tail rough-cofactor closure plus lower-jump threshold.

Next binary:

```text
Prove the scale deterioration is bounded OR kill this route as finite-only.
```

Missing variable:

```text
uniform lower bound for x3_lower as p grows
```
