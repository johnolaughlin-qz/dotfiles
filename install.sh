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

# On interactive SSH into a Gitpod, cd to the workspace repo and launch Claude.
# exec replaces the shell so quitting claude ends the session; use ! for bash commands inside claude.
# Skips non-interactive sessions (scp, ssh host 'cmd') and secondary clones (quizlet-shared-kotlin).
mkdir -p "$HOME/.zshrc.d"
cat > "$HOME/.zshrc.d/auto-claude.zsh" <<'EOF'
if [[ -n "$GITPOD_WORKSPACE_ID" && -n "$SSH_CONNECTION" && -o interactive ]]; then
  for _dir in /workspace/*/; do
    [[ "$(basename "$_dir")" == "quizlet-shared-kotlin" ]] && continue
    [[ -d "${_dir}.git" ]] && cd "$_dir" && break
  done
  unset _dir
  command -v claude &>/dev/null && exec claude
fi
EOF

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
