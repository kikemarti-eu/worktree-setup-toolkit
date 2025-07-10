#!/bin/bash

# Worktree Troubleshooting Script
# Usage: ./troubleshoot.sh [worktree-name] [--fix]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Find bare repository
find_bare_repo() {
    for repo in *.git; do
        if [ -d "$repo" ]; then
            echo "$repo"
            return 0
        fi
    done
    return 1
}

# Main troubleshooting function
troubleshoot_worktree() {
    local worktree_name="$1"
    local fix_mode="$2"
    
    print_info "Troubleshooting worktree: $worktree_name"
    
    # Check if worktree directory exists
    if [[ ! -d "$worktree_name" ]]; then
        print_error "Worktree directory not found: $worktree_name"
        return 1
    fi
    
    # Check .git file
    if [[ ! -f "$worktree_name/.git" ]]; then
        print_error "Missing .git file in worktree"
        if [[ "$fix_mode" == "true" ]]; then
            print_info "Attempting to repair .git file..."
            echo "gitdir: $(pwd)/$BARE_REPO/worktrees/$worktree_name" > "$worktree_name/.git"
            print_success "Repaired .git file"
        fi
    fi
    
    # Check Git status
    cd "$worktree_name"
    if ! git status >/dev/null 2>&1; then
        print_error "Git status failed in worktree"
        cd ..
        return 1
    fi
    
    print_success "Worktree appears healthy"
    cd ..
    return 0
}

# Parse arguments
WORKTREE_NAME=""
FIX_MODE="false"

for arg in "$@"; do
    case "$arg" in
        --fix)
            FIX_MODE="true"
            ;;
        *)
            if [[ -z "$WORKTREE_NAME" ]]; then
                WORKTREE_NAME="$arg"
            fi
            ;;
    esac
done

# Find bare repo
BARE_REPO=$(find_bare_repo)
if [[ -z "$BARE_REPO" ]]; then
    print_error "No bare repository found"
    exit 1
fi

print_info "Using bare repository: $BARE_REPO"

if [[ -n "$WORKTREE_NAME" ]]; then
    # Troubleshoot specific worktree
    troubleshoot_worktree "$WORKTREE_NAME" "$FIX_MODE"
else
    # Troubleshoot all worktrees
    print_info "Checking all worktrees..."
    git -C "$BARE_REPO" worktree list --porcelain | grep '^worktree' | while read -r line; do
        path=$(echo "$line" | cut -d' ' -f2-)
        name=$(basename "$path")
        if [[ "$path" != *".git" ]]; then
            troubleshoot_worktree "$name" "$FIX_MODE"
        fi
    done
fi

print_success "Troubleshooting complete" 