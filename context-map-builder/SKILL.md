---
name: context-map-builder
description: Generate CLAUDE.md context files that map a project for future Claude sessions. Use this skill whenever the user asks to "claude.md this project", "build" or "create CLAUDE.md", "map this project", or "generate context files", or explicitly calls this skill by name. Produces a root CLAUDE.md plus nested CLAUDE.md files that index proprietary scripts by location, purpose, and data inputs/outputs. Do NOT use this skill for writing READMEs, user-facing documentation, tutorials, changelogs, or any explanation of how code works internally — this skill deliberately excludes implementation detail and code examples.
---

Build `CLAUDE.md` context files that map a project so future Claude sessions orient fast.

## Philosophy

A context file is a **map and a statement of purpose**, not a wiki on how the sausage is made. It says *where* things are, *what* they are for, and *what data* moves in and out. It never explains how code is written and never contains code examples.

The output is for an agent, not a new hire. Cut every sentence that does not help locate something, state a purpose, or describe a data contract.

## When NOT to use

Do not use this skill for READMEs, onboarding docs, tutorials, API guides, changelogs, or any "how it works" explanation. Those describe mechanism; this skill deliberately omits mechanism. If the user wants those, this is the wrong tool.

## Files produced

All context files are named `CLAUDE.md`. Claude Code auto-loads them, merging a nested file with the root when work happens in that subtree.

- The `CLAUDE.md` at the project root is the **root context file**.
- A directory gets its own nested `CLAUDE.md` **only if it contains at least one proprietary script** (see test below).
- Two side files, referenced from the root `CLAUDE.md`: `TASKS.md` (task list) and `projectNotes.md` (preserved human notes, one per directory).

## Proprietary-script test

A file is a proprietary script only if **all three** hold:

1. It is repo-authored source on a non-vendored path. Exclude anything under `node_modules`, `.venv`, `site-packages`, `vendor`, `dist`, `build`, `.git`, or anything matched by `.gitignore`.
2. It is a script/module file type (`.py`, `.js`, `.ts`, `.r`, `.go`, `.rs`, etc.) — not config, data, lockfile, markdown, or asset.
3. It owns real logic the project authored — functions, classes, a pipeline — not a one-line shim or a generated/boilerplate file.

A directory with no proprietary script gets **no** `CLAUDE.md`; it is still listed and described in its parent's file.

## Workflow

1. **Walk the tree.** Enumerate every directory and file. Mark each directory as proprietary-script-bearing or not, using the test above.
2. **Read the code.** Read every proprietary script to extract its purpose and data contract. Reading code is required to build the map — but code never reaches the output files (see Hard rules).
3. **Preserve before replacing.** For every existing `CLAUDE.md`, move any content that does not fit the format below into that directory's `projectNotes.md` under a dated heading. Then discard the old `CLAUDE.md`.
4. **Write the root `CLAUDE.md`** per the root format.
5. **Write a nested `CLAUDE.md`** in each proprietary-script-bearing directory per the nested format.
6. **Write `TASKS.md`** if a task list exists or the user supplies one; otherwise create it empty with a header.
7. **Prune `projectNotes.md`.** In each directory, drop any note now fully covered by the new `CLAUDE.md`. `projectNotes.md` ends holding only orphaned human content.

## Root CLAUDE.md format

Use these sections in this order:

```markdown
# [Project name]

## Macro
[What the overall application does, end to end. Whole-application altitude — the
purpose and philosophy of the project, not its mechanical steps.]

## Project tree
[Full directory tree of the project. Every directory and proprietary script.]

## Root files
[Index entry per file in the project root. See File index entry rules.]

## Subdirectories
[One block per immediate subdirectory: purpose and boundary inputs/outputs.
Expand detail one level deep only. Note which subdirs have their own CLAUDE.md.]

## Conventions
- Write correctly-typed, efficient code.
- Prefer vectors and matrices over loops.
- Input/output sections describe data, never code.

## Recommended skills
[Skills already used in this project — see Recommended skills detection.]

## References
- Task list: TASKS.md
- Preserved human notes: projectNotes.md (per directory)
```

## Nested CLAUDE.md format

One per proprietary-script-bearing directory. Use these sections in this order:

```markdown
# [Directory name]

## Macro
[This directory's role within the project. Directory-scope altitude — what this
unit is for, not its mechanical steps.]

## Files
[Index entry per proprietary script in this directory. See File index entry rules.]

## Subdirectories
[Immediate next-level subdirectories only: purpose and boundary inputs/outputs.
Note which have their own CLAUDE.md.]
```

Nested files carry no conventions block, no skills list, no task list — those live in the root only and merge in automatically.

## File index entry rules

Each entry is 2-3 sentences. Frame inputs and outputs as **"what this needs to run / what it returns."** State data names, shapes, and types. State the error format. Never write argument order, call syntax, or code.

Determine I/O strictly from verifiable evidence: signatures, type hints, declared returns, file reads/writes, documented parameters. I/O that cannot be verified from the code is marked `UNVERIFIED` — never guessed.

**Example entry:**

```markdown
### engine.py
Engine that calculates the fair value of an index derivative.
Inputs: index constituents (list of tickers), price table (symbol-to-price map).
Output: a single fair-value float, or an error message in the format `ERR-XXX: <reason>`.
```

## Recommended skills detection

List skills the project already uses, so future chats keep using them. Source the list from:

- Skill names referenced inside existing `CLAUDE.md` files.
- Skills actually used in the chat session this skill runs in.

Each entry: skill name plus one line on why it applies. No evidence → state "no skill usage detected."

## Re-run behavior

`CLAUDE.md` files are replaced wholesale on every run. The safety net is the preserve-then-prune sequence in workflow steps 3 and 7:

- Before replacing a `CLAUDE.md`, anything in it not matching the formats above is cut and appended to that directory's `projectNotes.md` under a dated heading.
- After the new `CLAUDE.md` is written, any `projectNotes.md` content now covered by it is dropped.

`CLAUDE.md` is fully machine-owned. `projectNotes.md` is fully human-owned — this skill only moves text into it and prunes from it, never authors its content.

## Hard rules

- Never put code, code examples, or call syntax in any `CLAUDE.md`. Reading code to build the map is required; emitting code is forbidden.
- Never explain how code works internally. Describe location, purpose, and data contracts only.
- A directory gets a `CLAUDE.md` only if it passes the proprietary-script test.
- Macro sections stay at application/directory altitude — never a step-by-step of mechanical behavior.
- Unverifiable I/O is marked `UNVERIFIED`, never fabricated.
