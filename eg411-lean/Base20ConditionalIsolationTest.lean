import Base20Conditional

/-!
# TEST FILE — isolation demonstration only. NOT part of the real target.

This file is throwaway scaffolding for a one-time check: that `base_sequenceable_upto_20`
(declared in `Base20Conditional.lean`) is never silently hidden. Any theorem that uses it —
even indirectly, purely via `import` — must show it, by name, in that theorem's own
`#print axioms` report. This file is not a mathematical result, is not part of the
`round4-paper-graham-z29` campaign's proof target, and is not meant to be imported or cited
by anything else. Delete or ignore it once the isolation property has been confirmed.
-/

/-- Trivial corollary that only exists to *exercise* `base_sequenceable_upto_20`: it just
restates the axiom's conclusion for an arbitrary `S`. The point is not this theorem's content
(it is definitionally the axiom applied to its own hypotheses) — the point is what
`#print axioms` reports about it below. -/
theorem isolation_demo_sequenceable
    {G : Type*} [AddCommGroup G] (S : Finset G) (h0 : 0 ∉ S) (hcard : S.card ≤ 20) :
    Sequenceable S :=
  base_sequenceable_upto_20 S h0 hcard

#print axioms isolation_demo_sequenceable
