# Open-Problem Orchestrator Prompt

A reusable prompt for having a multi-agent model attack an open conjecture. It is a templated version of the prompt OpenAI published for GPT 5.6 Sol Ultra's proof of the Cycle Double Cover Conjecture:

> Source: <https://cdn.openai.com/pdf/04d1d1e4-bc75-476a-97cf-49055cd98d31/cdc_prompt.pdf>

Only the problem-specific phrases were turned into `{{SLOTS}}`. Every other sentence is the original, word for word. Filling the slots with the CDC values reproduces the published prompt exactly (696/696 words), so nothing from the original was dropped.

## Files

| File | What it is |
|------|------------|
| [prompt-template.md](prompt-template.md) | The generic prompt with `{{SLOTS}}`. Copy, fill, paste. |
| [examples/cycle-double-cover.md](examples/cycle-double-cover.md) | The template filled with the original CDC values (identical to the PDF) |
| [examples/union-closed-sets.md](examples/union-closed-sets.md) | The template filled for Frankl's union-closed sets conjecture, to show it carries over to another field |

## What the prompt does

These are the techniques in the original, and none of them depend on CDC:

1. **The target has no loopholes.** Exact definitions, explicit handling of degenerate cases, and a precise target that rules out extra hypotheses.
2. **Partial results don't count.** Special cases, weakened variants, reductions to other open problems, finite computation and unproven counterexamples are all named and rejected.
3. **A proof is assumed to exist.** This keeps the model from concluding that the problem is too hard.
4. **The search is managed dynamically.** There are no fixed "N agents per strategy" assignments. The root agent keeps re-planning between rounds.
5. **Agents work independently at first.** Most agents aren't told which approach is currently favored, and ideas are only shared once each route has shown its real gaps.
6. **The root keeps a registry of approach families.** Agents are grouped by the mathematical idea they use, and crowded families are thinned out.
7. **Routes that hit a theorem-strength gap are blocked.** A reduction to a lemma as hard as the conjecture doesn't count as progress.
8. **Adversarial checking runs throughout.** Every candidate proof is checked against a list of failure modes specific to the problem, including circular use of the conjecture itself.
9. **Agents must return concrete output.** Lemmas, constructions, equations or counterexamples, never status reports or claims that a step is "routine".
10. **Clear rules for when to stop.** There's a minimum time budget, the model may return only after a proof survives audit, and it may not search the web for the answer or for whether the problem is open.

## Filling the slots

| Slot | What goes there | Original (CDC) value |
|------|-----------------|----------------------|
| `DEFINITIONS` | Every term in the statement, with each degenerate object explicitly included or excluded | multigraph, bridge, cycle, cycle double cover, with parallel edges distinct and 2-cycles allowed |
| `CONJECTURE_NAME` | Full name (add `(ABBR)` if you use one for `SHORT_NAME`) | `Cycle Double Cover Conjecture` |
| `CONJECTURE_STATEMENT` | The statement in one sentence | `Every finite bridgeless loopless multigraph has a cycle double cover.` |
| `BOUNDARY_CONVENTIONS` | Trivial or empty cases, and clarifications of what is and isn't required | disconnected graphs allowed, edgeless graph has the empty cover, cycles need not be disjoint |
| `EXACT_TARGET` | The statement to prove, restated precisely (no trailing period) | `Every finite loopless multigraph with no bridge possesses a cycle double cover` |
| `FORBIDDEN_ASSUMPTIONS` | Extra hypotheses that would make it easier | `cubicity, planarity, connectivity, or higher edge-connectivity` |
| `SPECIAL_CLASSES` | Completes "proofs for special ___" | `graph classes` |
| `WEAKENED_VARIANTS` | Known relaxations and near-miss versions of the conjecture | `constructions of cycle covers with some edges covered other than twice, bounded-length or prescribed-cycle variants` |
| `SIZE_MEASURE` | Completes "computational verification through any fixed ___" | `graph size` |
| `CERTIFICATE_KIND` | Completes "without a complete ___ certificate" | `nonexistence` |
| `MULTIAGENT_TOOL` | Whatever your harness calls its multi-agent feature | `multiagent v2` |
| `MAX_AGENTS` | Concurrency limit | `64` |
| `DOMAIN_APPROACHES` | 3–6 approach families specific to the field. The generic ones (formulations, invariants, inductions, extremal arguments, and so on) are already in the template | `flow formulations, transition systems, embeddings` |
| `ADVERSARIAL_CHECKS` | Failure modes specific to the problem (see below). Circularity is already in the template | `exact-two multiplicity, repeated-edge closed trails masquerading as cycles, parallel-edge 2-cycles, disconnected graphs, cutvertices, bridges introduced by reductions` |
| `SHORT_NAME` | Short name used in "equivalent ___ statement" and "whether ___ is open" | `CDC` |
| `TIME_BUDGET` | Minimum effort before giving up | `8 hours` |

### Writing `ADVERSARIAL_CHECKS`

This slot matters most. The CDC checklist is built from six categories. Answer each one for your problem:

| Category | Question to ask | CDC instance |
|----------|-----------------|--------------|
| Exact quantitative requirement | What number, bound or multiplicity must hold *exactly*? | exact-two multiplicity |
| Look-alike objects | What resembles the required object but isn't one? | repeated-edge closed trails masquerading as cycles |
| Degenerate objects | Which edge-case objects do the definitions allow? | parallel-edge 2-cycles |
| Boundary instances | Which inputs sit at the edge of the hypotheses? | disconnected graphs, cutvertices |
| Hypotheses broken by reductions | Which hypothesis can a reduction or induction step silently destroy? | bridges introduced by reductions |
| Circularity | Which equivalent forms might be assumed without noticing? | equivalent CDC statement *(already in the template)* |

For the union-closed example, the same categories give: the exact 1/2 threshold, frequencies measured in a derived family, the family {∅}, families with one nonempty set, and union-closure or distinctness lost when deleting elements or passing to a subfamily.

## Disproving instead of proving

The template keeps the original's affirmative framing. Telling the model that a proof exists is deliberate, because it stops the model from hedging. If you believe the conjecture is false, or don't know which way it goes, swap these sentences:

**Disprove**

- Replace *"Assume for purposes of this task that a complete affirmative proof exists. A complete solution must prove exactly the following:"* with:
  `Assume for purposes of this task that a counterexample exists. A complete solution must exhibit an explicit counterexample, with a complete independently checkable certificate, to exactly the following:`
- In the "Partial progress" paragraph, after "In particular,", use:
  `near-misses, counterexamples to strengthened or modified versions, numerical or heuristic evidence, and candidates whose certificate is incomplete are insufficient. The counterexample must satisfy every hypothesis exactly as defined above.`
- Replace "every candidate proof must be checked for" with "every candidate counterexample must be checked for".
- Replace "Produce a complete proof if one survives audit" with "Produce a complete certified counterexample if one survives audit".
- Replace the return line with:
  `Return only when an explicit counterexample with a complete certificate has been found and survives adversarial audit.`

**Direction unknown**

- Replace the "Assume…" sentence with:
  `Assume for purposes of this task that the statement below can be settled rigorously in one direction or the other. A complete solution must either prove exactly the following, or exhibit an explicit counterexample to it with a complete independently checkable certificate:`
- After the registry bullet, add:
  `Treat proof and disproof as separate approach families in the registry, and do not let either direction absorb all agents.`
- Replace the return line with:
  `Return only when a complete proof or a fully certified counterexample has been found and survives adversarial audit.`

## Running it

- **`MULTIAGENT_TOOL`**: `multiagent v2` is the original wording from OpenAI's harness. Elsewhere, name your harness's own multi-agent feature so the model knows to use it.
- **Claude Code**: use `a workflow (multi-agent orchestration)`. The Workflow tool needs your explicit opt-in, and this prompt's own wording gives it. Workflows default to a "medium" size guideline of about 10 agents. To allow 64, raise **Dynamic workflow size** in `/config`.
- **Time budget**: the model can only keep going as long as the session does, so pick a value your setup can actually sustain.
