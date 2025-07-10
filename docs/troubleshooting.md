# Troubleshooting Guide

This guide covers common issues and solutions for the Git Worktree Setup Toolkit.

## 🚨 Quick Fixes

### Script Permissions Error
```bash
# Problem: Permission denied when running scripts
chmod +x scripts/*.sh
chmod +x *.sh
```

### Git Version Issues
```bash
# Check Git version (requires 2.5+)
git --version

# Update Git on Ubuntu/Debian
sudo apt update && sudo apt install git

# Update Git on macOS
brew install git
```

### Path Not Found
```bash
# Always run scripts from project root
cd /path/to/your-project
./create-feature.sh feature/my-feature
```

## 🔍 Diagnostic Tools

### Health Check
```bash
# Validate toolkit installation
./scripts/validate-toolkit.sh

# Check project setup
./scripts/utils/validate-setup.sh

# Get diagnostic information
./scripts/utils/troubleshoot.sh
```

### Auto-Fix Common Issues
```bash
# Automatically repair common problems
./scripts/utils/validate-setup.sh --fix
```

## 📋 Common Issues

### 1. Setup Script Failures

**Issue**: `setup-project.sh` fails during repository clone
```bash
[ERROR] Failed to clone repository
```

**Solutions**:
```bash
# Check network connectivity
ping github.com

# Verify repository URL
git ls-remote <repo-url>

# Check Git credentials
git config --global user.name
git config --global user.email

# Try with SSH instead of HTTPS
./scripts/setup-project.sh git@github.com:org/repo.git project-name
```

**Issue**: Target directory already exists
```bash
[ERROR] Target directory already exists: /path/to/project
```

**Solutions**:
```bash
# Remove existing directory
rm -rf /path/to/project

# Or choose different project name
./scripts/setup-project.sh <repo-url> different-name
```

### 2. Worktree Creation Issues

**Issue**: Failed to create worktree
```bash
fatal: 'feature/my-branch' is already checked out at '/path/to/worktree'
```

**Solutions**:
```bash
# Remove existing worktree
git worktree remove feature/my-branch

# Or use different branch name
./create-feature.sh feature/my-branch-v2
```

**Issue**: Branch doesn't exist on remote
```bash
fatal: invalid reference: feature/non-existent
```

**Solutions**:
```bash
# Create branch locally first
./create-feature.sh feature/new-branch

# Or specify base branch
./create-feature.sh feature/new-branch main
```

### 3. Build Script Issues

**Issue**: Build fails with missing dependencies
```bash
[ERROR] flutter: command not found
```

**Solutions**:
```bash
# Install Flutter
snap install flutter --classic

# Verify installation
flutter doctor

# Update PATH if needed
export PATH="$PATH:/path/to/flutter/bin"
```

**Issue**: Wrong build target
```bash
[ERROR] Unsupported build target: ios
```

**Solutions**:
```bash
# Check available targets
./build-branch.sh --help

# Use correct target for your platform
./build-branch.sh main -- linux --debug
```

### 4. Context Switching Problems

**Issue**: Can't switch to worktree
```bash
cd: no such file or directory: feature/my-branch
```

**Solutions**:
```bash
# List available worktrees
./switch-context.sh

# Verify worktree exists
git worktree list

# Create missing worktree
./create-feature.sh feature/my-branch
```

### 5. Sync Issues

**Issue**: Sync fails with conflicts
```bash
error: Your local changes to the following files would be overwritten by merge
```

**Solutions**:
```bash
# Check which worktree has conflicts
git status

# Stash or commit changes
git add . && git commit -m "WIP: save work"

# Or stash temporarily
git stash

# Then retry sync
./sync-worktrees.sh
```

### 6. Git Hooks Issues

**Issue**: Git hooks not executing
```bash
# Hooks installed but not running
```

**Solutions**:
```bash
# Check hook permissions
ls -la .git/hooks/

# Make hooks executable
chmod +x .git/hooks/*

# Reinstall hooks
./scripts/utils/setup-hooks.sh
```

**Issue**: Hook fails due to missing tools
```bash
./git/hooks/pre-commit: line 5: flutter: command not found
```

**Solutions**:
```bash
# Install missing tools
which flutter || snap install flutter --classic

# Update hook PATH
export PATH="$PATH:/snap/bin"

# Or disable problematic hooks temporarily
git config --local hooks.pre-commit false
```

## 🔧 Advanced Troubleshooting

### Corrupted Worktree Recovery

**Symptoms**: Worktree behaves strangely, Git commands fail
```bash
# Remove corrupted worktree
git worktree remove --force feature/corrupted-branch

# Recreate worktree
./create-feature.sh feature/recovered-branch

# Restore work from backup if needed
cp -r backup/feature/corrupted-branch/* feature/recovered-branch/
```

### Bare Repository Issues

**Problem**: Accidentally modified files in `ProjectName.git/`
```bash
# Reset bare repository to clean state
cd ProjectName.git
git reset --hard HEAD

# Or restore from remote
git fetch origin
git reset --hard origin/main
```

### Disk Space Issues

**Problem**: Multiple worktrees consuming too much space
```bash
# Check worktree disk usage
du -sh */

# Remove unused worktrees
git worktree list
git worktree remove feature/old-feature

# Clean build artifacts
./build-branch.sh --clean main
```

### Remote URL Changes

**Problem**: Remote repository moved to new URL
```bash
# Update remote URL in bare repository
cd ProjectName.git
git remote set-url origin <new-url>

# Update all worktrees
./sync-worktrees.sh
```

## 🐛 Reporting Issues

If you encounter issues not covered here:

### 1. Gather Information
```bash
# Run diagnostic script
./scripts/utils/troubleshoot.sh > troubleshooting-info.txt

# Include system information
uname -a >> troubleshooting-info.txt
git --version >> troubleshooting-info.txt
```

### 2. Create Minimal Reproduction
```bash
# Test with simple repository
./scripts/setup-project.sh https://github.com/octocat/Hello-World.git test-repo --dry-run
```

### 3. Check Logs
```bash
# Enable debug output
export DEBUG=1
./create-feature.sh feature/debug-test

# Check recent Git operations
git reflog
```

## 🎯 Prevention Tips

### Regular Maintenance
```bash
# Weekly health check
./scripts/utils/validate-setup.sh

# Monthly cleanup
git worktree prune
git gc
```

### Best Practices
- Always run scripts from project root
- Keep Git up to date
- Don't manually modify bare repository
- Use provided scripts for worktree management
- Commit work before switching contexts

### Backup Strategy
```bash
# Create project backup before major changes
tar -czf project-backup-$(date +%Y%m%d).tar.gz ProjectName/

# Version control your automation scripts
git add *.sh && git commit -m "Update automation scripts"
```

## 🆘 Getting Help

1. **Check this guide first** - Most issues are covered here
2. **Run diagnostics** - Use `validate-setup.sh` and `troubleshoot.sh`
3. **Search documentation** - Check README.md and workflow guides
4. **Create issue** - Report bugs with full diagnostic information
5. **Community help** - Ask in project discussions or forums

---

**💡 Pro Tip**: Most worktree issues can be resolved by recreating the problematic worktree. Always commit your work before troubleshooting! 