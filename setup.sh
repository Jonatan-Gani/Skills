#!/bin/bash
# Cloud environment setup: make these skills available to Claude Code in every
# session on this environment. Paste this into the environment's "Setup script"
# field (Settings -> environment -> Setup script).
#
# NOTE: we do NOT clone directly onto ~/.claude/skills, because the cloud VM
# ships that folder pre-populated (e.g. the bundled session-start-hook skill),
# so a direct clone fails with "destination path already exists". Instead we
# clone the repo to a side location and copy each skill folder into place,
# leaving any pre-installed skills untouched.

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
