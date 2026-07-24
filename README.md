# agent-factory

A **prompt compiler** for AI coding agents — not a prompt generator.

Given a request like *"write me a prompt for X"* or *"build an agent that does Y"*, `agent-factory` doesn't do X or Y. It compiles the request into a **reusable, structured pseudocode blueprint** — a `<role><goal><task>…<termination_condition>` specification that a human or another model can run to get X or Y done consistently, every time, without re-deriving the approach from scratch.

Works as both a **Claude Code skill** and a **Cursor rule**.

## What it produces

A fenced pseudocode block using angle-bracket tags:

```
<role>            expert identity + priority ordering
<goal>            concrete deliverables as outcomes, not activities
<context>         ground-truth situational facts
<inputs>          named artifacts/files/data
<task>            numbered, decomposed steps
<instructions>    cross-cutting behavioral rules + rubrics
<constraints>     what NOT to do
<evaluation>      how to self-judge the draft
<output_format>   exact return shape (sections/tables/schemas)
<termination_condition>  explicit stop condition
```

**Mode 2:** on request ("make this a repeatable thing I can invoke"), it converts that blueprint into an actual agent skill — a Claude Code `SKILL.md` or a Cursor `.mdc` rule.

See [`SKILL.md`](SKILL.md) for the full method, and [`examples/repository-auditor.txt`](examples/repository-auditor.txt) for a complete worked example.

## Install

### Claude Code

Global (available in every project):

```bash
git clone https://github.com/AlienWalker1995/agent-factory.git
mkdir -p ~/.claude/skills
cp -r agent-factory ~/.claude/skills/agent-factory
```

Or project-local: copy into `<your-repo>/.claude/skills/agent-factory/`. Then invoke it by asking Claude to "write a prompt for…" / "build a skill for…", or reference it by name.

### Cursor

The repo ships a ready-to-use rule at [`.cursor/rules/agent-factory.mdc`](.cursor/rules/agent-factory.mdc).

- **Project-scoped:** copy `.cursor/rules/agent-factory.mdc` into your project's `.cursor/rules/` folder (and `SKILL.md` + `examples/` alongside so the relative links resolve).
- **Global:** copy it into `~/.cursor/rules/`.

It's an *agent-requested* rule (`alwaysApply: false` + a rich description), so Cursor pulls it in when your request matches — e.g. "compile this into a reusable prompt".

## Repository layout

```
agent-factory/
├── SKILL.md                        # the skill — full schema, workflow, Mode 2
├── README.md                       # this file
├── examples/
│   └── repository-auditor.txt      # canonical worked example (full schema)
├── references/
│   └── bibliography.md             # background reading
└── .cursor/
    └── rules/
        └── agent-factory.mdc       # Cursor rule mirror of the skill
```

## Reference materials

Background reading — Reforge's product-prompt guides, the pseudocode-prompting research, OpenAI's prompt-engineering docs, and Chip Huyen's *AI Engineering* — is listed in [`references/bibliography.md`](references/bibliography.md).

## License

[MIT](LICENSE).
