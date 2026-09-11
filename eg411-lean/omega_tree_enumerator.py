"""
Complete solution-tree enumerator for 3*phi(n) = 2n+2, n squarefree, prime factors >= 5.
Theorems used for pruning (formalized in EG411Formal/SolutionStructure.lean):
  - solutions are odd, 3 does not divide n, squarefree  => factors are distinct primes >= 5
  - no-prime-chain: for primes r,s | n, r does not divide (s-1)
    => when extending prefix P by x: skip x with x = 1 (mod p) for any p in P.
Node math: A = 3*prod(p-1), B = 2*prod(p) over prefix P.
  Dead node: A <= B  (then 3*phi-product < 2*n-product forever).
  Intermediate cap (j >= 3 remaining, x = smallest remaining): dead when A*(x-1)^j > B*x^j + 2.
  Terminal (j = 2): t = (A*s - A + 2)/((A-B)*s - A); s-cap = (A + sqrt(K))/(A-B), K = A*B + 2*(A-B).
Emits the full kill-certified tree as JSON for the Lean forge.
"""
import sys, json, time
from sympy import isprime, primerange, integer_nthroot

W = int(sys.argv[1]) if len(sys.argv) > 1 else 7
OUT = sys.argv[2] if len(sys.argv) > 2 else f"omega{W}_tree.json"

t0 = time.time()
stats = {"terminals": 0, "branches": 0, "max_scan": 0, "pruned_chain": 0, "solutions": []}

def chain_ok(P, x):
    return all((x - 1) % p != 0 for p in P)

def solve(P, j, node):
    A = 3
    for p in P: A *= (p - 1)
    B = 2
    for p in P: B *= p
    node["P"] = list(P); node["A"] = A; node["B"] = B; node["j"] = j
    if A <= B:
        node["kill"] = "dead_AleB"
        return
    mx = P[-1] if P else 4
    if j == 2:
        c = A - B
        K = A * B + 2 * c
        r, _ = integer_nthroot(K, 2)
        s_hi = (A + r) // c + 2
        node["kill"] = "terminal"; node["K"] = K; node["s_hi"] = s_hi
        node["found"] = []
        stats["terminals"] += 1
        if stats["terminals"] % 1000 == 0:
            print(f"  ..terminal #{stats['terminals']} P={P}", file=sys.stderr, flush=True)
        def try_pair(s, t):
            if s >= t or s <= mx: return
            if not (isprime(s) and isprime(t)): return
            if not (chain_ok(P, s) and chain_ok(P, t) and (t - 1) % s != 0): return
            # verify the equation exactly
            if A * (s - 1) * (t - 1) == B * s * t + 2:
                node["found"].append([s, t])
                stats["solutions"].append(P + [s, t])
        if s_hi - mx <= 200000:
            # small range: direct scan (matches the Lean native_decide form)
            scan = 0
            for s in primerange(mx + 1, s_hi + 1):
                scan += 1
                den = c * s - A
                if den <= 0: continue
                num = A * s - A + 2
                if num % den: continue
                try_pair(s, num // den)
            stats["max_scan"] = max(stats["max_scan"], scan)
            node["scan"] = scan
        else:
            # divisor form: (c*s - A)(c*t - A) = K, both factors same sign.
            from sympy import divisors, factorint
            node["mode"] = "divisor"
            fac = factorint(K)
            node["K_factors"] = {str(k): v for k, v in fac.items()}
            divs = divisors(K)
            stats["max_scan"] = max(stats["max_scan"], len(divs))
            for u in divs:
                v = K // u
                # positive branch: s = (u+A)/c, t = (v+A)/c
                if (u + A) % c == 0 and (v + A) % c == 0:
                    try_pair((u + A) // c, (v + A) // c)
                # negative branch: s = (A-u)/c, t = (A-v)/c  (u = A - c*s > 0)
                if (A - u) % c == 0 and (A - v) % c == 0 and A > u and A > v:
                    s2, t2 = (A - v) // c, (A - u) // c
                    try_pair(s2, t2)
        return
    node["kill"] = "branch"; node["children"] = []
    for x in primerange(mx + 1, 10 ** 9):
        if A * (x - 1) ** j > B * x ** j + 2:
            node["cap"] = x
            break
        if not chain_ok(P, x):
            stats["pruned_chain"] += 1
            continue
        stats["branches"] += 1
        child = {}
        node["children"].append(child)
        solve(P + [x], j - 1, child)

root = {}
solve([], W, root)
elapsed = time.time() - t0
summary = {"omega": W, "elapsed_sec": round(elapsed, 1), **{k: v for k, v in stats.items()}}
with open(OUT, "w") as f:
    json.dump({"summary": summary, "tree": root}, f)
print(json.dumps(summary))
