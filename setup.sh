#!/bin/bash
# Cloud environment setup: make these skills available to Claude Code.
# The repo root is the skills directory, so clone straight into ~/.claude/skills.
git clone https://github.com/jonatan-gani/skills ~/.claude/skills 2>/dev/null || true
