# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Git Worktree Setup Toolkit** - a comprehensive system for converting any Git repository into a professional worktree-based development environment. The toolkit provides automated setup, intelligent branch management, and cross-platform compatibility for teams wanting to leverage Git worktrees for parallel development.

## Core Architecture

### Main Components
- **scripts/**: Automation scripts for worktree lifecycle management
  - `setup-project.sh`: Main entry point - converts repos to worktree setup
  - `create-feature.sh`: Creates feature branches with optional issue linking
  - `build-branch.sh`: Builds specific worktrees with isolated environments
  - `sync-worktrees.sh`: Syncs all worktrees with remote repository
  - `switch-context.sh`: Quick context switching between worktrees
  - `validate-toolkit.sh`: Validates toolkit integrity and auto-fixes issues

- **templates/**: Project-type-specific configurations
  - JSON templates define build targets, package managers, Git hooks, and quality checks
  - Support for Node.js, Flutter, Python, and AI-enhanced documentation projects

- **docs/**: Comprehensive workflow documentation and troubleshooting guides

- **examples/**: Real-world project setups demonstrating toolkit usage

### Worktree Structure Created by Toolkit
When the toolkit processes a repository, it creates:
```
target-project/
├── ProjectName.git/          # Bare repository (never modify directly)
├── main/                     # Main branch worktree  
├── feature/                  # Feature branch worktrees
├── hotfix/                   # Hotfix branch worktrees
└── [automation scripts]     # Copied from toolkit
```

## Key Development Commands

### Toolkit Validation
```bash
# Validate toolkit integrity
./scripts/validate-toolkit.sh

# Auto-fix common issues
./scripts/validate-toolkit.sh --fix
```

### Setting Up Projects
```bash
# Basic setup
./scripts/setup-project.sh <repo-url> <project-name>

# With project template
./scripts/setup-project.sh <repo-url> <project-name> --config templates/nodejs-project.json

# Setup in current directory (in-place)
./scripts/setup-project.sh <repo-url> --in-place

# Migrate existing repository
./scripts/migrate-existing.sh /path/to/existing/repo
```

### Working with Generated Projects
After setup, projects have these commands available:
```bash
# Create feature branches
./create-feature.sh feature/branch-name --issue 123

# Build specific branches
./build-branch.sh feature/branch-name -- --release

# Sync all worktrees
./sync-worktrees.sh

# Switch contexts
./switch-context.sh feature/branch-name
```

## Template System

Templates are JSON configurations that define:
- **worktree_structure**: Branch organization and protection rules
- **build_targets**: Commands for development, production, and testing
- **package_managers**: Support for npm, yarn, pnpm
- **git_hooks**: Pre-commit, commit-msg, post-checkout automation
- **quality_checks**: Linting, formatting, testing requirements
- **ignore_patterns**: Files/directories to exclude from worktrees

## Cross-Platform Considerations

The toolkit detects platform (Linux/macOS/Windows) and adapts:
- Uses `uname -s` for platform detection in `scripts/setup-project.sh:29-37`
- Windows support via Git Bash/WSL
- Path handling varies by platform for script execution

## Development Workflow

1. **Toolkit Development**: Modify scripts in `scripts/` directory
2. **Template Updates**: Edit JSON configurations in `templates/`
3. **Documentation**: Update guides in `docs/` and examples in `examples/`
4. **Validation**: Always run `./scripts/validate-toolkit.sh --fix` before committing
5. **Testing**: Test with different project types using template configurations

## Important Patterns

- **Bare Repository Safety**: Scripts prevent accidental modification of `.git` bare repositories
- **Atomic Operations**: Setup operations are atomic - either complete success or clean rollback
- **Issue Integration**: Feature creation supports GitHub issue linking via `--issue` flag
- **Isolated Builds**: Each worktree maintains independent build environments
- **Cross-Worktree Sync**: Central sync mechanism keeps all worktrees updated

## Error Handling

- Use `./scripts/utils/troubleshoot.sh` for diagnostic information
- `./scripts/utils/validate-setup.sh` validates project setup health
- All scripts include colored output for status indication (INFO/SUCCESS/WARNING/ERROR)