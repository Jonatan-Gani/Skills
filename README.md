# skills

A single source of truth for my [Claude Code skills](https://code.claude.com/docs).

Each skill lives in its own directory at the repo root, containing a `SKILL.md`
(plus any scripts or assets that skill ships with). The **folder name must match
the skill `name` in the frontmatter**.

```
skills/
  context-map-builder/
    SKILL.md
  humanizer/
    SKILL.md
  cover-letter/
    SKILL.md
```

## Use in the cloud (recommended)

The repo root *is* the skills directory, so clone it straight into
`~/.claude/skills`. Add this to your cloud environment's setup script:

```bash
#!/bin/bash
SKILLS_DIR="$HOME/.claude/skills"
if [ -d "$SKILLS_DIR/.git" ]; then
  git -C "$SKILLS_DIR" pull --ff-only || true
else
  git clone https://github.com/Jonatan-Gani/Skills "$SKILLS_DIR" 2>/dev/null || true
fi
```

If the repo is **private**, add a `GH_TOKEN` environment variable to the
environment and clone with it instead:

```bash
git clone https://x-access-token:${GH_TOKEN}@github.com/Jonatan-Gani/Skills "$SKILLS_DIR"
```

> **Caveat:** whether cloud Claude Code reads `~/.claude/skills` is undocumented.
> Test once — enable a session and type a trigger phrase for one of the skills.
> If it loads, every repo using that environment gets all skills with no
> per-repo work.

## Fallback: per-project submodule

If the `~/.claude/skills` test fails, the guaranteed-but-tedious path is to
vendor the skills into each project at `.claude/skills/` as a submodule pointing
at this same repo (so there's still one source of truth):

```bash
git submodule add https://github.com/Jonatan-Gani/Skills .claude/skills
```

## Adding a skill

1. Create a directory named exactly after the skill's frontmatter `name`.
2. Add a `SKILL.md` with valid frontmatter (`name`, `description`).
3. Drop any supporting scripts/assets in the same directory.
4. Commit and push.

## Skills

<!-- Keep this list in sync as skills are added. -->

| Skill | Invoke | What it does |
|---|---|---|
| [`context-map-builder`](context-map-builder/SKILL.md) | `/context-map-builder` or auto | Generates `CLAUDE.md` context-map files (root + nested) that index a project's proprietary scripts by location, purpose, and data I/O. |
