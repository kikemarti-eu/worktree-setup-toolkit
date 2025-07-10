#!/bin/bash

# Git Hooks Setup for Worktree Environments
# Usage: ./setup-hooks.sh [--project-root <path>]

set -e

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PROJECT_ROOT=""

# === ARGUMENT PARSING ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project-root)
            if [[ -z "$2" || "$2" == --* ]]; then
                echo "Error: --project-root requires a path"
                exit 1
            fi
            PROJECT_ROOT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--project-root <path>]"
            echo ""
            echo "Options:"
            echo "  --project-root PATH  Root directory of the project setup"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# === DETECT ENVIRONMENT ===
if [[ -z "$PROJECT_ROOT" ]]; then
    PROJECT_ROOT="$(pwd)"
fi

# Check if we're in a Git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a Git repository"
    exit 1
fi

# Detect if we're in a worktree
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null || echo ".git")
if [[ "$GIT_COMMON_DIR" != ".git" ]]; then
    ENVIRONMENT="worktree"
    echo "Detected: Git worktree environment"
else
    ENVIRONMENT="standalone"
    echo "Detected: Standalone Git repository"
fi

# === HOOKS TEMPLATE DIRECTORY ===
HOOKS_TEMPLATE_DIR="$TOOLKIT_ROOT/templates/hooks"

# Create basic hooks if template directory doesn't exist
if [[ ! -d "$HOOKS_TEMPLATE_DIR" ]]; then
    echo "Creating basic Git hooks templates..."
    mkdir -p "$HOOKS_TEMPLATE_DIR"
    
    # Create post-checkout hook
    cat > "$HOOKS_TEMPLATE_DIR/post-checkout" << 'EOF'
#!/bin/bash
# Post-checkout hook for worktree environments

# Exit if this is a file checkout, not a branch checkout
if [ "$3" != "1" ]; then
    exit 0
fi

echo "Switched to branch: $(git branch --show-current)"

# Run any additional post-checkout tasks
if [ -f ".githooks/post-checkout-tasks.sh" ]; then
    ./.githooks/post-checkout-tasks.sh
fi
EOF

    # Create commit-msg hook
    cat > "$HOOKS_TEMPLATE_DIR/commit-msg" << 'EOF'
#!/bin/bash
# Commit message validation hook

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Basic validation: ensure commit message is not empty
if [[ -z "$(echo "$COMMIT_MSG" | tr -d '[:space:]')" ]]; then
    echo "Error: Commit message cannot be empty"
    exit 1
fi

# Check for conventional commit format (optional)
if ! echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+'; then
    echo "Warning: Consider using conventional commit format:"
    echo "  feat: add new feature"
    echo "  fix: fix bug"
    echo "  docs: update documentation"
    echo "  etc."
fi
EOF

    # Create pre-commit hook  
    cat > "$HOOKS_TEMPLATE_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for basic validation

# Check for merge conflict markers
if git diff --cached | grep -E '^[<>]=+' >/dev/null; then
    echo "Error: Merge conflict markers found in staged files"
    exit 1
fi

# Check for TODO/FIXME comments in staged files (warning only)
if git diff --cached --name-only | xargs grep -l "TODO\|FIXME" 2>/dev/null; then
    echo "Warning: Found TODO/FIXME comments in staged files"
fi

# Success
exit 0
EOF

    chmod +x "$HOOKS_TEMPLATE_DIR"/*
    echo "Created basic hooks templates in: $HOOKS_TEMPLATE_DIR"
fi

# === INSTALL HOOKS ===
HOOKS_DIR=$(git rev-parse --git-path hooks)
echo "Installing hooks to: $HOOKS_DIR"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Copy hooks from template
for hook_file in "$HOOKS_TEMPLATE_DIR"/*; do
    if [[ -f "$hook_file" ]]; then
        hook_name=$(basename "$hook_file")
        cp "$hook_file" "$HOOKS_DIR/$hook_name"
        chmod +x "$HOOKS_DIR/$hook_name"
        echo "Installed: $hook_name"
    fi
done

# Create metadata file to track installation
cat > "$HOOKS_DIR/.hook-metadata" << EOF
# Git Hooks Metadata
installed_by=worktree-setup-toolkit
installed_at=$(date -Iseconds)
environment=$ENVIRONMENT
project_root=$PROJECT_ROOT
toolkit_version=1.0.0
hooks_template_dir=$HOOKS_TEMPLATE_DIR
EOF

echo "✓ Git hooks setup complete"
echo "✓ Metadata saved to: $HOOKS_DIR/.hook-metadata"

# === VALIDATION ===
echo "Validating hooks installation..."
for hook in post-checkout commit-msg pre-commit; do
    if [[ -x "$HOOKS_DIR/$hook" ]]; then
        echo "  ✓ $hook: installed and executable"
    else
        echo "  ✗ $hook: not installed or not executable"
    fi
done

echo ""
echo "Hooks installed successfully!"
echo "These hooks will be active for this worktree only." 