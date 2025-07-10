#!/bin/bash

# Sync all worktrees with remote
# Usage: ./sync-worktrees.sh [--dry-run]

set -e

DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

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

echo "=== Syncing worktrees ==="

# Fetch all updates
echo "Fetching from remote..."
if [ "$DRY_RUN" = "false" ]; then
    git -C "$BARE_REPO" fetch --all --prune
else
    echo "[DRY RUN] Would run: git fetch --all --prune"
fi

# Get list of all worktrees
echo "Checking worktrees..."
git -C "$BARE_REPO" worktree list --porcelain | grep -E '^worktree|^branch' | paste - - | while read -r worktree_line branch_line; do
    worktree_path=$(echo "$worktree_line" | cut -d' ' -f2-)
    branch_name=$(echo "$branch_line" | cut -d' ' -f2-)
    
    if [ "$branch_name" = "(detached)" ]; then
        echo "  Skipping detached HEAD at $worktree_path"
        continue
    fi
    
    echo "  Syncing $(basename "$worktree_path") [$branch_name]"
    
    if [ "$DRY_RUN" = "false" ]; then
        cd "$worktree_path"
        
        # Check if remote tracking branch exists
        if git show-ref --verify --quiet refs/remotes/origin/"$branch_name"; then
            echo "    Pulling from origin/$branch_name"
            git pull origin "$branch_name" || echo "    Warning: Failed to pull $branch_name"
        else
            echo "    No remote tracking branch for $branch_name"
        fi
        
        cd - > /dev/null
    else
        echo "    [DRY RUN] Would sync $branch_name"
    fi
done

echo "=== Sync complete ==="