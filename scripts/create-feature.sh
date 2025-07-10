#!/bin/bash

# Create a new feature branch and worktree
# Usage: ./create-feature.sh <branch-name> [base-branch] [--issue <issue-number>]
# Example: ./create-feature.sh feature/new-ui main --issue 42
#          ./create-feature.sh feature/another-fix --issue 123  (defaults to main)

set -e

# --- Argument parsing ---
BRANCH_NAME=""
BASE_BRANCH=""
ISSUE_NUMBER=""

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --issue)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: --issue requires a value." >&2
        exit 1
      fi
      ISSUE_NUMBER="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo "Usage: $0 <branch-name> [base-branch] [--issue <issue-number>]"
      echo "Example: $0 feature/new-ui main --issue 42"
      echo "         $0 feature/audio-cleanup --issue 30"
      exit 0
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# --- Assign positional arguments and validate ---
if [ ${#POSITIONAL_ARGS[@]} -eq 0 ]; then
  echo "Error: Missing required argument <branch-name>"
  echo "Usage: $0 <branch-name> [base-branch] [--issue <issue-number>]"
  exit 1
fi

BRANCH_NAME="${POSITIONAL_ARGS[0]}"
BASE_BRANCH="${POSITIONAL_ARGS[1]:-main}" # Default to main if second positional arg is missing

WORKTREE_DIR="$BRANCH_NAME"

# Ensure we're in the correct directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$WORKTREE_DIR")
if [ "$PARENT_DIR" != "." ] && [ ! -d "$PARENT_DIR" ]; then
    mkdir -p "$PARENT_DIR"
fi

# Get absolute path for worktree directory
WORKTREE_ABSOLUTE_PATH="$SCRIPT_DIR/$WORKTREE_DIR"

# Find bare repository (adapt to any project name)
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

# Temporarily disable global hooks to prevent interference during creation
ORIGINAL_HOOKS_PATH=$(git -C "$BARE_REPO" config --get core.hooksPath || true)
if [ -n "$ORIGINAL_HOOKS_PATH" ]; then
    git -C "$BARE_REPO" config --unset core.hooksPath
fi

# Check if branch already exists
# This command might fail if hooks interfere, so we use '|| true' to continue
if git -C "$BARE_REPO" show-ref --verify --quiet refs/heads/"$BRANCH_NAME"; then
    echo "Branch $BRANCH_NAME already exists. Creating worktree for existing branch."
    git -C "$BARE_REPO" worktree add "$WORKTREE_ABSOLUTE_PATH" "$BRANCH_NAME" || true
else
    echo "Creating new branch $BRANCH_NAME from $BASE_BRANCH"
    git -C "$BARE_REPO" worktree add "$WORKTREE_ABSOLUTE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH" || true
fi

# --- Health Check & Repair ---
echo "Running health check on new worktree..."
METADATA_DIR="$BARE_REPO/worktrees/$(basename "$WORKTREE_DIR")"

# 1. Fix .git file link
if [ ! -f "$WORKTREE_ABSOLUTE_PATH/.git" ]; then
    echo "  - Repairing .git file link..."
    echo "gitdir: $SCRIPT_DIR/$METADATA_DIR" > "$WORKTREE_ABSOLUTE_PATH/.git"
fi

# 2. Fix missing config.worktree
CONFIG_FILE="$METADATA_DIR/config.worktree"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "  - Repairing missing config.worktree..."
    CONFIG_CONTENT="[core]\n\tbare = false\n\thooksPath = $SCRIPT_DIR/$METADATA_DIR/hooks"
    echo -e "$CONFIG_CONTENT" > "$CONFIG_FILE"
fi

echo "✅ Health check complete. Worktree is ready."

# Set up tracking if remote branch exists
(
    cd "$WORKTREE_ABSOLUTE_PATH"
    if git show-ref --verify --quiet refs/remotes/origin/"$BRANCH_NAME"; then
        echo "Setting up tracking to origin/$BRANCH_NAME"
        git branch --set-upstream-to=origin/"$BRANCH_NAME" "$BRANCH_NAME"
    fi
)

# Restore global hooks path
if [ -n "$ORIGINAL_HOOKS_PATH" ]; then
    git -C "$BARE_REPO" config core.hooksPath "$ORIGINAL_HOOKS_PATH"
fi

# Set up issue linking if issue number provided
if [ -n "$ISSUE_NUMBER" ]; then
    echo "Setting up issue linking for #$ISSUE_NUMBER..."
    
    # Determine repository URL for issue linking
    REPO_URL=$(git -C "$BARE_REPO" remote get-url origin || echo "")
    if [[ "$REPO_URL" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
        GITHUB_ORG="${BASH_REMATCH[1]}"
        GITHUB_REPO="${BASH_REMATCH[2]}"
        ISSUE_URL="https://github.com/$GITHUB_ORG/$GITHUB_REPO/issues/$ISSUE_NUMBER"
    else
        ISSUE_URL="Issue #$ISSUE_NUMBER"
    fi
    
    # Set branch description (from within the worktree)
    cd "$WORKTREE_ABSOLUTE_PATH"
    git config branch."$BRANCH_NAME".description "Implements feature for issue #$ISSUE_NUMBER - $ISSUE_URL"
    cd - > /dev/null
    
    # Create branch info file
    cat > "$WORKTREE_ABSOLUTE_PATH/BRANCH_INFO.md" << EOF
# Feature Branch: $(basename "$BRANCH_NAME")

## Issue Reference
- **GitHub Issue**: [$ISSUE_URL]($ISSUE_URL)
- **Issue Type**: Feature Enhancement
- **Priority**: TBD

## Branch Information
- **Base Branch**: $BASE_BRANCH
- **Created**: $(date +%Y-%m-%d)
- **Branch Name**: $BRANCH_NAME

## Description
This branch implements functionality as specified in issue #$ISSUE_NUMBER.

## Development Notes
- Work on this branch should directly address the requirements outlined in the linked GitHub issue
- All commits should reference the issue number using conventional commit format
- Testing should validate the functionality described in issue #$ISSUE_NUMBER

## Commit Message Convention
Use the format: \`feat: description - fixes #$ISSUE_NUMBER\` or \`feat: description - refs #$ISSUE_NUMBER\`
EOF
    
    echo "✓ Branch linked to issue #$ISSUE_NUMBER"
    echo "✓ Branch description set"
    echo "✓ BRANCH_INFO.md created"
fi

# Check if hooks are installed in the new worktree
(
    cd "$WORKTREE_ABSOLUTE_PATH"
    GIT_HOOKS_DIR=$(git rev-parse --git-path hooks)
    if [ ! -f "$GIT_HOOKS_DIR/.hook-metadata" ]; then
        echo ""
        echo "⚠️  ADVERTENCIA: Git hooks no detectados en este worktree."
        echo "   Si es la primera vez que usas este repositorio, ejecuta el instalador:"
        echo "   ./.githooks/install.sh"
        echo ""
    fi
)

echo "Worktree created at: $WORKTREE_DIR"
echo "To switch to this worktree: cd $WORKTREE_DIR"