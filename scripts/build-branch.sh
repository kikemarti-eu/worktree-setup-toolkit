#!/bin/bash
# Build script for Git Worktrees Flutter projects
# Usage: ./build-branch.sh <worktree-name> -- <flutter-build-args>
# Example: ./build-branch.sh feature/frontend-linux -- linux --debug

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--dry-run] <worktree-name> [--clean] -- <flutter-build-args>"
    echo ""
    echo "Options:"
    echo "  --dry-run    Validate setup but don't build"
    echo "  --clean      Run 'flutter clean' before building"
    echo ""
    echo "Examples:"
    echo "  $0 feature/frontend-linux --clean -- linux --debug"
    echo "  $0 main -- linux --release"
    echo "  $0 --dry-run feature/frontend-linux --clean -- linux --debug"
    echo ""
    echo "Available worktrees:"
    # Find bare repository
    BARE_REPO=""
    for repo in *.git; do
        if [ -d "$repo" ]; then
            BARE_REPO="$repo"
            break
        fi
    done
    
    if [ -n "$BARE_REPO" ]; then
        git -C "$BARE_REPO" worktree list 2>/dev/null | while read -r worktree_path commit branch; do
            if [[ "$worktree_path" != *".git" ]]; then
                rel_path=$(realpath --relative-to="$(pwd)" "$worktree_path" 2>/dev/null || basename "$worktree_path")
                echo "  $rel_path"
            fi
        done
    else
        echo "  (No bare repository found)"
    fi
}

# Parse arguments
DRY_RUN=false
CLEAN_BUILD=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    shift
fi

if [ $# -lt 3 ]; then
    print_error "Insufficient arguments"
    show_usage
    exit 1
fi

WORKTREE_NAME="$1"
shift

if [ "$1" = "--clean" ]; then
    CLEAN_BUILD=true
    shift
fi

# Look for -- separator
if [ "$1" != "--" ]; then
    print_error "Missing '--' separator before flutter build arguments"
    show_usage
    exit 1
fi
shift

# Remaining arguments are flutter build arguments
FLUTTER_ARGS=("$@")

print_info "Building worktree: $WORKTREE_NAME"
print_info "Flutter build arguments: ${FLUTTER_ARGS[*]}"

# Validate worktree exists
WORKTREE_PATH="$SCRIPT_DIR/$WORKTREE_NAME"
if [ ! -d "$WORKTREE_PATH" ]; then
    print_error "Worktree directory not found: $WORKTREE_PATH"
    show_usage
    exit 1
fi

# Validate frontend directory exists
FRONTEND_PATH="$WORKTREE_PATH/frontend"
if [ ! -d "$FRONTEND_PATH" ]; then
    print_error "Frontend directory not found: $FRONTEND_PATH"
    print_error "Expected: $FRONTEND_PATH"
    exit 1
fi

# Validate pubspec.yaml exists (Flutter project check)
if [ ! -f "$FRONTEND_PATH/pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. This doesn't appear to be a Flutter project."
    print_error "Expected: $FRONTEND_PATH/pubspec.yaml"
    exit 1
fi

print_success "Worktree and Flutter project validated"

# Change to frontend directory
cd "$FRONTEND_PATH"

# Execute flutter clean if requested
if [ "$CLEAN_BUILD" = "true" ]; then
    if [ "$DRY_RUN" = "true" ]; then
        print_info "[DRY RUN] Would execute: flutter clean"
    else
        print_info "Executing: flutter clean"
        if ! flutter clean; then
            print_error "Flutter clean failed"
            exit 1
        fi
        print_success "Flutter clean completed successfully"
    fi
fi

# Get git information
BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "unknown")
COMMIT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
COMMIT_SHORT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

print_info "Branch: $BRANCH_NAME"
print_info "Commit: $COMMIT_SHORT ($COMMIT_HASH)"

# Determine build type from flutter arguments
BUILD_TYPE="debug"
PLATFORM=""
for arg in "${FLUTTER_ARGS[@]}"; do
    case "$arg" in
        --release)
            BUILD_TYPE="release"
            ;;
        --debug)
            BUILD_TYPE="debug"
            ;;
        linux|android|ios|macos|windows|web)
            PLATFORM="$arg"
            ;;
    esac
done

if [ -z "$PLATFORM" ]; then
    print_error "No platform specified in flutter build arguments"
    print_error "Expected one of: linux, android, ios, macos, windows, web"
    exit 1
fi

print_info "Platform: $PLATFORM"
print_info "Build type: $BUILD_TYPE"

# Execute flutter build
if [ "$DRY_RUN" = "true" ]; then
    print_info "[DRY RUN] Would execute: flutter build ${FLUTTER_ARGS[*]}"
    print_info "[DRY RUN] Skipping actual build"
else
    print_info "Executing: flutter build ${FLUTTER_ARGS[*]}"
    if ! flutter build "${FLUTTER_ARGS[@]}"; then
        print_error "Flutter build failed"
        exit 1
    fi
    print_success "Flutter build completed successfully"
fi

# Determine source path based on platform and build type
case "$PLATFORM" in
    linux)
        SOURCE_PATH="build/linux/x64/$BUILD_TYPE/bundle"
        BINARY_NAME="dictify"
        ;;
    windows)
        SOURCE_PATH="build/windows/x64/runner/$BUILD_TYPE"
        BINARY_NAME="dictify.exe"
        ;;
    android)
        if [ "$BUILD_TYPE" = "release" ]; then
            SOURCE_PATH="build/app/outputs/flutter-apk"
            BINARY_NAME="app-release.apk"
        else
            SOURCE_PATH="build/app/outputs/flutter-apk"
            BINARY_NAME="app-debug.apk"
        fi
        ;;
    web)
        SOURCE_PATH="build/web"
        BINARY_NAME="index.html"
        ;;
    *)
        print_warning "Unknown platform: $PLATFORM"
        SOURCE_PATH="build/$PLATFORM"
        BINARY_NAME="unknown"
        ;;
esac

# Create builds directory in project root
BUILDS_DIR="$SCRIPT_DIR/builds"
if [ "$DRY_RUN" = "false" ]; then
    mkdir -p "$BUILDS_DIR"
fi

# Generate unique build identifier
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_ID="${BRANCH_NAME//\//_}_${PLATFORM}_${BUILD_TYPE}_${COMMIT_SHORT}_${TIMESTAMP}"
TARGET_DIR="$BUILDS_DIR/$BUILD_ID"

if [ "$DRY_RUN" = "true" ]; then
    print_info "[DRY RUN] Would copy build artifacts:"
    print_info "[DRY RUN]   From: $SOURCE_PATH"
    print_info "[DRY RUN]   To: $TARGET_DIR"
else
    # Copy build artifacts
    if [ -d "$SOURCE_PATH" ]; then
        print_info "Copying build artifacts to: $TARGET_DIR"
        cp -r "$SOURCE_PATH" "$TARGET_DIR"
        
        # Create build metadata
        cat > "$TARGET_DIR/BUILD_INFO.md" << EOF
# Build Information

## Project Details
- **Branch**: $BRANCH_NAME
- **Commit**: $COMMIT_SHORT ($COMMIT_HASH)
- **Platform**: $PLATFORM
- **Build Type**: $BUILD_TYPE
- **Timestamp**: $(date)

## Build Command
\`\`\`bash
flutter build ${FLUTTER_ARGS[*]}
\`\`\`

## Artifacts
- **Source Path**: $SOURCE_PATH
- **Primary Binary**: $BINARY_NAME
- **Build ID**: $BUILD_ID

## Usage
- **Linux**: \`chmod +x $BINARY_NAME && ./$BINARY_NAME\`
- **Windows**: \`$BINARY_NAME\`
- **Android**: Install APK file
- **Web**: Serve from web server
EOF
        
        print_success "Build artifacts copied to: $TARGET_DIR"
        
        # Create convenience symlink to latest build
        LATEST_LINK="$BUILDS_DIR/latest_${PLATFORM}_${BUILD_TYPE}"
        rm -f "$LATEST_LINK"
        ln -sf "$BUILD_ID" "$LATEST_LINK"
        print_info "Latest build symlink: $LATEST_LINK"
        
        # Show executable path for convenience
        if [ -f "$TARGET_DIR/$BINARY_NAME" ]; then
            print_success "Executable: $TARGET_DIR/$BINARY_NAME"
        fi
        
        # Platform-specific post-build actions
        case "$PLATFORM" in
            linux)
                if [ -f "$TARGET_DIR/$BINARY_NAME" ]; then
                    chmod +x "$TARGET_DIR/$BINARY_NAME"
                    print_info "Made executable: $TARGET_DIR/$BINARY_NAME"
                fi
                ;;
            android)
                print_info "APK ready for installation: $TARGET_DIR/$BINARY_NAME"
                ;;
            web)
                print_info "Web build ready. Serve from: $TARGET_DIR"
                print_info "Example: cd $TARGET_DIR && python -m http.server 8000"
                ;;
        esac
        
    else
        print_error "Build output directory not found: $SOURCE_PATH"
        print_error "Build may have failed or artifacts are in unexpected location"
        exit 1
    fi
fi

# Final summary
echo ""
print_success "Build process completed!"
if [ "$DRY_RUN" = "false" ]; then
    print_info "Build ID: $BUILD_ID"
    print_info "Artifacts: $TARGET_DIR"
    
    # Show disk usage
    if command -v du >/dev/null 2>&1; then
        SIZE=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        print_info "Build size: $SIZE"
    fi
fi