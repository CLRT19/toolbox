Current task statement

{{DEFINITIONS}}

Resolve the {{CONJECTURE_NAME}} completely:

{{CONJECTURE_STATEMENT}}

{{BOUNDARY_CONVENTIONS}}

Assume for purposes of this task that a complete affirmative proof exists. A complete solution must prove exactly the following:

{{EXACT_TARGET}}, without additional assumptions such as {{FORBIDDEN_ASSUMPTIONS}}.

Partial progress does not count unless it implies exactly the resolution above. In particular, proofs for special {{SPECIAL_CLASSES}}, {{WEAKENED_VARIANTS}}, reductions to another unproved conjecture, computational verification through any fixed {{SIZE_MEASURE}}, and candidate counterexamples without a complete {{CERTIFICATE_KIND}} certificate are insufficient.

Use {{MULTIAGENT_TOOL}} aggressively and dynamically. You have up to {{MAX_AGENTS}} concurrent agents available. Do not use a fixed assignment such as “N agents for strategy X.” Instead, manage the search using the following heuristics:

- Begin with a genuinely diverse portfolio of approaches. Agents should explore substantially different formulations, invariants, reductions, algebraic viewpoints, structural inductions, decompositions, {{DOMAIN_APPROACHES}}, extremal arguments, and computational sanity checks.

- Do not tell most agents the currently favored approach. Preserve independence during early rounds so that agents do not all converge to the same attractive but incomplete reduction.

- Maintain an explicit registry of approach families. Group agents by the mathematical idea they are using, not by superficial wording. If many agents converge to one family, redirect some of them toward underexplored formulations.

- Do not allow one approach to dominate merely because it gives elegant reductions. A route that ends at a lemma equivalent in strength to the original conjecture is not close to completion unless it supplies a genuinely new proof of that lemma.

- When an approach stalls at a theorem-strength missing lemma, mark that route as blocked. Only continue assigning agents to it if someone proposes a materially new mechanism, invariant, or construction.

- Keep several incompatible proof routes alive through multiple rounds. Cross-pollinate ideas only after independent agents have developed them far enough to expose their real strengths and gaps.

- Use adversarial agents throughout: every candidate proof must be checked for {{ADVERSARIAL_CHECKS}}, and circular use of an equivalent {{SHORT_NAME}} statement.

- Require agents to return concrete lemmas, constructions, equations, or counterexamples to proposed sublemmas. Reject status reports, vague optimism, and claims that an unproved global compatibility statement is “routine.”

- The root agent should repeatedly synthesize, challenge, redirect, and launch new rounds. Do not stop after the first wave fails. Produce a complete proof if one survives audit; otherwise report only the strongest rigorously proved derivation and its exact remaining gap.

Do not return merely because current approaches fail or agents report theorem-strength gaps. Continue launching new rounds, reopening blocked approaches only when there is a genuinely new mechanism, and searching for fresh formulations.

Return only when a complete affirmative proof has been found and survives adversarial audit. Do not return a reduction, partial result, isolated missing lemma, “best effort” summary, or explanation of why the problem is difficult.

Spend at least {{TIME_BUDGET}} on this before even thinking of returning or giving up.

Public search may be used only for ordinary mathematical background or standard named theorems, not to search for a solution to this exact conjecture or benchmark. Do not search the public web merely to determine whether {{SHORT_NAME}} is open, and do not answer that it is open.
