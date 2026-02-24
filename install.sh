#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/wp"
SOURCE="$(cd "$(dirname "$0")" && pwd)/SKILL.md"

echo "=== Claude Code WP Skill Installer ==="
echo ""

# Check source file exists
if [ ! -f "$SOURCE" ]; then
  echo "ERROR: SKILL.md not found in $(dirname "$SOURCE")"
  exit 1
fi

# Create directory
mkdir -p "$SKILL_DIR"

# Overwrite confirmation
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  echo "WARNING: $SKILL_DIR/SKILL.md already exists."
  read -rp "Overwrite? (y/N): " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Copy
cp "$SOURCE" "$SKILL_DIR/SKILL.md"
echo "Installed: $SKILL_DIR/SKILL.md"

# Security notice
echo ""
echo "--- Security Reminder / セキュリティに関する注意 ---"
echo "SKILL.md contains SSH host and path placeholders."
echo "After editing with your real credentials, do NOT commit"
echo "the configured file to a public repository."
echo ""
echo "SKILL.md には SSH ホスト名やパスのプレースホルダーが含まれています。"
echo "実際の値に書き換えた後、公開リポジトリにコミットしないでください。"
echo ""
echo "Done! Edit $SKILL_DIR/SKILL.md to configure your environment."
