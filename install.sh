#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.claude/skills
cp -r "$SCRIPT_DIR/.claude/skills/"* ~/.claude/skills/
