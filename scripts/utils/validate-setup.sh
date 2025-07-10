#!/bin/bash

# Worktree Setup Validation Script
# Usage: ./validate-setup.sh [--fix]

set -e

# === CONFIGURATION ===
FIX_ISSUES=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === HELPER FUNCTIONS ===
print_check() {
    echo -e "${BLUE}Checking: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

print_fail() {
    echo -e "${RED}  ✗ $1${NC}"
}

print_fix() {
    echo -e "${BLUE}  → $1${NC}"
}

# === ARGUMENT PARSING ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix)
            FIX_ISSUES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--fix]"
            echo ""
            echo "Options:"
            echo "  --fix     Attempt to fix issues automatically"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# === VALIDATION FUNCTIONS ===
check_bare_repository() {
    print_check "Bare repository"
    
    # Find bare repository
    BARE_REPO=""
    for repo in *.git; do
        if [ -d "$repo" ]; then
            BARE_REPO="$repo"
            break
        fi
    done
    
    if [[ -z "$BARE_REPO" ]]; then
        print_fail "No bare repository found (*.git)"
        return 1
    fi
    
    if [[ ! -d "$BARE_REPO/objects" ]]; then
        print_fail "Invalid bare repository structure: $BARE_REPO"
        return 1
    fi
    
    print_pass "Found bare repository: $BARE_REPO"
    
    # Check remote configuration
    if ! git -C "$BARE_REPO" remote get-url origin >/dev/null 2>&1; then
        print_warn "No origin remote configured"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            print_fix "Manual fix required: git -C $BARE_REPO remote add origin <url>"
        fi
    else
        ORIGIN_URL=$(git -C "$BARE_REPO" remote get-url origin)
        print_pass "Origin remote: $ORIGIN_URL"
    fi
    
    return 0
}

check_main_worktree() {
    print_check "Main worktree"
    
    if [[ ! -d "main" ]]; then
        print_fail "Main worktree directory not found"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            print_fix "Creating main worktree..."
            git -C "$BARE_REPO" worktree add main main
            print_pass "Main worktree created"
        fi
        return 1
    fi
    
    if [[ ! -f "main/.git" ]]; then
        print_fail "Main worktree .git file missing"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            print_fix "Repairing main worktree..."
            echo "gitdir: $(pwd)/$BARE_REPO/worktrees/main" > "main/.git"
            print_pass "Main worktree .git file repaired"
        fi
        return 1
    fi
    
    print_pass "Main worktree exists and appears healthy"
    return 0
}

check_automation_scripts() {
    print_check "Automation scripts"
    
    REQUIRED_SCRIPTS=(
        "create-feature.sh"
        "build-branch.sh"
        "switch-context.sh"
        "sync-worktrees.sh"
    )
    
    MISSING_SCRIPTS=()
    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if [[ ! -f "$script" ]]; then
            MISSING_SCRIPTS+=("$script")
            print_fail "Missing script: $script"
        elif [[ ! -x "$script" ]]; then
            print_warn "Script not executable: $script"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                chmod +x "$script"
                print_fix "Made executable: $script"
            fi
        else
            print_pass "Script OK: $script"
        fi
    done
    
    if [[ ${#MISSING_SCRIPTS[@]} -gt 0 ]]; then
        if [[ "$FIX_ISSUES" == "true" ]]; then
            print_fix "Consider copying missing scripts from toolkit"
        fi
        return 1
    fi
    
    return 0
}

check_worktree_health() {
    print_check "Worktree health"
    
    # Get list of all worktrees
    WORKTREE_COUNT=0
    UNHEALTHY_COUNT=0
    
    git -C "$BARE_REPO" worktree list --porcelain | grep -E '^worktree' | while read -r line; do
        worktree_path=$(echo "$line" | cut -d' ' -f2-)
        WORKTREE_COUNT=$((WORKTREE_COUNT + 1))
        
        if [[ "$worktree_path" == *".git" ]]; then
            continue  # Skip bare repository
        fi
        
        worktree_name=$(basename "$worktree_path")
        
        # Check if worktree directory exists
        if [[ ! -d "$worktree_path" ]]; then
            print_fail "Worktree directory missing: $worktree_name"
            UNHEALTHY_COUNT=$((UNHEALTHY_COUNT + 1))
            if [[ "$FIX_ISSUES" == "true" ]]; then
                print_fix "Pruning stale worktree: $worktree_name"
                git -C "$BARE_REPO" worktree remove "$worktree_name" --force || true
            fi
            continue
        fi
        
        # Check .git file
        if [[ ! -f "$worktree_path/.git" ]]; then
            print_fail "Worktree .git file missing: $worktree_name"
            UNHEALTHY_COUNT=$((UNHEALTHY_COUNT + 1))
            if [[ "$FIX_ISSUES" == "true" ]]; then
                metadata_dir="$BARE_REPO/worktrees/$worktree_name"
                echo "gitdir: $(realpath "$metadata_dir")" > "$worktree_path/.git"
                print_fix "Repaired .git file: $worktree_name"
            fi
        fi
    done
    
    if [[ $UNHEALTHY_COUNT -gt 0 ]]; then
        print_warn "Found $UNHEALTHY_COUNT unhealthy worktrees"
        return 1
    else
        print_pass "All worktrees appear healthy"
        return 0
    fi
}

check_git_hooks() {
    print_check "Git hooks"
    
    # Check hooks in main worktree
    if [[ -d "main" ]]; then
        HOOKS_DIR=$(cd main && git rev-parse --git-path hooks)
        if [[ -f "$HOOKS_DIR/.hook-metadata" ]]; then
            print_pass "Git hooks installed in main worktree"
        else
            print_warn "Git hooks not detected in main worktree"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                print_fix "Consider running: ./scripts/utils/setup-hooks.sh"
            fi
        fi
    fi
    
    return 0
}

check_documentation() {
    print_check "Documentation"
    
    if [[ -f "WORKTREE_GUIDE.md" ]]; then
        print_pass "Worktree guide exists"
    else
        print_warn "WORKTREE_GUIDE.md not found"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            print_fix "Consider generating documentation"
        fi
    fi
    
    return 0
}

check_gitignore() {
    print_check ".gitignore configuration"
    
    if [[ -f ".gitignore" ]]; then
        if grep -q "*.git/" ".gitignore" 2>/dev/null; then
            print_pass ".gitignore excludes bare repositories"
        else
            print_warn ".gitignore doesn't exclude *.git/ patterns"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                echo "*.git/" >> ".gitignore"
                print_fix "Added *.git/ to .gitignore"
            fi
        fi
    else
        print_warn "No .gitignore file found"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            cat > ".gitignore" << 'EOF'
# Worktree Setup - Basic .gitignore
*.git/
main/
feature/
hotfix/
performance/
EOF
            print_fix "Created basic .gitignore"
        fi
    fi
    
    return 0
}

check_build_artifacts() {
    print_check "Build artifacts"
    
    BUILD_DIRS=0
    LARGE_DIRS=0
    
    if [[ -d "builds" ]]; then
        BUILD_DIRS=$(find builds -maxdepth 1 -type d | wc -l)
        BUILD_DIRS=$((BUILD_DIRS - 1))  # Subtract the builds directory itself
        
        # Check for very large build directories
        if command -v du >/dev/null 2>&1; then
            while IFS= read -r dir; do
                if [[ -d "$dir" ]]; then
                    size=$(du -sm "$dir" 2>/dev/null | cut -f1 || echo "0")
                    if [[ $size -gt 1000 ]]; then  # > 1GB
                        LARGE_DIRS=$((LARGE_DIRS + 1))
                    fi
                fi
            done < <(find builds -maxdepth 1 -type d -not -name builds)
        fi
        
        print_pass "Found $BUILD_DIRS build directories"
        if [[ $LARGE_DIRS -gt 0 ]]; then
            print_warn "Found $LARGE_DIRS large build directories (>1GB)"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                print_fix "Consider cleaning old builds: rm -rf builds/old_*"
            fi
        fi
    else
        print_pass "No builds directory (normal for new setup)"
    fi
    
    return 0
}

# === MAIN EXECUTION ===
echo "=== Worktree Setup Validation ==="
echo ""

cd "$(dirname "$0")/../.."  # Go to project root

TOTAL_CHECKS=8
PASSED_CHECKS=0

# Run all checks
check_bare_repository && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_main_worktree && PASSED_CHECKS=$((PASSED_CHECKS + 1))  
check_automation_scripts && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_worktree_health && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_git_hooks && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_documentation && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_gitignore && PASSED_CHECKS=$((PASSED_CHECKS + 1))
check_build_artifacts && PASSED_CHECKS=$((PASSED_CHECKS + 1))

# === SUMMARY ===
echo ""
echo "=== Validation Summary ==="
echo -e "Checks passed: ${GREEN}$PASSED_CHECKS${NC}/$TOTAL_CHECKS"

if [[ $PASSED_CHECKS -eq $TOTAL_CHECKS ]]; then
    echo -e "${GREEN}✓ All checks passed! Your worktree setup is healthy.${NC}"
    exit 0
elif [[ $PASSED_CHECKS -gt $((TOTAL_CHECKS * 2 / 3)) ]]; then
    echo -e "${YELLOW}⚠ Most checks passed, but some issues were found.${NC}"
    if [[ "$FIX_ISSUES" == "false" ]]; then
        echo "Run with --fix to attempt automatic repairs."
    fi
    exit 1
else
    echo -e "${RED}✗ Multiple issues found with your worktree setup.${NC}"
    if [[ "$FIX_ISSUES" == "false" ]]; then
        echo "Run with --fix to attempt automatic repairs."
    fi
    exit 2
fi 