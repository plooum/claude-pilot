#!/usr/bin/env bash
# Install claude-pilot: clone/pull, link the two global skills. Idempotent.
set -euo pipefail

REPO_URL="https://github.com/plooum/claude-pilot"
HOME_DIR="${CLAUDE_PILOT_HOME:-$HOME/.local/opt/claude-pilot}"
REF="${CLAUDE_PILOT_REF:-}"   # branch to clone (testers only); default: the repo's default branch

# 1. clone or pull
if [ -d "$HOME_DIR/.git" ]; then
  git -C "$HOME_DIR" pull --ff-only -q && echo "pull: $HOME_DIR"
else
  mkdir -p "$(dirname "$HOME_DIR")"
  if [ -n "$REF" ]; then
    git clone -q -b "$REF" "$REPO_URL" "$HOME_DIR"
  else
    git clone -q "$REPO_URL" "$HOME_DIR"
  fi
  echo "clone: $HOME_DIR"
fi
HOME_DIR="$(cd "$HOME_DIR" && pwd)"

# 2. skills
SKILL_DIR="$HOME/.claude/skills"
mkdir -p "$SKILL_DIR"
for name in pilot pilot-subagent; do
  LINK="$SKILL_DIR/$name"
  if [ -L "$LINK" ] && [ "$(readlink "$LINK")" = "$HOME_DIR/skills/$name" ]; then
    echo "skill $name already there"
  elif [ -e "$LINK" ] || [ -L "$LINK" ]; then
    echo "skill $name left alone: $LINK already exists and is not our link (warning)"
  else
    ln -s "$HOME_DIR/skills/$name" "$LINK" && echo "skill $name linked"
  fi
done
echo "Done. A new Claude Code session may be needed to see the skills."
