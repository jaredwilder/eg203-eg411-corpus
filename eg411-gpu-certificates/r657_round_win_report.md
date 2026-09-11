# R657 Round Win Report

## Binary

Can a fresh, larger adversarial RTX pass break the observed lower-jump floor, or does the floor survive?

## Inputs

- GPU hunter: `UNIVERSAL_LAW/oracle/math/recovered/erdos_411_r652_engineered_depth4_survivor_hunter.py`
- Rough-cofactor closure: `UNIVERSAL_LAW/oracle/math/recovered/erdos_411_r654_rough_cofactor_certificate.py`
- Constant extractor: `UNIVERSAL_LAW/oracle/math/recovered/erdos_411_r656_lower_jump_constants.py`

## Hard Output

- R652 artifact: `r652_gpu_20m_box_seed657_top4096_fastfactor.json`
- Mode: `box`
- Samples: `20,000,000`
- Strict GPU candidates: `10,001,311`
- Exact checks: `4,096`
- Exact status counts: `C2_FACTORING_INCOMPLETE=38`, `P_COMPOSITE_OR_NOT_PROVED_BY_SYMPY=4056`, `DEPTH4_FORCED=2`
- R652 verdict: `closed_by_this_pass=true`
- Runtime: `192.073s`

## Closure

- R654 artifact: `r654_rough_cofactor_certificates_20m_box_seed657_top4096.json`
- Hard candidates checked: `38`
- Status counts: `DEPTH4_FORCED_BY_ROUGH_C2=38`
- Minimum `x3_lower`: `0.9936682749996613`
- Minimum `x4_lower`: `1.0659384100373508`

## Combined Constant

- R656 artifact: `r656_lower_jump_constants_with_20m_seed657.json`
- Total rough-cofactor certificates included: `59`
- All input certificates depth-4 forced: `true`
- Observed minimum `x3_lower`: `0.9908274015338756`
- Observed minimum `x4_lower`: `1.0642041710859147`
- Worst certificate remains from the earlier R646-neighborhood pass, input rank `15`.

## Win

The 20M seed-657 broad-box pass did not break the lower-jump floor. It added 38 new hard-row closures and raised the adversarial sample base while preserving the finite theorem constant:

```text
If a strict-underflow Cambie record has x3_lower >= 0.990827401533875607
and C3 <= 4p^3 with p having at most 434020 digits,
then depth-4 overshoot is forced by the primorial lower bound.
```

This is not a global proof. It is a stronger finite closure artifact and a cleaner target for the missing global invariant.
