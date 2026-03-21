#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.claude/commands
cp -r "$SCRIPT_DIR/.claude/commands/"* ~/.claude/commands/
