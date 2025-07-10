# Worktree Development Workflow

## Introduction

Git worktrees allow you to work on multiple branches simultaneously without the overhead of multiple repository clones. This guide covers the complete workflow for using the worktree setup toolkit.

## Core Concepts

### Repository Structure
```
project/
├── ProjectName.git/          # Bare repository (central storage)
├── main/                     # Main branch worktree
├── feature/
│   ├── user-authentication/  # Feature branch worktrees
│   └── api-improvements/
├── hotfix/
│   └── critical-bug/         # Hotfix worktrees
└── [automation scripts]
```

### Key Principles
- **Bare Repository**: Central storage, never work directly here
- **Worktrees**: Individual checkouts for each branch
- **Isolation**: Each worktree has independent working state
- **Shared History**: All worktrees share the same Git history

## Daily Workflow

### 1. Starting a New Feature

```bash
# Create feature branch from main
./create-feature.sh feature/user-authentication --issue 123

# Switch to the new worktree
cd feature/user-authentication

# Start development
git status
```

### 2. Working in a Worktree

```bash
# Normal Git operations work as expected
git add .
git commit -m "feat: add user login form"
git push origin feature/user-authentication

# Switch between worktrees without losing work
cd ../main
git pull origin main
cd ../feature/user-authentication
```

### 3. Building and Testing

```bash
# Build specific worktree (Flutter example)
./build-branch.sh feature/user-authentication -- linux --debug

# Clean build if needed
./build-branch.sh feature/user-authentication --clean -- linux --release

# Validate build before deploy
./build-branch.sh --dry-run feature/user-authentication -- linux --release
```

### 4. Context Switching

```bash
# List available worktrees
./switch-context.sh

# Quick switch to another branch
./switch-context.sh hotfix/critical-security-fix

# Work on hotfix
git commit -m "fix: patch security vulnerability"
git push origin hotfix/critical-security-fix

# Switch back to feature work  
./switch-context.sh feature/user-authentication
```

### 5. Keeping Everything Synchronized

```bash
# Sync all worktrees with remote
./sync-worktrees.sh

# Preview sync operations
./sync-worktrees.sh --dry-run
```

## Advanced Patterns

### Parallel Development

Work on multiple features simultaneously:

```bash
# Terminal 1: Frontend work
cd feature/user-interface
npm run dev

# Terminal 2: Backend work  
cd feature/api-improvements
python manage.py runserver

# Terminal 3: Testing
cd main
./run-integration-tests.sh
```

### Release Preparation

```bash
# Create release branch
./create-feature.sh release/v1.2.0 main

# Merge features
cd release/v1.2.0
git merge feature/user-authentication
git merge feature/api-improvements

# Build release candidates
./build-branch.sh release/v1.2.0 -- linux --release
./build-branch.sh release/v1.2.0 -- windows --release
```

### Hotfix Workflow

```bash
# Create hotfix from main
./create-feature.sh hotfix/security-patch main --issue 456

# Apply fix
cd hotfix/security-patch
# ... make changes ...
git commit -m "fix: resolve security vulnerability - fixes #456"

# Test fix
./build-branch.sh hotfix/security-patch --clean -- linux --debug

# Deploy when ready
git push origin hotfix/security-patch
```

## Troubleshooting

### Common Issues

**Worktree not responding to Git commands**
```bash
# Check worktree health
./scripts/utils/validate-setup.sh

# Repair if needed
./scripts/utils/validate-setup.sh --fix
```

**Build artifacts in wrong location**
```bash
# Check build configuration
./build-branch.sh --dry-run feature/my-branch -- linux --debug

# Clean and rebuild
./build-branch.sh feature/my-branch --clean -- linux --debug
```

**Sync conflicts**
```bash
# Check which worktrees have conflicts
./sync-worktrees.sh --dry-run

# Resolve conflicts manually in each worktree
cd feature/problematic-branch
git status
git resolve-conflicts
```

### Recovery Procedures

**Corrupted worktree**
```bash
# Remove and recreate
git worktree remove feature/broken-branch
./create-feature.sh feature/broken-branch main
```

**Missing remote tracking**
```bash
cd feature/my-branch
git branch --set-upstream-to=origin/feature/my-branch
```

## Best Practices

### Branch Naming
- **Features**: `feature/descriptive-name` or `feature/issue-123-description`
- **Bug fixes**: `bugfix/issue-456-crash-fix`
- **Hotfixes**: `hotfix/critical-security-patch`
- **Performance**: `performance/optimize-database`
- **Refactoring**: `refactor/clean-up-auth-service`

### Commit Messages
Use conventional commit format:
```bash
feat: add user authentication system
fix: resolve login validation bug - fixes #123
docs: update API documentation
style: format code according to style guide
refactor: simplify database queries
test: add unit tests for auth service
chore: update dependencies
```

### Worktree Management
- Keep worktrees focused on single features
- Remove completed worktrees promptly
- Use descriptive branch names
- Link branches to issues when possible
- Sync regularly to avoid conflicts

### Build Management
- Use `--dry-run` to validate before building
- Keep build artifacts organized in `builds/` directory
- Clean builds when switching between major changes
- Tag important builds for easy reference

## Integration with IDEs

### VS Code
```bash
# Open specific worktree
code feature/user-authentication

# Multi-root workspace for parallel development
code --add feature/user-authentication
code --add feature/api-improvements
```

### JetBrains IDEs
- Open each worktree as separate project
- Use project groups for organization
- Configure shared code style settings

### Terminal Multiplexers
```bash
# tmux session for worktree development
tmux new-session -d -s worktrees
tmux new-window -t worktrees -n main 'cd main && bash'
tmux new-window -t worktrees -n feature 'cd feature/user-auth && bash'
tmux attach-session -t worktrees
```

## Performance Tips

### Large Repositories
- Use shallow clones when possible
- Configure Git to use sparse checkout
- Regularly clean up unused worktrees
- Monitor disk usage in builds directory

### Build Optimization
- Cache dependencies between builds
- Use incremental builds when supported
- Parallel builds for multiple platforms
- Shared build artifacts for similar configurations

## Security Considerations

### Sensitive Data
- Never commit secrets to any worktree
- Use environment files (excluded by .gitignore)
- Implement pre-commit hooks to catch secrets
- Regularly audit committed files

### Access Control
- Configure appropriate Git hooks
- Use signed commits for important changes
- Implement branch protection rules
- Monitor access to bare repository

---

This workflow documentation provides a comprehensive foundation for productive development with Git worktrees. Adapt the patterns to fit your specific project needs and team requirements. 