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

Add this to your cloud environment's **Setup script** field (Settings →
environment → Setup script). It runs in every session on that environment, so
every repo gets all skills with no per-repo work. Confirmed: cloud Claude Code
loads skills from `~/.claude/skills` at session start.

```bash
#!/bin/bash
SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/.claude/skills-src"

mkdir -p "$SKILLS_DIR"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
else
  git clone --depth 1 https://github.com/Jonatan-Gani/Skills "$REPO_DIR" 2>/dev/null || true
fi

# Copy every skill folder (one that contains a SKILL.md) into ~/.claude/skills.
for d in "$REPO_DIR"/*/; do
  [ -f "${d}SKILL.md" ] && cp -rf "$d" "$SKILLS_DIR/"
done
```

> **Why not clone straight onto `~/.claude/skills`?** The cloud VM ships that
> folder pre-populated (e.g. the bundled `session-start-hook` skill), so a direct
> `git clone … ~/.claude/skills` fails with *"destination path already exists and
> is not an empty directory"* and silently installs nothing. Cloning to a side
> location and copying each skill folder in avoids the collision and preserves
> any pre-installed skills.

If the repo is **private**, add a `GH_TOKEN` environment variable to the
environment and swap the clone line for:

```bash
git clone --depth 1 https://x-access-token:${GH_TOKEN}@github.com/Jonatan-Gani/Skills "$REPO_DIR"
```

## Fallback: per-project submodule

If you prefer per-project vendoring, the alternative path is to
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
| [`thermo-nuclear-code-quality-review`](thermo-nuclear-code-quality-review/SKILL.md) | `/thermo-nuclear-code-quality-review` (manual only) | Extremely strict maintainability review — hunts giant files, spaghetti conditionals, and "code-judo" simplifications. From [cursor/plugins](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review). |
