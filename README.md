# skills

A single source of truth for my [Claude Code skills](https://code.claude.com/docs).

Each skill lives in its own directory containing a `SKILL.md` (plus any scripts
or assets that skill ships with). The **folder name must match the skill `name`
in the frontmatter**.

## Organization (category folders)

Skills are grouped into **category folders** purely for human organization. The
categories are **dynamic** — add, rename, or nest them however you like; nothing
else needs to change (see how loading works below).

```
skills/
  programming/
    context-map-builder/
      SKILL.md
    thermo-nuclear-code-quality-review/
      SKILL.md
    grill-me/
      SKILL.md
  writing/
    ...
  finance/
    ...
  meta/
    add-skill/
      SKILL.md
    handoff/
      SKILL.md
```

> **Important:** Claude Code does **not** discover skills nested under category
> folders — it only loads a skill from a directory placed *directly* under
> `~/.claude/skills/`. The setup script below bridges this by **flattening**: it
> finds every `SKILL.md` at any depth and copies its folder into
> `~/.claude/skills/`. That's what makes categories free-form. The only rule:
> **skill folder names must be unique across categories** (they all flatten into
> one directory).

## Use in the cloud (recommended)

Add this to your cloud environment's **Setup script** field (Settings →
environment → Setup script). It runs in every session on that environment, so
every repo gets all skills with no per-repo work. Confirmed: cloud Claude Code
loads skills from `~/.claude/skills` at session start.

```bash
#!/bin/bash
set +e
SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/.claude/skills-src"

mkdir -p "$SKILLS_DIR"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
else
  rm -rf "$REPO_DIR"
  git clone --depth 1 https://github.com/Jonatan-Gani/Skills "$REPO_DIR" 2>/dev/null || true
fi

# Flatten: copy every skill folder (any dir containing a SKILL.md, at any depth)
# into ~/.claude/skills/. This is what makes the category folders dynamic.
if [ -d "$REPO_DIR" ]; then
  find "$REPO_DIR" -name SKILL.md -not -path '*/.git/*' -print0 2>/dev/null \
    | while IFS= read -r -d '' skillmd; do
        cp -rf "$(dirname "$skillmd")" "$SKILLS_DIR/" 2>/dev/null || true
      done
fi

exit 0
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

1. Pick (or create) a category folder, e.g. `programming/`, `writing/`, `meta/`.
2. Inside it, create a directory named exactly after the skill's frontmatter
   `name` — and keep that name unique across all categories.
3. Add a `SKILL.md` with valid frontmatter (`name`, `description`) at the very top.
4. Drop any supporting scripts/assets in the same skill directory.
5. Add a row to the Skills table below (Category + Author/Source).
6. Commit and push.

The [`add-skill`](meta/add-skill/SKILL.md) skill automates this whole flow.

## Skills

<!-- Keep this list in sync as skills are added. -->

| Category | Skill | Invoke | What it does | Author / Source |
|---|---|---|---|---|
| programming | [`context-map-builder`](programming/context-map-builder/SKILL.md) | `/context-map-builder` or auto | Generates `CLAUDE.md` context-map files (root + nested) that index a project's proprietary scripts by location, purpose, and data I/O. | [Jonatan-Gani](https://github.com/Jonatan-Gani) (original) |
| programming | [`thermo-nuclear-code-quality-review`](programming/thermo-nuclear-code-quality-review/SKILL.md) | `/thermo-nuclear-code-quality-review` (manual only) | Extremely strict maintainability review — hunts giant files, spaghetti conditionals, and "code-judo" simplifications. | [Cursor team](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review) |
| programming | [`grill-me`](programming/grill-me/SKILL.md) | `/grill-me` or auto | Interviews you relentlessly about a plan or design, one question at a time with a recommended answer each, walking the decision tree until shared understanding. | [Matt Pocock](https://github.com/mattpocock/) |
| meta | [`handoff`](meta/handoff/SKILL.md) | `/handoff [focus]` or auto | Compacts the current conversation into a handoff document (saved to the OS temp dir) so a fresh agent can continue the work, including a suggested-skills section. | [Matt Pocock](https://github.com/mattpocock/) |
| meta | [`add-skill`](meta/add-skill/SKILL.md) | `/add-skill` or auto | Adds a skill to this repo — registers an already-written skill (Mode A) or creates one from scratch with the full eval/benchmark/description-optimization loop (Mode B), then updates this README and pushes. | [Anthropic](https://github.com/anthropics/skills/tree/main/skills/skill-creator) (adapted — edited) |
| productivity | [`caveman`](productivity/caveman/SKILL.md) | `/caveman` or auto | Ultra-compressed "caveman" communication mode — drops articles, filler, and pleasantries to cut token usage ~75% while keeping full technical accuracy, with auto-clarity exceptions for warnings and destructive actions. | [Matt Pocock](https://github.com/mattpocock/skills/tree/main/skills/productivity/caveman) |
| writing | [`humanizer`](writing/humanizer/SKILL.md) | `/humanizer` or auto | Removes signs of AI-generated writing (em-dash overuse, rule of three, inflated significance, promotional language, AI vocabulary, filler/hedging, etc.) to make text sound natural and human, with a draft → audit → final rewrite loop. Based on Wikipedia's "Signs of AI writing" guide. | [blader](https://github.com/blader/humanizer) |

## Credits

Skills authored by others are vendored here with attribution. All credit to their
original creators:

- **`thermo-nuclear-code-quality-review`** — by the **Cursor team**, from
  [cursor/plugins](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review).
- **`grill-me`** — by **[Matt Pocock](https://github.com/mattpocock/)**.
- **`handoff`** — by **[Matt Pocock](https://github.com/mattpocock/)**.
- **`caveman`** — by **[Matt Pocock](https://github.com/mattpocock/)**, from
  [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/caveman).
- **`humanizer`** — by **[blader](https://github.com/blader/humanizer)** (MIT;
  license preserved at `writing/humanizer/LICENSE`). Based on
  [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).
- **`add-skill`** — adapted from Anthropic's
  [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator)
  (Apache-2.0; license preserved at `meta/add-skill/LICENSE.txt`). **Edited for this
  repo:** added an "add an existing skill" mode and the registration/commit/push
  workflow; all original skill-creator functionality is preserved.

Skills marked _(original)_ above were written by the repo owner.
