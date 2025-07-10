#!/bin/bash

# Quick switch between worktrees
# Usage: ./switch-context.sh [branch-name]
# If no branch-name provided, shows available worktrees

set -e

cd "$(dirname "$0")"

# Find bare repository
BARE_REPO=""
for repo in *.git; do
    if [ -d "$repo" ]; then
        BARE_REPO="$repo"
        break
    fi
done

if [ -z "$BARE_REPO" ]; then
    echo "Error: No bare repository found (*.git)"
    echo "Make sure you're in a directory with a bare Git repository"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Available worktrees:"
    git -C "$BARE_REPO" worktree list | while read -r worktree_path commit branch; do
        if [[ "$worktree_path" != *".git" ]]; then
            rel_path=$(realpath --relative-to="$(pwd)" "$worktree_path" 2>/dev/null || basename "$worktree_path")
            echo "  $rel_path -> $branch"
        fi
    done
    echo ""
    echo "Usage: $0 <branch-name>"
    echo "Example: $0 feature/ai-proxy-basics"
    exit 0
fi

BRANCH_NAME="$1"

# Check if worktree exists
if [ -d "$BRANCH_NAME" ]; then
    echo "Switching to $BRANCH_NAME"
    cd "$BRANCH_NAME"
    exec bash
else
    echo "Worktree $BRANCH_NAME not found."
    echo "Available worktrees:"
    ./switch-context.sh
    exit 1
fi