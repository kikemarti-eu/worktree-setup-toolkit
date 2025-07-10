#!/bin/bash
# migrate-existing.sh - Migrate existing repository to worktree setup
# Converts a standard Git repository to a professional worktree-based environment
#
# Usage: ./migrate-existing.sh <existing-repo-path> [project-name]

set -e

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === UTILITY FUNCTIONS ===
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

show_usage() {
    cat << EOF
Worktree Migration Tool - Migrate Existing Repository

Usage: $0 <existing-repo-path> [project-name]

Arguments:
  existing-repo-path    Path to existing Git repository
  project-name         Name for new worktree project (optional)

Examples:
  $0 /path/to/my-project
  $0 ./existing-repo new-worktree-project

This script will:
1. Create a backup of your existing repository
2. Convert it to a bare repository structure
3. Create worktrees for existing branches
4. Install automation scripts
5. Preserve all Git history and configuration

EOF
}

# === ARGUMENT PARSING ===
EXISTING_REPO=""
PROJECT_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [[ -z "$EXISTING_REPO" ]]; then
                EXISTING_REPO="$1"
            elif [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            else
                print_error "Too many arguments"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$EXISTING_REPO" ]]; then
    print_error "Missing required argument: existing-repo-path"
    show_usage
    exit 1
fi

# Convert to absolute path
EXISTING_REPO="$(cd "$EXISTING_REPO" && pwd)"

# Default project name based on repository name
if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="$(basename "$EXISTING_REPO")"
fi

# === VALIDATION ===
print_step "Validating existing repository..."

if [[ ! -d "$EXISTING_REPO" ]]; then
    print_error "Repository path does not exist: $EXISTING_REPO"
    exit 1
fi

if [[ ! -d "$EXISTING_REPO/.git" ]]; then
    print_error "Not a Git repository: $EXISTING_REPO"
    exit 1
fi

# Check for uncommitted changes
cd "$EXISTING_REPO"
if ! git diff-index --quiet HEAD --; then
    print_warning "Repository has uncommitted changes"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Migration cancelled"
        exit 0
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

print_info "Repository: $EXISTING_REPO"
print_info "Current branch: $CURRENT_BRANCH"
print_info "Remote URL: $REMOTE_URL"
print_info "Target project: $PROJECT_NAME"

# === MIGRATION PROCESS ===
PARENT_DIR="$(dirname "$EXISTING_REPO")"
NEW_PROJECT_PATH="$PARENT_DIR/${PROJECT_NAME}-worktree"
BACKUP_PATH="$PARENT_DIR/${PROJECT_NAME}-backup-$(date +%Y%m%d-%H%M%S)"

print_step "Creating backup..."
cp -r "$EXISTING_REPO" "$BACKUP_PATH"
print_success "Backup created: $BACKUP_PATH"

print_step "Creating worktree project structure..."
mkdir -p "$NEW_PROJECT_PATH"

# Clone existing repo as bare
print_info "Converting to bare repository..."
cd "$NEW_PROJECT_PATH"
git clone --bare "$EXISTING_REPO" "${PROJECT_NAME}.git"

# Create main worktree
print_info "Creating main worktree..."
git -C "${PROJECT_NAME}.git" worktree add main "$CURRENT_BRANCH"

# Create worktrees for other local branches
print_info "Creating worktrees for existing branches..."
cd "$EXISTING_REPO"
for branch in $(git branch | sed 's/^[* ] //' | grep -v "^$CURRENT_BRANCH$"); do
    print_info "Creating worktree for branch: $branch"
    cd "$NEW_PROJECT_PATH"
    
    # Determine appropriate directory based on branch name
    if [[ "$branch" =~ ^feature/ ]]; then
        git -C "${PROJECT_NAME}.git" worktree add "$branch" "$branch"
    elif [[ "$branch" =~ ^hotfix/ ]]; then
        git -C "${PROJECT_NAME}.git" worktree add "$branch" "$branch"
    elif [[ "$branch" =~ ^release/ ]]; then
        git -C "${PROJECT_NAME}.git" worktree add "$branch" "$branch"
    else
        # Place other branches in a generic location
        git -C "${PROJECT_NAME}.git" worktree add "branches/$branch" "$branch"
    fi
done

# Copy automation scripts
print_step "Installing automation scripts..."
cp "$TOOLKIT_ROOT/scripts/create-feature.sh" "$NEW_PROJECT_PATH/"
cp "$TOOLKIT_ROOT/scripts/build-branch.sh" "$NEW_PROJECT_PATH/"
cp "$TOOLKIT_ROOT/scripts/switch-context.sh" "$NEW_PROJECT_PATH/"
cp "$TOOLKIT_ROOT/scripts/sync-worktrees.sh" "$NEW_PROJECT_PATH/"
cp -r "$TOOLKIT_ROOT/scripts/utils" "$NEW_PROJECT_PATH/scripts/"

# Make scripts executable
chmod +x "$NEW_PROJECT_PATH"/*.sh
chmod +x "$NEW_PROJECT_PATH/scripts/"*.sh

# Create project documentation
print_step "Generating project documentation..."
cat > "$NEW_PROJECT_PATH/WORKTREE_GUIDE.md" << EOF
# ${PROJECT_NAME} - Worktree Development Guide

## Project Structure
\`\`\`
${PROJECT_NAME}/
├── ${PROJECT_NAME}.git/     # Bare repository (don't modify)
├── main/                    # Main branch worktree
├── feature/                 # Feature branch worktrees
├── hotfix/                  # Hotfix branch worktrees
└── [automation scripts]
\`\`\`

## Quick Start
\`\`\`bash
# Create new feature
./create-feature.sh feature/new-feature

# Switch between worktrees
./switch-context.sh

# Sync all worktrees
./sync-worktrees.sh
\`\`\`

## Migration Information
- **Original repository**: $EXISTING_REPO
- **Backup location**: $BACKUP_PATH
- **Migration date**: $(date)
- **Current branch**: $CURRENT_BRANCH

## Getting Help
- Run \`./scripts/utils/validate-setup.sh\` to check setup
- See automation scripts for daily workflow helpers
EOF

# Validate the migration
print_step "Validating migration..."
cd "$NEW_PROJECT_PATH"
if [[ -f "./scripts/utils/validate-setup.sh" ]]; then
    ./scripts/utils/validate-setup.sh
fi

print_success "🎉 Migration completed successfully!"
print_info ""
print_info "Next steps:"
print_info "  1. cd $NEW_PROJECT_PATH"
print_info "  2. Review worktree structure"
print_info "  3. Test automation scripts"
print_info "  4. Remove backup when satisfied: rm -rf $BACKUP_PATH"
print_info ""
print_info "Your original repository remains unchanged at: $EXISTING_REPO"
print_info "Backup available at: $BACKUP_PATH" 