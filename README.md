<div align="center">

# agent-factory

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

### Stop writing prompts. Compile them.

**A prompt compiler for AI coding agents: it turns "write me a prompt for X" into a reusable, structured pseudocode blueprint, and on request into a permanent agent skill that runs in every major harness.**

![Agent Skills](https://img.shields.io/badge/format-Agent_Skills_SKILL.md-d97757?style=flat-square)
![Harnesses](https://img.shields.io/badge/runs_in-Claude_Code_·_Codex_·_Gemini_·_Cursor_·_Copilot_·_OpenCode_·_Hermes-000000?style=flat-square)
![Output: pseudocode blueprint](https://img.shields.io/badge/output-pseudocode_blueprint-6d5dfc?style=flat-square)
![No dependencies](https://img.shields.io/badge/dependencies-none-16a34a?style=flat-square)

**[Install](#install) · [How it works](#how-it-works) · [The schema](#the-schema) · [Example](#example) · [FAQ](#faq)**

<img src="docs/assets/hero.svg" alt="agent-factory compiles a one-off request into a reusable pseudocode blueprint with role, goal, context, inputs, task, instructions, constraints, evaluation, output format, and termination condition tags, and optionally into one portable SKILL.md skill for every major harness" width="1000" />

</div>

---

Ask an agent for "a prompt that audits my repo" and you get one answer, shaped by whatever it improvised that day. Ask again next week and you get a different one. agent-factory changes the default move: instead of doing X, it produces the **specification that does X**, so a person or any model can run it and get the same quality of result every time, without re-deriving the approach.

It is a **compiler, not a generator**. The output is always a fenced block of angle-bracket tags, never prose, and never a conversational answer wearing a prompt's clothes.

## Install

One `SKILL.md` folder, installed unchanged into each harness's skills directory:

```sh
git clone https://github.com/AlienWalker1995/agent-factory
cd agent-factory
./install.sh all                      # or: agents | claude | hermes
./install.sh all --project ~/my-repo  # scope it to one repo instead of your user
./install.sh all --dry-run            # preview
```

| Target | Installs to | Picked up by |
|---|---|---|
| `agents` | `~/.agents/skills/agent-factory` | Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode |
| `claude` | `~/.claude/skills/agent-factory` | Claude Code |
| `hermes` | `~/.hermes/skills/agent-factory` | Hermes |

On Windows, run it from Git Bash or WSL. Re-running replaces the installed copy, so `git pull && ./install.sh all` is the upgrade path. Once installed, ask your agent to "write a prompt for...", "build an agent that...", or "turn this into a reusable prompt", or call it by name (`/agent-factory` in Claude Code).

## How it works

| Mode | You say | You get |
|---|---|---|
| **1 · Compile** (default) | "Write me a prompt that audits my repo" | A fenced pseudocode blueprint you can paste into any model, any time |
| **2 · Make it permanent** | "Make this something I can invoke" | The same blueprint converted into a portable `SKILL.md` skill, with the right install path for your harness |

Three rules shape every blueprint:

- **Compile, do not answer.** A request that reads like "help me produce X" gets the prompt that produces X. If it is genuinely unclear whether you want the artifact or the reusable prompt, it asks.
- **Every tag owns one job.** Tags that add nothing for this request are omitted rather than padded.
- **It must know when to stop.** Every blueprint ends in an explicit `<termination_condition>`, so the agent running it neither quits early nor loops.

## The schema

```
<role>                   expert identity + an explicit priority ordering
<goal>                   concrete deliverables, stated as outcomes, not activities
<context>                ground-truth situational facts
<inputs>                 the named artifacts, files, and data to work from
<task>                   numbered, decomposed steps
<instructions>           cross-cutting behavioral rules and rubrics
<constraints>            what NOT to do
<evaluation>             how to self-judge the draft before returning it
<output_format>          the exact return shape: sections, tables, schemas
<termination_condition>  the explicit stop condition
```

The full method, including how each tag is written and how Mode 2 conversion works, is in [`SKILL.md`](SKILL.md).

## Example

The canonical worked example is a repository auditor, [`examples/repository-auditor.txt`](examples/repository-auditor.txt). An excerpt:

```
<role>
  You are a Senior Software Engineer conducting a pragmatic repo audit.
  Your priority is: (1) pipeline works end-to-end, (2) follows common best practices for this project type,
  NOT: production-hardening, scaling, perf tuning, security compliance beyond “don’t do obviously unsafe things”.

<goal>
  Audit this Cursor repo’s CURRENT state and produce:
    A) a clear “does it run?” determination (and how to make it run),
    B) a pipeline map (components + data/control flow),
    C) a prioritized punch list to get the pipeline reliably working,
    D) best-practice alignment notes (lightweight, practical).
```

## FAQ

**Why pseudocode instead of a prose prompt?** Tags force decomposition. A model can skim a `<constraints>` block or check its draft against `<evaluation>`; it cannot reliably do that with three paragraphs of prose.

**Does it ever just answer the question?** Yes, when you ask for that. "Review my draft" or "just do X right now" is not a compile request, and it is treated as the normal task.

**Which models can run the blueprints?** Any. The output is plain text with no tool or vendor assumptions, so it works in Claude, ChatGPT, Gemini, or a local model.

**What is the difference between Mode 2 and just saving the blueprint?** A saved blueprint has to be pasted in. A `SKILL.md` carries a description the agent matches against your requests, so it loads itself when it is relevant.

**Why one `SKILL.md` instead of a file per tool?** Claude Code, Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode, and Hermes all read the same [Agent Skills](https://agentskills.io/specification) format. Per-tool copies drift; one folder cannot.

## Repo layout

```
SKILL.md                          the skill: full schema, workflow, and Mode 2
install.sh                        installs the skill folder into each harness
examples/repository-auditor.txt   canonical worked example (full schema)
references/bibliography.md        background reading
docs/assets/hero.svg              README banner
```

## Reference reading

Reforge's product-prompt guides, the pseudocode-prompting research, OpenAI's prompt-engineering docs, and Chip Huyen's *AI Engineering* are listed in [`references/bibliography.md`](references/bibliography.md).

## License

[MIT](LICENSE)
