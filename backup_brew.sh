#!/usr/bin/env bash
set -euo pipefail

# 临时文件路径
TMP_FILE="/tmp/Brewfile.tmp"

# 目标输出路径
DOTFILES_DIR="$HOME/.dotfiles"
OUT_FILE="$DOTFILES_DIR/Brewfile"

# 确保目录存在
mkdir -p "$DOTFILES_DIR"

# 1. 导出完整 Brewfile 到临时文件
brew bundle dump --force --file="$TMP_FILE"

# 2. 去除 vscode 插件条目
grep -v '^vscode ' "$TMP_FILE" > "$OUT_FILE"
