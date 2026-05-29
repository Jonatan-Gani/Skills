#!/bin/bash
# Cloud environment setup: make these skills available to Claude Code in every
# session on this environment. Paste this into the environment's "Setup script"
# field (Settings -> environment -> Setup script).
#
# The repo root IS the skills directory, so it clones straight into
# ~/.claude/skills. If the environment cache already has the folder, pull instead.

SKILLS_DIR="$HOME/.claude/skills"

if [ -d "$SKILLS_DIR/.git" ]; then
  git -C "$SKILLS_DIR" pull --ff-only || true
else
  git clone https://github.com/Jonatan-Gani/Skills "$SKILLS_DIR" 2>/dev/null || true
fi
