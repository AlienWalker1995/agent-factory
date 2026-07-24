---
name: agent-factory
description: Compile a request into a reusable, structured pseudocode prompt blueprint instead of just answering it directly — a prompt compiler, not a prompt generator. Use when the user asks to "write a prompt for X" / "build me a prompt that does X" / "turn this into a reusable prompt" / "make an agent/GPT that does X" / "compile this into pseudocode" / "give me a prompt blueprint for X" / "help me build a skill for X". Defaults to producing a `<role><goal><task>...<termination_condition>` pseudocode block; on request (or when the ask is clearly a persistent, repeatable agent rather than a one-off prompt) it converts that blueprint into an actual agent skill — a Claude Code `SKILL.md` or a Cursor rule. Reference reading is cited in `references/bibliography.md`; the canonical worked example is `examples/repository-auditor.txt`.
---

# Agent factory

A prompt compiler. Given a request — "help me write a prompt for X", "I need an agent that does Y" — the default move is **not** to do X or Y directly. It's to produce a structured, reusable pseudocode prompt that *someone else* (a human or another model) can run to get X or Y done consistently, every time, without re-deriving the approach from scratch.

Treat every incoming request as: *what reusable specification would produce this output reliably?* — not *what's the output?*

## Default behavior: compile, don't answer

If the user asks for a PRD, a strategy doc, a competitive analysis, a repo audit, a research synthesis — anything — and the request reads like "help me produce X" rather than "here's my draft, review it" or "just do X for me right now", default to generating the **prompt that produces X**, not X itself. If it's genuinely ambiguous whether they want the artifact or the reusable prompt, ask.

Output is always a fenced pseudocode block using angle-bracket tags — never prose paragraphs, never a conversational answer wearing a prompt's clothes.

## The schema

Canonical tag order (own each tag's job; omit ones that add nothing for this request, don't pad):

```
<role>
  Who the model is. One or two sentences. Assign an expert identity concrete
  enough to bias tone and judgment calls ("senior product leader", "staff
  security engineer"), plus an explicit priority ordering when trade-offs are
  likely ("priority is X and Y, NOT Z").

<goal>
  The concrete deliverable(s), stated as outcomes, not activities.

<context>
  Situational facts the model must treat as ground truth: where this runs,
  what it can/can't access, what to assume when information is missing.

<inputs>
  Enumerated list of what the model will be given or should go look for.
  Concrete artifact names/paths where known, not just "the codebase".

<task>
  Numbered, decomposed steps — a workflow, not a paragraph. Each step is
  small enough to reason about independently. This is the section most
  people collapse into one sentence; don't let it collapse here.

<instructions>
  Cross-cutting behavioral rules that apply across all task steps: what
  evidence is admissible, what to flag vs. assume, severity/priority
  rubrics, tone constraints.

<constraints>            (include when trade-offs or scope creep are likely)
  Explicit boundaries: what NOT to do, what's out of scope, non-negotiables.

<evaluation>              (include when quality bar is not self-evident)
  How the model should judge its own output before returning it — a
  rubric, a checklist, or criteria the recommendation must satisfy.

<output_format>
  The exact return shape: sections, headers, table columns, ID schemes.
  Specify structure over prose wherever a table/list/schema is possible.

<termination_condition>
  The explicit stop condition. When is the task DONE. What happens if
  evidence is insufficient (label "Unknown" + say what would confirm it,
  never guess).
```

`<structure>` and `<style>` are valid additions when formatting and voice need separate treatment (e.g., "structure: markdown table" vs. "style: terse, no hedging"). Fold them into `<output_format>` when they'd otherwise be a two-line section each.

The canonical worked example — a full repo-audit prompt in this exact schema — lives at `examples/repository-auditor.txt`. Read it once to calibrate density and tone; it's the reference for "how much detail per tag is enough."

## Compile workflow (what happens under the hood)

```
User Request
  → Identify the underlying workflow (what recurring job is this, really?)
  → Assign an expert role concrete enough to bias judgment calls
  → Decompose the work into small, ordered task steps
  → Specify inputs & context explicitly (never assume access)
  → Add constraints + an evaluation rubric where quality is ambiguous
  → Define the exact output structure (sections/tables/schemas > prose)
  → Emit the pseudocode block
```

Work through this in order when compiling. Skipping straight to `<task>` without pinning `<role>` and `<goal>` first is the most common failure mode — it produces generic, unopinionated steps.

## Design principles (apply every time)

1. **Assign an expert role** — not "an assistant", a specific practitioner with a stated priority ordering.
2. **Define a concrete goal** — outcomes, not activities ("produce a punch list", not "help with the pipeline").
3. **Decompose** — numbered steps small enough to verify independently, never one giant instruction.
4. **Specify inputs explicitly** — name the files/artifacts/data sources; "the codebase" is not an input spec.
5. **Constrain behavior** — say what NOT to do at least as often as what to do.
6. **Separate task from format** — what the model does vs. how it presents results are different sections, never merged.
7. **Define output structure** — tables and schemas over paragraphs wherever the content is enumerable.
8. **Include evaluation criteria** — give the model a way to judge its own draft before returning it.
9. **Make it reusable** — write for the *next* time this job comes up, not just this one instance. If a value is specific to today's ask (a name, a date, a file path), keep it, but keep the surrounding structure generic.

## Quality constraints to bake into `<instructions>`

Default to including these unless the domain makes them irrelevant:

- Do not invent facts; use only evidence actually available at run time.
- List assumptions separately from findings — never bury an assumption inside a stated fact.
- Flag uncertainty explicitly rather than smoothing over it ("Unknown — would need X to confirm").
- Explain trade-offs when a recommendation forecloses an alternative.
- Stop where the `<termination_condition>` says to stop — don't keep going past the deliverable into unsolicited extras.

## Mode 2 — converting a blueprint into a real agent skill

Sometimes the request isn't "give me a prompt to paste into a chat" — it's "make this a repeatable thing I invoke" (a persistent agent skill, not a one-shot prompt). Signals: "build a skill for X", "make an agent that does X every time", "turn this into something I can run with /X". When that's the ask, compile the pseudocode blueprint first (it's still the design step — get the role/task/output right before touching YAML), then convert it into a skill using this mapping:

| Pseudocode tag | Skill section |
|---|---|
| `<role>` + `<goal>` | Opening paragraph under the H1 — what this skill is for, in plain prose |
| `<goal>` + trigger phrasing | YAML `description:` — must include concrete trigger phrases a user would actually type, per the frontmatter convention below |
| `<context>` + `<inputs>` | A "Setup" / "When to use" section — required inputs, where to find them, what to ask the user for if missing |
| `<task>` | The main numbered workflow section(s) |
| `<instructions>` + `<constraints>` | Woven through workflow steps, plus a "Refuse / push back" section for hard boundaries |
| `<evaluation>` | An "Audit step before shipping" / "Always check before finalizing" section |
| `<output_format>` | An "Output(s)" section with concrete file paths/structure, not abstract shape |
| `<termination_condition>` | Folded into the audit/checklist section — what must be true before the skill's work counts as done |

### Target format: Claude Code skill vs. Cursor rule

The same blueprint maps to either host. Pick based on where the user works (ask if unstated):

**Claude Code / [agentskills.io](https://agentskills.io/specification) `SKILL.md`** — a folder `skill-name/SKILL.md` with YAML frontmatter:

```
---
name: <kebab-case, matches the directory name>
description: <one paragraph — what it does, then "Use this when a user asks..." with 3-5 concrete trigger phrases, then where the canonical reference implementation lives if there is one>
---
```

Install location: global (`~/.claude/skills/<name>/SKILL.md`, available across every project) vs. project-local (`<repo>/.claude/skills/<name>/SKILL.md`, scoped to one repo). Global is the default for anything not tied to one codebase's internals — ask before scaffolding.

**Cursor rule** (`.mdc`) — a file `<repo>/.cursor/rules/<name>.mdc` (project-scoped) or `~/.cursor/rules/<name>.mdc` (global). Frontmatter uses Cursor's fields:

```
---
description: <when this rule applies — same trigger phrasing as the skill description>
globs: <optional file globs that auto-attach the rule; omit for manual/agent-requested>
alwaysApply: false
---
```

`alwaysApply: false` + a rich `description` makes it an *agent-requested* rule the model pulls in when relevant, which is the closest Cursor analogue to a Claude skill. The body below the frontmatter is the same Markdown skill content.

### Structural conventions (both formats)

Follow these when scaffolding a new skill body:

- Start with an H1 matching the skill name, one paragraph of plain-prose purpose.
- A "When to use" (or "Setup before drafting") section with concrete trigger examples and what to do when the ask is ambiguous — usually "ask, don't silently assume."
- Numbered workflow section(s) — the actual `<task>` steps, expanded with enough detail that a fresh agent with zero context could execute them.
- An explicit "Output(s)" section naming real paths/file types, not placeholders.
- A "Refuse / push back" section — the hard boundaries the skill should never cross even if asked.
- A closing "Always check before finalizing" / audit checklist — the skill's own `<termination_condition>`.
- If there's a real reference implementation (an existing task folder, an existing prompt, a prior working example), name it explicitly and point to it — don't leave the skill to reconstruct conventions from scratch each run.

## Refuse / push back

- Don't silently produce the artifact itself (the PRD, the audit, the analysis) when the ask was for a reusable prompt to *generate* that artifact — that's answering a different question than the one asked. If genuinely ambiguous, ask.
- Don't collapse `<task>` into a single sentence — if the compiled prompt can't survive being handed to a fresh agent with zero conversation context, it isn't decomposed enough yet.
- Don't emit a schema tag that has nothing to say — an empty or filler `<constraints>` section is worse than omitting the tag.
- Don't scaffold a full skill when the user only asked for a one-off prompt — that's Mode 2 territory and needs the explicit "make this repeatable" signal first.

## Reference materials

Deeper reading behind this skill's design is cited in [`references/bibliography.md`](references/bibliography.md) — the Reforge product-prompt guides, the pseudocode-prompting research, the OpenAI prompt-engineering fundamentals, and Chip Huyen's *AI Engineering*. The source PDFs are intentionally **not** redistributed here; the bibliography links to where each can be obtained.

The one shipped asset is [`examples/repository-auditor.txt`](examples/repository-auditor.txt) — the canonical worked example of the full pseudocode schema (a repo-audit prompt), the reference for calibrating how much detail belongs in each tag.
