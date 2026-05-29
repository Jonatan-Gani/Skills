#!/bin/bash
# Cloud environment setup: make these skills available to Claude Code in every
# session on this environment. Paste this into the environment's "Setup script"
# field (Settings -> environment -> Setup script).
#
# This repo organizes skills into category folders (programming/, writing/,
# finance/, meta/, ...) purely for human organization. Claude Code does NOT
# discover skills nested under category folders -- it only loads a skill from a
# directory placed DIRECTLY under ~/.claude/skills/. So we FLATTEN: find every
# SKILL.md at any depth and copy its folder into ~/.claude/skills/.
#
# This makes categories fully dynamic: add, rename, or nest category folders
# however you like and new skills are picked up automatically -- no edits here.
#
# NOTE: we clone to a side dir (not onto ~/.claude/skills) because the cloud VM
# ships that folder pre-populated, so a direct clone would fail.
#
# This script is written to NEVER fail the session: every step tolerates errors
# and it always exits 0. If the clone can't run (e.g. no network), skills just
# won't update this session.

set +e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/.claude/skills-src"

mkdir -p "$SKILLS_DIR"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
else
  # Clear any partial/leftover dir so the clone can succeed cleanly.
  rm -rf "$REPO_DIR"
  git clone --depth 1 https://github.com/Jonatan-Gani/Skills "$REPO_DIR" 2>/dev/null || true
fi

# Flatten: copy every skill folder (any dir containing a SKILL.md, at any depth)
# into ~/.claude/skills/. Guarded so a missing REPO_DIR (failed clone) can't
# make the script exit non-zero. Folder name = the loaded skill name, so keep
# skill folder names unique across categories.
if [ -d "$REPO_DIR" ]; then
  find "$REPO_DIR" -name SKILL.md -not -path '*/.git/*' -print0 2>/dev/null \
    | while IFS= read -r -d '' skillmd; do
        cp -rf "$(dirname "$skillmd")" "$SKILLS_DIR/" 2>/dev/null || true
      done
fi

exit 0
