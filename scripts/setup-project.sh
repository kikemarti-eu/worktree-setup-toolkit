#!/bin/bash
# setup-project.sh - Universal Git Worktree Setup Script
# Converts any repository into a professional worktree-based development environment
#
# Usage: ./setup-project.sh <repo-url> <project-name> [options]
# Example: ./setup-project.sh https://github.com/org/repo.git my-project

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

# Function to detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*|MINGW*|MSYS*) echo "Windows";;
        *)          echo "Unknown";;
    esac
}

# Function to show usage
show_usage() {
    cat << EOF
Git Worktree Setup Toolkit - Universal Project Setup

Usage: $0 <repo-url> <project-name> [options]

Arguments:
  repo-url       Git repository URL (HTTPS or SSH)
  project-name   Name for the local project directory

Options:
  --base-branch BRANCH    Base branch to create main worktree from (default: main)
  --config PATH           Path to project template config file
  --dry-run              Show what would be done without executing
  --skip-hooks           Skip Git hooks installation
  --help                 Show this help message

Examples:
  $0 https://github.com/flutter/gallery.git flutter-demo
  $0 git@github.com:org/project.git my-project --base-branch develop
  $0 https://github.com/org/node-app.git node-demo --config templates/node-project.json

Project Templates:
$(find "$TOOLKIT_ROOT/templates" -name "*.json" 2>/dev/null | sed 's|.*/||; s|\.json$||' | sed 's/^/  /')

EOF
}

# === ARGUMENT PARSING ===
REPO_URL=""
PROJECT_NAME=""
BASE_BRANCH="main"
CONFIG_FILE=""
DRY_RUN=false
SKIP_HOOKS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base-branch)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-hooks)
            SKIP_HOOKS=true
            shift
            ;;
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
            if [[ -z "$REPO_URL" ]]; then
                REPO_URL="$1"
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
if [[ -z "$REPO_URL" || -z "$PROJECT_NAME" ]]; then
    print_error "Missing required arguments"
    show_usage
    exit 1
fi

# Validate config file if provided
if [[ -n "$CONFIG_FILE" && ! -f "$CONFIG_FILE" ]]; then
    print_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# === MAIN SETUP PROCESS ===
PLATFORM=$(detect_platform)
PARENT_DIR="$(dirname "$TOOLKIT_ROOT")"
PROJECT_PATH="$PARENT_DIR/$PROJECT_NAME"
BARE_REPO_NAME="${PROJECT_NAME}.git"
BARE_REPO_PATH="$PROJECT_PATH/$BARE_REPO_NAME"

print_step "Setting up Git Worktree environment for: $PROJECT_NAME"
print_info "Repository: $REPO_URL"
print_info "Base branch: $BASE_BRANCH"
print_info "Platform: $PLATFORM"
print_info "Target directory: $PROJECT_PATH"

if [[ "$DRY_RUN" == "true" ]]; then
    print_warning "DRY RUN MODE - No changes will be made"
fi

# === STEP 1: VALIDATE PREREQUISITES ===
print_step "Validating prerequisites..."

# Check Git installation
if ! command -v git >/dev/null 2>&1; then
    print_error "Git is not installed or not in PATH"
    exit 1
fi

# Check Git version (worktrees require Git 2.5+)
GIT_VERSION=$(git --version | sed 's/git version //')
print_info "Git version: $GIT_VERSION"

# Check if target directory already exists
if [[ -d "$PROJECT_PATH" ]]; then
    print_error "Target directory already exists: $PROJECT_PATH"
    print_info "Please choose a different project name or remove the existing directory"
    exit 1
fi

# === STEP 2: CREATE PROJECT DIRECTORY ===
print_step "Creating project directory structure..."

if [[ "$DRY_RUN" == "false" ]]; then
    mkdir -p "$PROJECT_PATH"
    cd "$PROJECT_PATH"
else
    print_info "[DRY RUN] Would create: $PROJECT_PATH"
fi

# === STEP 3: CLONE AS BARE REPOSITORY ===
print_step "Cloning repository as bare repository..."

if [[ "$DRY_RUN" == "false" ]]; then
    print_info "Cloning: $REPO_URL -> $BARE_REPO_NAME"
    if ! git clone --bare "$REPO_URL" "$BARE_REPO_NAME"; then
        print_error "Failed to clone repository"
        exit 1
    fi
    
    # Configure remote and fetch settings
    cd "$BARE_REPO_NAME"
    git remote set-url origin "$REPO_URL"
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git fetch origin
    
    # List available branches
    print_info "Available branches:"
    git branch -a | sed 's/^/  /'
    
    cd "$PROJECT_PATH"
else
    print_info "[DRY RUN] Would clone: $REPO_URL as bare repository"
fi

# === STEP 4: CREATE MAIN WORKTREE ===
print_step "Creating main worktree from branch: $BASE_BRANCH"

if [[ "$DRY_RUN" == "false" ]]; then
    # Check if base branch exists
    if ! git -C "$BARE_REPO_NAME" show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
        print_warning "Branch '$BASE_BRANCH' not found on remote. Available branches:"
        git -C "$BARE_REPO_NAME" branch -r | sed 's/^/  /'
        read -p "Enter the correct branch name: " BASE_BRANCH
    fi
    
    print_info "Creating main worktree from origin/$BASE_BRANCH"
    git -C "$BARE_REPO_NAME" worktree add main "$BASE_BRANCH"
else
    print_info "[DRY RUN] Would create main worktree from $BASE_BRANCH"
fi

# === STEP 5: COPY AUTOMATION SCRIPTS ===
print_step "Installing automation scripts..."

SCRIPTS_TO_COPY=(
    "create-feature.sh"
    "build-branch.sh" 
    "switch-context.sh"
    "sync-worktrees.sh"
)

if [[ "$DRY_RUN" == "false" ]]; then
    for script in "${SCRIPTS_TO_COPY[@]}"; do
        if [[ -f "$TOOLKIT_ROOT/scripts/$script" ]]; then
            cp "$TOOLKIT_ROOT/scripts/$script" "$PROJECT_PATH/"
            chmod +x "$PROJECT_PATH/$script"
            print_info "Installed: $script"
        else
            print_warning "Script not found: $script (skipping)"
        fi
    done
else
    print_info "[DRY RUN] Would copy automation scripts"
fi

# === STEP 6: SETUP GIT HOOKS (if not skipped) ===
if [[ "$SKIP_HOOKS" == "false" ]]; then
    print_step "Setting up Git hooks..."
    
    if [[ "$DRY_RUN" == "false" ]]; then
        HOOKS_SCRIPT="$TOOLKIT_ROOT/scripts/utils/setup-hooks.sh"
        if [[ -f "$HOOKS_SCRIPT" ]]; then
            cd "$PROJECT_PATH/main"
            "$HOOKS_SCRIPT" --project-root "$PROJECT_PATH"
            cd "$PROJECT_PATH"
            print_info "Git hooks configured"
        else
            print_warning "Hooks setup script not found (skipping)"
        fi
    else
        print_info "[DRY RUN] Would setup Git hooks"
    fi
else
    print_warning "Skipping Git hooks setup (--skip-hooks specified)"
fi

# === STEP 7: APPLY PROJECT TEMPLATE (if specified) ===
if [[ -n "$CONFIG_FILE" ]]; then
    print_step "Applying project template: $CONFIG_FILE"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Basic template application (can be extended)
        if command -v jq >/dev/null 2>&1; then
            PROJECT_TYPE=$(jq -r '.type // "generic"' "$CONFIG_FILE")
            print_info "Project type: $PROJECT_TYPE"
            
            # Apply gitignore patterns if specified
            if jq -e '.ignore_patterns' "$CONFIG_FILE" >/dev/null 2>&1; then
                print_info "Applying custom .gitignore patterns"
                jq -r '.ignore_patterns[]' "$CONFIG_FILE" >> "$PROJECT_PATH/main/.gitignore"
            fi
        else
            print_warning "jq not found - template features limited"
        fi
    else
        print_info "[DRY RUN] Would apply template: $CONFIG_FILE"
    fi
fi

# === STEP 8: GENERATE PROJECT README ===
print_step "Generating project documentation..."

if [[ "$DRY_RUN" == "false" ]]; then
    cat > "$PROJECT_PATH/WORKTREE_GUIDE.md" << EOF
# $PROJECT_NAME - Git Worktree Workspace

This project uses Git Worktrees for efficient multi-branch development.

## Quick Start

\`\`\`bash
# Create a new feature
./create-feature.sh feature/my-feature --issue 123

# Build the project
./build-branch.sh feature/my-feature -- <build-args>

# Switch between worktrees
./switch-context.sh feature/my-feature

# Sync all worktrees
./sync-worktrees.sh
\`\`\`

## Directory Structure

\`\`\`
$PROJECT_NAME/
├── $BARE_REPO_NAME/     # Bare repository (don't modify)
├── main/                # Main branch worktree
├── feature/             # Feature branch worktrees
├── hotfix/              # Hotfix worktrees
└── [scripts]            # Automation scripts
\`\`\`

## Available Scripts

- **create-feature.sh**: Create new feature branches with issue linking
- **build-branch.sh**: Build specific worktrees
- **switch-context.sh**: Quick context switching
- **sync-worktrees.sh**: Sync all worktrees with remote

For complete documentation, see: https://github.com/your-username/worktree-setup-toolkit

## Repository Information

- **Source**: $REPO_URL
- **Base Branch**: $BASE_BRANCH
- **Setup Date**: $(date)
- **Platform**: $PLATFORM
EOF

    print_info "Generated WORKTREE_GUIDE.md"
else
    print_info "[DRY RUN] Would generate project documentation"
fi

# === STEP 9: FINAL VALIDATION ===
print_step "Validating setup..."

if [[ "$DRY_RUN" == "false" ]]; then
    # Verify main worktree
    if [[ -d "$PROJECT_PATH/main" && -f "$PROJECT_PATH/main/.git" ]]; then
        print_success "Main worktree created successfully"
    else
        print_error "Main worktree validation failed"
        exit 1
    fi
    
    # Verify bare repository
    if [[ -d "$BARE_REPO_PATH" && -f "$BARE_REPO_PATH/config" ]]; then
        print_success "Bare repository configured correctly"
    else
        print_error "Bare repository validation failed"
        exit 1
    fi
    
    # Test script permissions
    cd "$PROJECT_PATH"
    for script in "${SCRIPTS_TO_COPY[@]}"; do
        if [[ -x "$script" ]]; then
            print_info "✓ $script is executable"
        else
            print_warning "✗ $script is not executable"
        fi
    done
else
    print_info "[DRY RUN] Would validate setup"
fi

# === SUCCESS SUMMARY ===
print_success "🎉 Project setup completed successfully!"
echo
print_info "Next steps:"
echo -e "  ${CYAN}1.${NC} cd $PROJECT_PATH"
echo -e "  ${CYAN}2.${NC} ./create-feature.sh feature/your-first-feature"
echo -e "  ${CYAN}3.${NC} cd feature/your-first-feature"
echo -e "  ${CYAN}4.${NC} # Start coding!"
echo
print_info "Available commands:"
echo -e "  ${GREEN}./create-feature.sh${NC}   - Create new feature branches"
echo -e "  ${GREEN}./switch-context.sh${NC}   - List and switch between worktrees"
echo -e "  ${GREEN}./sync-worktrees.sh${NC}   - Sync all worktrees with remote"
echo -e "  ${GREEN}./build-branch.sh${NC}     - Build specific worktrees"
echo
print_info "Documentation:"
echo -e "  ${GREEN}cat WORKTREE_GUIDE.md${NC} - Project-specific guide"
echo -e "  ${GREEN}https://github.com/your-username/worktree-setup-toolkit${NC}"
echo
print_success "Happy coding! 🚀" 