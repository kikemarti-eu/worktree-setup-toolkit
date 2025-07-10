#!/bin/bash
# validate-toolkit.sh - Validate worktree-setup-toolkit integrity
# Usage: ./scripts/validate-toolkit.sh [--fix]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(dirname "$SCRIPT_DIR")"
FIX_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix)
            FIX_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--fix]"
            echo "Validates the worktree-setup-toolkit structure and functionality"
            echo ""
            echo "Options:"
            echo "  --fix    Attempt to fix issues automatically"
            echo "  --help   Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

cd "$TOOLKIT_ROOT"

print_info "Validating worktree-setup-toolkit..."
print_info "Toolkit root: $TOOLKIT_ROOT"

ERRORS=0
WARNINGS=0

# === VALIDATION CHECKS ===

## Check 1: Required files exist
print_info "🔍 Checking required files..."
REQUIRED_FILES=(
    "README.md"
    "QUICK_START.md"
    ".gitignore"
    "scripts/setup-project.sh"
    "scripts/create-feature.sh"
    "scripts/build-branch.sh"
    "scripts/sync-worktrees.sh"
    "scripts/switch-context.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        print_error "Missing required file: $file"
        ERRORS=$((ERRORS + 1))
    fi
done

## Check 2: Script permissions
print_info "🔍 Checking script permissions..."
for script in scripts/*.sh scripts/{utils}/*.sh scripts/utils/*.sh; do
    if [[ -f "$script" && ! -x "$script" ]]; then
        print_warning "Script not executable: $script"
        WARNINGS=$((WARNINGS + 1))
        if [[ "$FIX_MODE" == "true" ]]; then
            chmod +x "$script"
            print_success "Fixed permissions for: $script"
        fi
    fi
done

## Check 3: .gitignore effectiveness
print_info "🔍 Checking .gitignore patterns..."
GITIGNORE_TESTS=(
    "main/"
    "feature/"
    "hotfix/"
    "performance/"
    "test.git/"
    "build/"
    "node_modules/"
)

for pattern in "${GITIGNORE_TESTS[@]}"; do
    # Create temporary test directory
    mkdir -p "temp-test-$pattern"
    if git check-ignore "temp-test-$pattern" >/dev/null 2>&1; then
        print_success ".gitignore correctly excludes: $pattern"
    else
        print_warning ".gitignore may not exclude: $pattern"
        WARNINGS=$((WARNINGS + 1))
    fi
    rmdir "temp-test-$pattern" 2>/dev/null || true
done

## Check 4: Template files
print_info "🔍 Checking template files..."
TEMPLATE_FILES=(
    "templates/flutter-project.json"
    "templates/nodejs-project.json"
    "templates/python-project.json"
    "templates/ai-docs-project.json"
)

for template in "${TEMPLATE_FILES[@]}"; do
    if [[ -f "$template" ]]; then
        # Validate JSON syntax
        if ! python3 -m json.tool "$template" >/dev/null 2>&1; then
            print_error "Invalid JSON in template: $template"
            ERRORS=$((ERRORS + 1))
        fi
    else
        print_warning "Missing template: $template"
        WARNINGS=$((WARNINGS + 1))
    fi
done

## Check 5: Documentation structure
print_info "🔍 Checking documentation structure..."
DOC_DIRS=("docs" "examples")
for dir in "${DOC_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_warning "Missing documentation directory: $dir"
        WARNINGS=$((WARNINGS + 1))
        if [[ "$FIX_MODE" == "true" ]]; then
            mkdir -p "$dir"
            print_success "Created directory: $dir"
        fi
    fi
done

## Check 6: Script syntax validation
print_info "🔍 Checking script syntax..."
for script in scripts/*.sh scripts/{utils}/*.sh scripts/utils/*.sh; do
    if [[ -f "$script" ]]; then
        if ! bash -n "$script" 2>/dev/null; then
            print_error "Syntax error in script: $script"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

## Check 7: Setup script functionality test
print_info "🔍 Testing setup script help..."
if ./scripts/setup-project.sh --help >/dev/null 2>&1; then
    print_success "setup-project.sh help works"
else
    print_error "setup-project.sh help failed"
    ERRORS=$((ERRORS + 1))
fi

## Check 8: Git configuration
print_info "🔍 Checking Git environment..."
if ! git --version >/dev/null 2>&1; then
    print_error "Git not available"
    ERRORS=$((ERRORS + 1))
fi

GIT_VERSION=$(git --version | sed 's/git version //' | cut -d. -f1-2)
if [[ $(echo "$GIT_VERSION >= 2.5" | bc -l 2>/dev/null || echo 0) -eq 0 ]]; then
    print_warning "Git version may be too old for worktrees (current: $GIT_VERSION, recommended: 2.5+)"
    WARNINGS=$((WARNINGS + 1))
fi

## Check 9: Example projects
print_info "🔍 Checking example projects..."
for example in examples/*/; do
    if [[ -d "$example" && ! -f "$example/README.md" ]]; then
        print_warning "Example missing README: $example"
        WARNINGS=$((WARNINGS + 1))
    fi
done

## Check 10: AI docs templates
print_info "🔍 Checking AI docs templates..."
if [[ -d "examples/ai-docs-templates" ]]; then
    AI_DOCS_FILES=(
        "examples/ai-docs-templates/README.md"
        "examples/ai-docs-templates/git-hooks/"
        "examples/ai-docs-templates/backend-architecture-plan/"
    )
    for item in "${AI_DOCS_FILES[@]}"; do
        if [[ ! -e "$item" ]]; then
            print_warning "Missing AI docs template: $item"
            WARNINGS=$((WARNINGS + 1))
        fi
    done
fi

# === SUMMARY ===
echo ""
print_info "=== VALIDATION SUMMARY ==="

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    print_success "🎉 Toolkit validation passed! Everything looks good."
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_warning "⚠️  Toolkit validation completed with $WARNINGS warnings."
    print_info "The toolkit should work fine, but consider addressing the warnings."
    exit 0
else
    print_error "❌ Toolkit validation failed with $ERRORS errors and $WARNINGS warnings."
    print_info "Please fix the errors before using the toolkit."
    if [[ "$FIX_MODE" != "true" ]]; then
        print_info "Try running with --fix to automatically resolve some issues."
    fi
    exit 1
fi 