# Git Worktree Workflow Guide

Complete guide to using Git worktrees for professional development workflows.

## Table of Contents

- [Introduction](#introduction)
- [Core Concepts](#core-concepts)
- [Daily Workflow](#daily-workflow)
- [Advanced Patterns](#advanced-patterns)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Introduction

Git worktrees allow you to have multiple working directories from a single repository, enabling you to work on different branches simultaneously without the overhead of switching contexts or stashing changes.

### Why Use Worktrees?

**Traditional Git workflow problems:**
- Context switching between branches loses your current state
- Stashing/unstashing interrupts flow
- IDE configurations reset when switching branches
- Can't easily compare branches side-by-side
- Build artifacts get mixed between branches

**Worktree solutions:**
- Each branch has its own working directory
- Multiple branches checked out simultaneously
- Independent IDE sessions per feature
- Side-by-side branch comparison
- Isolated build environments

## Core Concepts

### Repository Structure

```
your-project/
├── ProjectName.git/          # Bare repository (central storage)
├── main/                     # Main branch worktree
├── feature/
│   ├── user-authentication/  # Feature worktrees
│   └── ui-improvements/
├── hotfix/
│   └── critical-bug-fix/     # Hotfix worktrees
└── scripts...                # Automation tools
```

### Key Components

1. **Bare Repository** (`ProjectName.git/`): Central Git database
2. **Main Worktree** (`main/`): Primary development branch
3. **Feature Worktrees** (`feature/*/`): Individual feature development
4. **Hotfix Worktrees** (`hotfix/*/`): Critical fixes
5. **Automation Scripts**: Tools for managing worktrees

## Daily Workflow

### 1. Starting a New Feature

```bash
# Create new feature branch and worktree
./create-feature.sh feature/user-login --issue 123

# Switch to the new feature directory
cd feature/user-login

# Start coding immediately!
code .  # Opens in VS Code
```

### 2. Working on Multiple Features

```bash
# Terminal 1: Working on authentication
cd feature/user-authentication
# Edit files, make commits...

# Terminal 2: Working on UI improvements
cd feature/ui-improvements  
# Edit different files simultaneously...

# Terminal 3: Testing main branch
cd main
./build-branch.sh main -- linux --release
```

### 3. Comparing Branches

```bash
# Open both directories in your IDE
code feature/user-login feature/ui-improvements

# Or use command line diff
diff -r feature/user-login/lib feature/ui-improvements/lib
```

### 4. Building and Testing

```bash
# Build specific feature
./build-branch.sh feature/user-login -- flutter build android

# Test multiple branches
./build-branch.sh main -- flutter test
./build-branch.sh feature/user-login -- flutter test
```

### 5. Context Switching

```bash
# List all worktrees
./switch-context.sh

# Quick switch (opens new shell in worktree)
./switch-context.sh feature/user-authentication
```

### 6. Syncing with Remote

```bash
# Sync all worktrees with remote changes
./sync-worktrees.sh

# Or sync specific worktree
cd feature/user-login
git pull origin main  # Merge main branch changes
```

## Advanced Patterns

### Parallel Development

```bash
# Create multiple related features
./create-feature.sh feature/auth-backend --issue 100
./create-feature.sh feature/auth-frontend --issue 101
./create-feature.sh feature/auth-testing --issue 102

# Work on all simultaneously
# Terminal 1: Backend development
cd feature/auth-backend
# Terminal 2: Frontend development  
cd feature/auth-frontend
# Terminal 3: Test development
cd feature/auth-testing
```

### Release Preparation

```bash
# Create release branch
./create-feature.sh release/v2.0.0

# Cherry-pick features into release
cd release/v2.0.0
git cherry-pick feature/user-login
git cherry-pick feature/ui-improvements

# Build and test release
./build-branch.sh release/v2.0.0 -- flutter build --release
```

### Hotfix Workflow

```bash
# Create hotfix from main
./create-feature.sh hotfix/security-patch main --issue 999

cd hotfix/security-patch
# Fix the critical issue
git commit -m "Fix security vulnerability"

# Test hotfix
./build-branch.sh hotfix/security-patch -- flutter test

# Merge back to main and develop
cd main
git merge hotfix/security-patch
```

### Code Review Setup

```bash
# Reviewer checks out PR branch
./create-feature.sh review/pr-123 feature/user-login

cd review/pr-123
# Review code, test locally
./build-branch.sh review/pr-123 -- flutter test

# Clean up after review
git worktree remove review/pr-123
```

## Troubleshooting

### Common Issues

#### "Worktree already exists"

```bash
# Remove existing worktree first
git worktree remove feature/my-feature
./create-feature.sh feature/my-feature
```

#### "Branch already checked out"

```bash
# Option 1: Use different branch name
./create-feature.sh feature/my-feature-v2

# Option 2: Remove existing worktree
git worktree list  # Find which worktree has the branch
git worktree remove path/to/worktree
```

#### Stale worktree references

```bash
# Clean up stale references
./scripts/utils/troubleshoot.sh --clean-stale
```

#### Build failures in worktrees

```bash
# Validate setup
./scripts/utils/validate-setup.sh

# Clean build
./build-branch.sh feature/my-branch --clean -- your-build-args
```

### Diagnostic Commands

```bash
# Check worktree health
./scripts/utils/validate-setup.sh

# Comprehensive troubleshooting
./scripts/utils/troubleshoot.sh --repair-all

# List all worktrees
git worktree list

# Check Git configuration
git config --list | grep worktree
```

## Best Practices

### Organization

1. **Consistent Naming**: Use descriptive, consistent branch names
   ```bash
   feature/user-authentication
   feature/payment-integration
   hotfix/security-patch
   ```

2. **Directory Structure**: Keep worktrees organized by type
   ```
   feature/
   hotfix/ 
   release/
   experiment/
   ```

### Development

1. **Keep Worktrees Focused**: One feature per worktree
2. **Regular Syncing**: Sync worktrees daily with `./sync-worktrees.sh`
3. **Clean Up**: Remove completed worktrees promptly
4. **Use Issue Linking**: Always link branches to issues

### Performance

1. **Limit Active Worktrees**: Keep 3-5 active worktrees maximum
2. **Clean Build Artifacts**: Use `--clean` flag when needed
3. **Monitor Disk Usage**: Check with `du -sh */`

### Collaboration

1. **Document Workflow**: Keep `WORKTREE_GUIDE.md` updated
2. **Share Scripts**: Ensure all team members have automation scripts
3. **Consistent Setup**: Use project templates for consistency

### Git Configuration

```bash
# Recommended Git settings for worktrees
git config core.worktree true
git config extensions.worktreeConfig true

# Prevent accidental commits to wrong branch
git config branch.autosetupmerge always
git config branch.autosetuprebase always
```

## Integration with IDEs

### VS Code

```bash
# Open specific worktree
code feature/user-login

# Open multiple worktrees in separate windows
code main feature/user-login feature/ui-improvements
```

### JetBrains IDEs

```bash
# Open project in IntelliJ/WebStorm
idea feature/user-login

# Or use "Open Folder" in the IDE
```

### Vim/Neovim

```bash
# Use session management
cd feature/user-login
nvim -S Session.vim  # Restore specific session
```

## Automation Tips

### Custom Scripts

Create project-specific scripts in your worktree root:

```bash
# quick-test.sh
#!/bin/bash
./build-branch.sh $1 -- flutter test --coverage

# Usage: ./quick-test.sh feature/user-login
```

### Git Aliases

```bash
# Add to ~/.gitconfig
[alias]
    wtlist = worktree list
    wtadd = worktree add
    wtremove = worktree remove
    wtprune = worktree prune
```

### Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
export WORKTREE_ROOT="/path/to/your/projects"
alias cdwt="cd $WORKTREE_ROOT"
```

---

For more advanced topics and troubleshooting, see:
- [Git Hooks Setup](git-hooks-setup.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Architecture Overview](architecture-overview.md) 