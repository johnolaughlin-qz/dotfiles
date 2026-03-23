#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create ~/Desktop so screenshot-sync can scp files here
mkdir -p "$HOME/Desktop"

# Symlink /Users/johnolaughlin/Desktop → ~/Desktop so Mac-style paths work on gitpod
# (Claude Code receives local Mac paths like /Users/johnolaughlin/Desktop/Screenshot...
#  and needs to resolve them to the synced copy on the gitpod)
if [ ! -e /Users/johnolaughlin/Desktop ]; then
  sudo mkdir -p /Users/johnolaughlin
  sudo ln -sfn "$HOME/Desktop" /Users/johnolaughlin/Desktop
fi

# Fix go-services (and any devcontainer-based) gitpod: HISTFILE points to /dc/shellhistory/
# which only exists in Docker devcontainers, not Gitpod Classic.
if [ ! -d /dc/shellhistory ]; then
  sudo mkdir -p /dc/shellhistory && sudo chown "$(whoami)" /dc/shellhistory
fi

# Fix keybindings.zsh: bindkey fails silently when $terminfo values are empty,
# which happens if zsh-history-substring-search loads before terminfo is ready.
# Overwrite with a guarded version.
if [ -f "$HOME/.zshrc.d/keybindings.zsh" ]; then
  cat > "$HOME/.zshrc.d/keybindings.zsh" <<'EOF'
# Binds up and down arrow keys to search through command history
# https://github.com/zsh-users/zsh-history-substring-search
[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down
EOF
fi

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
