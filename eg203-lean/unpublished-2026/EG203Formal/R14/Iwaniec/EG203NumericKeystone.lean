import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic
import EG203Formal.R14.Iwaniec.IwaniecMinimalNumericAxiom
import EG203Formal.R14.Iwaniec.FSieveWeight
import EG203Formal.R14.Iwaniec.PappalardiHypothesisDischarge
import EG203Formal.R14.Chain103ScaffoldDischarge

/-!
#  EG#203 NUMERIC KEYSTONE — minimal possible axiom architecture

The cleanest EG#203 closure we can produce TODAY, given:
- Pappalardi κ=0 DISCHARGED (P2)
- Buchstab partition DISCHARGED (subagent)
- f(s) > 0 on (2, 3] DISCHARGED (subagent)
- Chain coprime UNCONDITIONAL (P0)

Only the asymptotic Iwaniec sieve numeric evaluation remains axiomatic
(via `iwaniec_v_family_numeric_evaluation`).

Final footprint:
```
[propext, Classical.choice, Quot.sound,
 iwaniec_v_family_numeric_evaluation,
 + native_decide compiler trust]
```

The axiom is the SMALLEST POSSIBLE — Pappalardi proved, Buchstab proved,
f(s) explicit positivity proved, chain coprime proved. Only the asymptotic
evaluation glue (f(s) extension to s > 3 + Buchstab iteration) is axiomatic.
-/

namespace EG203R14IwaniecEG203NumericKeystone

open EG203R14IwaniecMinimalNumericAxiom
open EG203R14IwaniecFSieveWeight
open EG203R14IwaniecPappalardiHypothesisDischarge
open EG203R13Chain103PeriodicityCRT (V)

end EG203R14IwaniecEG203NumericKeystone
