#!/bin/bash
# Cloud setup script for Jonatan-Gani/Skills.
# Intended to be run via: curl -fsSL https://raw.githubusercontent.com/Jonatan-Gani/Skills/main/setup.sh | bash
#
# Claude Code only discovers a skill when its folder sits DIRECTLY under
# ~/.claude/skills/ (i.e. ~/.claude/skills/<skill>/SKILL.md). This repo groups
# skills into free-form category folders (programming/, writing/, finance/, ...),
# so this script "flattens" every skill folder into ~/.claude/skills/.
#
# History note: the prior commit message claimed this rewrite fixed "markdown-
# fence corruption" and leftover category folders. That was a misdiagnosis from
# garbled terminal output -- the previous setup.sh was already clean and the
# install was already correctly flattened. The only real-world cause of "skills
# missing in new sessions" is a STALE cached clone: this script re-pulls on each
# run, so a fresh container/session picks up newly added skills automatically.
# This version is functionally equivalent to the original, plus the step-2
# defensive cleanup below (a harmless no-op when no category folders are present).
set +e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/.claude/skills-src"

mkdir -p "$SKILLS_DIR"

# 1. Get / update the source repo in a SIDE location. We never clone straight
#    onto ~/.claude/skills because the cloud VM ships that folder pre-populated
#    (bundled skills), which would make a direct clone fail.
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
else
  rm -rf "$REPO_DIR"
  git clone --depth 1 https://github.com/Jonatan-Gani/Skills "$REPO_DIR" 2>/dev/null || true
fi

# 2. Clean up leftovers from any earlier (non-flattening) run. A real skill
#    folder has SKILL.md DIRECTLY inside it; a stray category folder instead has
#    SKILL.md one level down (category/<skill>/SKILL.md). Remove those category
#    folders so nested, undiscoverable copies don't linger. This auto-handles
#    future categories without hardcoding names, and never touches a real
#    top-level skill (which has its own SKILL.md).
for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  if [ ! -f "${dir}SKILL.md" ] && compgen -G "${dir}*/SKILL.md" > /dev/null 2>&1; then
    rm -rf "$dir"
  fi
done

# 3. Flatten: copy every skill folder (any dir containing a SKILL.md, at any
#    depth) directly into ~/.claude/skills/. This is what makes the category
#    folders dynamic.
if [ -d "$REPO_DIR" ]; then
  find "$REPO_DIR" -name SKILL.md -not -path '*/.git/*' -print0 2>/dev/null \
    | while IFS= read -r -d '' skillmd; do
        cp -rf "$(dirname "$skillmd")" "$SKILLS_DIR/" 2>/dev/null || true
      done
fi

exit 0
