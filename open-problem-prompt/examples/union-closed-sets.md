Current task statement

A family here is a finite collection F of distinct finite sets. The universe U(F) is the union of all members of F. F is union-closed if A ∪ B ∈ F for all A, B ∈ F. The frequency of an element x in F is the number of members of F that contain x. The empty set may or may not belong to F; when it does, it counts as one member of F.

Resolve the Union-Closed Sets Conjecture (UCSC, Frankl's conjecture) completely:

Every finite union-closed family of sets that contains a nonempty set has an element belonging to at least half of the sets in the family.

The empty family and the family {∅} are excluded; every other finite union-closed family is in scope, whether or not it contains ∅. “At least half” means frequency at least |F|/2, where |F| counts ∅ when ∅ ∈ F. The witnessing element must lie in U(F), and its frequency is computed in F itself, not in any derived family.

Assume for purposes of this task that a complete affirmative proof exists. A complete solution must prove exactly the following:

Every finite union-closed family F containing at least one nonempty set has an element x ∈ U(F) whose frequency in F is at least |F|/2, without additional assumptions such as a bound on |U(F)| or |F|, the presence or absence of ∅, F being large relative to 2^|U(F)|, F containing a small set, or lattice-theoretic regularity of F such as distributivity or semimodularity.

Partial progress does not count unless it implies exactly the resolution above. In particular, proofs for special family or lattice classes, bounds of the form c|F| for any constant c < 1/2, asymptotic or “sufficiently large” versions, bounds that hold only up to lower-order error terms, weighted or fractional variants that do not specialize to the unweighted 1/2 bound, reductions to another unproved conjecture, computational verification through any fixed universe size or family size, and candidate counterexamples without a complete verification certificate are insufficient.

Use subagents aggressively and dynamically. You have up to 64 concurrent agents available. Do not use a fixed assignment such as “N agents for strategy X.” Instead, manage the search using the following heuristics:

- Begin with a genuinely diverse portfolio of approaches. Agents should explore substantially different formulations, invariants, reductions, algebraic viewpoints, structural inductions, decompositions, entropy and information-theoretic couplings, weighting and averaging schemes, lattice-theoretic formulations, linear-programming duality, compression and shifting, Fourier analysis on the hypercube, extremal arguments, and computational sanity checks.

- Do not tell most agents the currently favored approach. Preserve independence during early rounds so that agents do not all converge to the same attractive but incomplete reduction.

- Maintain an explicit registry of approach families. Group agents by the mathematical idea they are using, not by superficial wording. If many agents converge to one family, redirect some of them toward underexplored formulations.

- Do not allow one approach to dominate merely because it gives elegant reductions. A route that ends at a lemma equivalent in strength to the original conjecture is not close to completion unless it supplies a genuinely new proof of that lemma.

- When an approach stalls at a theorem-strength missing lemma, mark that route as blocked. Only continue assigning agents to it if someone proposes a materially new mechanism, invariant, or construction.

- Keep several incompatible proof routes alive through multiple rounds. Cross-pollinate ideas only after independent agents have developed them far enough to expose their real strengths and gaps.

- Use adversarial agents throughout: every candidate proof must be checked for the exact 1/2 threshold with no ε or asymptotic loss, ≥ versus > and whether ∅ is counted in |F|, frequencies measured in a derived family instead of F, the family {∅} and families with a single nonempty set, distinctness of members or union-closure destroyed by reductions such as deleting or identifying elements or passing to a subfamily, and circular use of an equivalent UCSC statement.

- Require agents to return concrete lemmas, constructions, equations, or counterexamples to proposed sublemmas. Reject status reports, vague optimism, and claims that an unproved global compatibility statement is “routine.”

- The root agent should repeatedly synthesize, challenge, redirect, and launch new rounds. Do not stop after the first wave fails. Produce a complete proof if one survives audit; otherwise report only the strongest rigorously proved derivation and its exact remaining gap.

Do not return merely because current approaches fail or agents report theorem-strength gaps. Continue launching new rounds, reopening blocked approaches only when there is a genuinely new mechanism, and searching for fresh formulations.

Return only when a complete affirmative proof has been found and survives adversarial audit. Do not return a reduction, partial result, isolated missing lemma, “best effort” summary, or explanation of why the problem is difficult.

Spend at least 8 hours on this before even thinking of returning or giving up.

Public search may be used only for ordinary mathematical background or standard named theorems, not to search for a solution to this exact conjecture or benchmark. Do not search the public web merely to determine whether UCSC is open, and do not answer that it is open.
