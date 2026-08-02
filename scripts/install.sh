#!/usr/bin/env bash
# Install the dvc skill into common agent skill directories.
# Usage:
#   ./scripts/install.sh              # project-local (cwd)
#   ./scripts/install.sh --global     # user home
#   ./scripts/install.sh --agent claude-code|codex|all
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_SRC="$ROOT/skills/dvc"
MODE="local"
AGENT="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global) MODE="global"; shift ;;
    --agent) AGENT="${2:-all}"; shift 2 ;;
    -h|--help)
      sed -n '2,7p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
  echo "Missing $SKILL_SRC/SKILL.md" >&2
  exit 1
fi

install_one() {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$SKILL_SRC" "$dest"
  echo "Installed → $dest"
}

case "$MODE" in
  local)
    base="$PWD"
    [[ "$AGENT" == "all" || "$AGENT" == "claude-code" || "$AGENT" == "claude" ]] && \
      install_one "$base/.claude/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "codex" ]] && \
      install_one "$base/.agents/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "opencode" || "$AGENT" == "omp" ]] && \
      install_one "$base/.opencode/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "grok" ]] && \
      install_one "$base/.grok/skills/dvc"
    ;;
  global)
    [[ "$AGENT" == "all" || "$AGENT" == "claude-code" || "$AGENT" == "claude" ]] && \
      install_one "${HOME}/.claude/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "codex" ]] && \
      install_one "${HOME}/.agents/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "opencode" || "$AGENT" == "omp" ]] && \
      install_one "${HOME}/.opencode/skills/dvc"
    [[ "$AGENT" == "all" || "$AGENT" == "grok" ]] && \
      install_one "${HOME}/.grok/skills/dvc"
    ;;
esac

echo "Done. Restart your agent session if it was already running."
echo "Tip: npx skills add $ROOT   # auto-detect agents (skills.sh CLI)"
