#!/usr/bin/env bash
# Install the agent-factory skill into one or more agent harnesses.
#
# The repo root is the skill: SKILL.md plus the examples/ and references/ it
# links to. Every harness gets an identical copy of that folder; nothing is
# rewritten per tool, so there is one source of truth.
#
# Usage: ./install.sh <agents|claude|hermes|all> [--project DIR] [--dry-run]
set -euo pipefail

SKILL_NAME="agent-factory"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_FILES=(SKILL.md LICENSE examples references)

usage() {
  cat <<USAGE
Usage: ./install.sh <agents|claude|hermes|all> [--project DIR] [--dry-run]

Install the $SKILL_NAME skill for one or more agent harnesses.

Targets:
  agents   ~/.agents/skills/$SKILL_NAME   Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode
  claude   ~/.claude/skills/$SKILL_NAME   Claude Code
  hermes   ~/.hermes/skills/$SKILL_NAME   Hermes
  all      every target above

Options:
  --project DIR   install into DIR/.agents/skills and DIR/.claude/skills instead
                  of your home directory (hermes has no project scope)
  --dry-run       print what would be copied without copying it
  --help          show this help

Re-running is safe: the installed folder is replaced with a fresh copy.
USAGE
}

TARGET=""
PROJECT_DIR=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    agents|claude|hermes|all)
      TARGET="$1"
      ;;
    --project)
      if [ $# -lt 2 ]; then
        echo "install.sh: --project needs a directory" >&2
        exit 2
      fi
      PROJECT_DIR="$2"
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "install.sh: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ -z "$TARGET" ]; then
  usage >&2
  exit 2
fi

if [ -n "$PROJECT_DIR" ] && [ ! -d "$PROJECT_DIR" ]; then
  echo "install.sh: project directory does not exist: $PROJECT_DIR" >&2
  exit 2
fi

# Base directory for a harness: the project when --project is given, else home.
base_dir() {
  if [ -n "$PROJECT_DIR" ]; then
    echo "$PROJECT_DIR"
  else
    echo "$HOME"
  fi
}

# Replace <skills_dir>/agent-factory with a fresh copy of the skill files.
install_into() {
  local label="$1"
  local skills_dir="$2"
  local dest="$skills_dir/$SKILL_NAME"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $label: replace $dest with ${SKILL_FILES[*]}"
    return
  fi

  # Stage next to the destination, then swap, so a failed copy never leaves
  # a half-installed skill behind.
  mkdir -p "$skills_dir"
  local staging
  staging="$(mktemp -d "$skills_dir/.$SKILL_NAME.XXXXXX")"
  for item in "${SKILL_FILES[@]}"; do
    cp -R "$SRC/$item" "$staging/"
  done
  rm -rf "$dest"
  mv "$staging" "$dest"
  echo "installed $label -> $dest"
}

install_agents() { install_into "agents" "$(base_dir)/.agents/skills"; }
install_claude() { install_into "claude" "$(base_dir)/.claude/skills"; }
install_hermes() {
  if [ -n "$PROJECT_DIR" ]; then
    echo "skipped hermes: it has no project-scoped skills folder"
    return
  fi
  install_into "hermes" "$HOME/.hermes/skills"
}

case "$TARGET" in
  agents) install_agents ;;
  claude) install_claude ;;
  hermes) install_hermes ;;
  all)
    install_agents
    install_claude
    install_hermes
    ;;
esac
