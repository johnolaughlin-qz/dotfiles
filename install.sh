#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create ~/Desktop so screenshot-sync can scp files here
mkdir -p "$HOME/Desktop"

# Copy skills into the project's .claude/skills/ where Claude Code discovers them
REPO_DIR="/workspace/quizlet-web"
if [ -d "$REPO_DIR/.git" ]; then
  mkdir -p "$REPO_DIR/.claude/skills"
  cp -r "$SCRIPT_DIR/.claude/skills/"* "$REPO_DIR/.claude/skills/"

  # Exclude personal skills from git tracking
  if ! grep -q '.claude/skills/' "$REPO_DIR/.git/info/exclude" 2>/dev/null; then
    echo '.claude/skills/' >> "$REPO_DIR/.git/info/exclude"
  fi
fi
